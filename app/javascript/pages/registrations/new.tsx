import { FormEvent, useState } from "react";
import { visit } from "@hotwired/turbo";
import { AuthShell } from "@/components/auth/auth-shell";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type RegistrationsNewProps = {
  create_path: string;
  sign_in_path: string;
};

export default function RegistrationsNew({
  create_path,
  sign_in_path,
}: RegistrationsNewProps) {
  const [emailAddress, setEmailAddress] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const toast = useToast();
  const { loading, getFieldError, getBaseErrors, clearErrors, makeRequest } =
    useApiRequest<{ redirect_to: string }>({
      onSuccess: payload => {
        visit(payload?.redirect_to ?? "/");
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

    await makeRequest("POST", create_path, {
      email_address: emailAddress,
      password,
      password_confirmation: passwordConfirmation,
    });
  };

  return (
    <AuthShell
      eyebrow="Create Account"
      title="Sign up"
      description="Create an account with your email address and password."
      footer={
        <p>
          Already have an account?{" "}
          <a
            className="font-medium text-foreground underline underline-offset-4"
            href={sign_in_path}
          >
            Sign in instead
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
            htmlFor="registration-email-address"
            className="text-sm font-medium text-foreground"
          >
            Email address
          </label>
          <Input
            id="registration-email-address"
            type="email"
            autoComplete="email"
            autoFocus
            required
            value={emailAddress}
            onChange={event => setEmailAddress(event.target.value)}
            aria-invalid={getFieldError("email_address") ? true : undefined}
          />
          {getFieldError("email_address") ? (
            <p className="text-sm text-destructive">{getFieldError("email_address")}</p>
          ) : null}
        </div>

        <div className="space-y-2">
          <label
            htmlFor="registration-password"
            className="text-sm font-medium text-foreground"
          >
            Password
          </label>
          <Input
            id="registration-password"
            type="password"
            autoComplete="new-password"
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
            htmlFor="registration-password-confirmation"
            className="text-sm font-medium text-foreground"
          >
            Confirm password
          </label>
          <Input
            id="registration-password-confirmation"
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
          {loading ? "Creating account..." : "Create account"}
        </Button>
      </form>
    </AuthShell>
  );
}
