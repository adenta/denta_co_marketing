import { useState } from "react";
import { getCsrfToken } from "@/lib/csrf";

type HttpMethod = "POST" | "PATCH" | "PUT" | "DELETE";
type ApiErrors = Record<string, string[]>;

type ApiRequestOptions<TResponse> = {
  onSuccess?: (data: TResponse | null) => void;
  onError?: (error: string, errors?: ApiErrors, payload?: ApiErrorPayload | null) => void;
};

type ApiErrorPayload = {
  errors?: ApiErrors;
  message?: string;
  error?: string;
  redirect_to?: string;
};

async function parseJson(response: Response): Promise<unknown> {
  if (response.status === 204) {
    return null;
  }

  const contentType = response.headers.get("content-type") ?? "";

  if (!contentType.includes("application/json")) {
    return null;
  }

  try {
    return await response.json();
  } catch {
    return null;
  }
}

export function useApiRequest<TResponse = unknown>(
  options: ApiRequestOptions<TResponse> = {},
) {
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<ApiErrors>({});

  const makeRequest = async (
    method: HttpMethod,
    url: string,
    data?: unknown,
  ): Promise<TResponse | null> => {
    setLoading(true);
    setErrors({});

    try {
      const csrfToken = getCsrfToken();
      const response = await fetch(url, {
        method,
        credentials: "same-origin",
        headers: {
          Accept: "application/json",
          ...(data !== undefined ? { "Content-Type": "application/json" } : {}),
          ...(csrfToken ? { "X-CSRF-Token": csrfToken } : {}),
        },
        ...(data !== undefined ? { body: JSON.stringify(data) } : {}),
      });

      const payload = (await parseJson(response)) as TResponse | ApiErrorPayload | null;

      if (response.ok) {
        const result = payload as TResponse | null;
        options.onSuccess?.(result);
        return result;
      }

      const apiError = payload as ApiErrorPayload | null;

      if (apiError?.errors) {
        setErrors(apiError.errors);
        const message = apiError.message ?? "Validation failed";
        options.onError?.(message, apiError.errors, apiError);
        throw new Error(message);
      }

      const message =
        apiError?.message ??
        apiError?.error ??
        `Request failed (${response.status})`;

      options.onError?.(message, undefined, apiError);
      throw new Error(message);
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      }

      const message = "An unexpected error occurred.";
      options.onError?.(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  };

  const getFieldError = (fieldName: string): string | undefined =>
    errors[fieldName]?.[0];

  const getBaseErrors = (): string[] => errors.base ?? [];

  const hasErrors = (): boolean => Object.keys(errors).length > 0;

  return {
    loading,
    errors,
    makeRequest,
    getFieldError,
    getBaseErrors,
    hasErrors,
    clearErrors: () => setErrors({}),
  };
}
