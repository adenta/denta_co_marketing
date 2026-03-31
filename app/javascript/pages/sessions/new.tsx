import { FormEvent, useState } from "react";
import { visit } from "@hotwired/turbo";
import { AuthShell } from "@/components/auth/auth-shell";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type SessionsNewProps = {
  create_path: string;
  forgot_password_path: string;
  sign_up_path: string;
};

export default function SessionsNew({
  create_path,
  forgot_password_path,
  sign_up_path,
}: SessionsNewProps) {
  const [emailAddress, setEmailAddress] = useState("");
  const [password, setPassword] = useState("");
  const toast = useToast();
  const { loading, getBaseErrors, clearErrors, makeRequest } =
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
    });
  };

  return (
    <AuthShell
      eyebrow="Account Access"
      title="Sign in"
      description="Use your email address and password to pick up where you left off."
      footer={
        <div className="space-y-2">
          <p>
            Forgot your password?{" "}
            <a className="font-medium text-foreground underline underline-offset-4" href={forgot_password_path}>
              Reset it here
            </a>
            .
          </p>
          <p>
            Need an account?{" "}
            <a className="font-medium text-foreground underline underline-offset-4" href={sign_up_path}>
              Create one
            </a>
            .
          </p>
        </div>
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
            htmlFor="session-email-address"
            className="text-sm font-medium text-foreground"
          >
            Email address
          </label>
          <Input
            id="session-email-address"
            type="email"
            autoComplete="username"
            autoFocus
            required
            value={emailAddress}
            onChange={event => setEmailAddress(event.target.value)}
          />
        </div>

        <div className="space-y-2">
          <label
            htmlFor="session-password"
            className="text-sm font-medium text-foreground"
          >
            Password
          </label>
          <Input
            id="session-password"
            type="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={event => setPassword(event.target.value)}
          />
        </div>

        <Button type="submit" className="w-full" size="lg" disabled={loading}>
          {loading ? "Signing in..." : "Sign in"}
        </Button>
      </form>
    </AuthShell>
  );
}
