import { FormEvent, useState } from "react";
import { visit } from "@hotwired/turbo";
import { AuthShell } from "@/components/auth/auth-shell";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type PasswordsNewProps = {
  create_path: string;
  sign_in_path: string;
};

export default function PasswordsNew({
  create_path,
  sign_in_path,
}: PasswordsNewProps) {
  const [emailAddress, setEmailAddress] = useState("");
  const toast = useToast();
  const { loading, makeRequest } = useApiRequest<{ redirect_to: string }>({
    onSuccess: payload => {
      visit(payload?.redirect_to ?? sign_in_path);
    },
    onError: message => {
      toast.error(message);
    },
  });

  const onSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    if (!event.currentTarget.reportValidity()) {
      return;
    }

    await makeRequest("POST", create_path, {
      email_address: emailAddress,
    });
  };

  return (
    <AuthShell
      eyebrow="Password Recovery"
      title="Reset your password"
      description="We will send you a reset link if an account exists for the email address you enter."
      footer={
        <p>
          Remembered it?{" "}
          <a className="font-medium text-foreground underline underline-offset-4" href={sign_in_path}>
            Return to sign in
          </a>
          .
        </p>
      }
    >
      <form className="space-y-4" onSubmit={onSubmit}>

        <div className="space-y-2">
          <label
            htmlFor="password-reset-email-address"
            className="text-sm font-medium text-foreground"
          >
            Email address
          </label>
          <Input
            id="password-reset-email-address"
            type="email"
            autoComplete="email"
            autoFocus
            required
            value={emailAddress}
            onChange={event => setEmailAddress(event.target.value)}
          />
        </div>

        <Button type="submit" className="w-full" size="lg" disabled={loading}>
          {loading ? "Sending reset link..." : "Send reset link"}
        </Button>
      </form>
    </AuthShell>
  );
}
