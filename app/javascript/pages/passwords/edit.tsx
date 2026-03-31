import { FormEvent, useState } from "react";
import { visit } from "@hotwired/turbo";
import { AuthShell } from "@/components/auth/auth-shell";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type PasswordsEditProps = {
  update_path: string;
  sign_in_path: string;
};

export default function PasswordsEdit({
  update_path,
  sign_in_path,
}: PasswordsEditProps) {
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const toast = useToast();
  const { loading, getFieldError, getBaseErrors, clearErrors, makeRequest } =
    useApiRequest<{ redirect_to: string }>({
      onSuccess: payload => {
        visit(payload?.redirect_to ?? sign_in_path);
      },
      onError: (message, errors, payload) => {
        if (payload?.redirect_to) {
          visit(payload.redirect_to);
          return;
        }

        if (!errors) {
          toast.error(message);
        }
      },
    });

  const onSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    clearErrors();

    if (!event.currentTarget.reportValidity()) {
      return;
    }

    await makeRequest("PATCH", update_path, {
      password,
      password_confirmation: passwordConfirmation,
    });
  };

  return (
    <AuthShell
      eyebrow="Set A New Password"
      title="Choose a new password"
      description="Enter your new password twice to confirm the reset."
      footer={
        <p>
          Want to try signing in again?{" "}
          <a className="font-medium text-foreground underline underline-offset-4" href={sign_in_path}>
            Back to sign in
          </a>
          .
        </p>
      }
    >
      <form className="space-y-4" onSubmit={onSubmit}>
        {getBaseErrors().length > 0 ? (
          <div className="rounded-lg border border-destructive/20 bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {getBaseErrors().join(" ")}
          </div>
        ) : null}

        <div className="space-y-2">
          <label
            htmlFor="password-reset-password"
            className="text-sm font-medium text-foreground"
          >
            New password
          </label>
          <Input
            id="password-reset-password"
            type="password"
            autoComplete="new-password"
            autoFocus
            required
            value={password}
            onChange={event => setPassword(event.target.value)}
            aria-invalid={getFieldError("password") ? true : undefined}
          />
          {getFieldError("password") ? (
            <p className="text-sm text-destructive">{getFieldError("password")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <label
            htmlFor="password-reset-password-confirmation"
            className="text-sm font-medium text-foreground"
          >
            Confirm password
          </label>
          <Input
            id="password-reset-password-confirmation"
            type="password"
            autoComplete="new-password"
            required
            value={passwordConfirmation}
            onChange={event => setPasswordConfirmation(event.target.value)}
            aria-invalid={getFieldError("password_confirmation") ? true : undefined}
          />
          {getFieldError("password_confirmation") ? (
            <p className="text-sm text-destructive">
              {getFieldError("password_confirmation")}
            </p>
          ) : null}
        </div>

        <Button type="submit" className="w-full" size="lg" disabled={loading}>
          {loading ? "Resetting password..." : "Reset password"}
        </Button>
      </form>
    </AuthShell>
  );
}
