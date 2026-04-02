import { FormEvent, useId, useState } from "react";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type BlogSubscribeFormProps = {
  createPath: string;
  title: string;
  description: string;
  emailLabel: string;
  emailPlaceholder?: string;
  submitLabel: string;
  successMessage?: string;
};

export default function BlogSubscribeForm({
  createPath,
  title,
  description,
  emailLabel,
  emailPlaceholder,
  submitLabel,
  successMessage,
}: BlogSubscribeFormProps) {
  const emailId = useId();
  const toast = useToast();
  const [emailAddress, setEmailAddress] = useState("");
  const { loading, getBaseErrors, getFieldError, clearErrors, makeRequest } =
    useApiRequest<{ message?: string }>({
      onSuccess: payload => {
        toast.success(payload?.message ?? successMessage ?? "");
        setEmailAddress("");
      },
      onError: (message, errors) => {
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

    await makeRequest("POST", createPath, {
      email_address: emailAddress,
    });
  };

  return (
    <section className="rounded-3xl border border-border/70 bg-card/90 p-6 shadow-sm shadow-black/5">
      <div className="space-y-2">
        <h2 className="text-2xl font-semibold tracking-tight text-foreground">{title}</h2>
        <p className="max-w-2xl text-base leading-7 text-muted-foreground">{description}</p>
      </div>

      <form className="mt-5 space-y-4" onSubmit={onSubmit}>
        {getBaseErrors().length > 0 ? (
          <div className="rounded-lg border border-destructive/20 bg-destructive/10 px-3 py-2 text-sm text-destructive">
            {getBaseErrors().join(" ")}
          </div>
        ) : null}

        <div className="space-y-2">
          <label htmlFor={emailId} className="text-sm font-medium text-foreground">
            {emailLabel}
          </label>
          <Input
            id={emailId}
            type="email"
            autoComplete="email"
            required
            value={emailAddress}
            placeholder={emailPlaceholder}
            onChange={event => setEmailAddress(event.target.value)}
            aria-invalid={getFieldError("email_address") ? true : undefined}
          />
          {getFieldError("email_address") ? (
            <p className="text-sm text-destructive">{getFieldError("email_address")}</p>
          ) : null}
        </div>

        <Button type="submit" size="lg" disabled={loading}>
          {submitLabel}
        </Button>
      </form>
    </section>
  );
}
