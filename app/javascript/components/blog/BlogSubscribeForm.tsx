import { FormEvent, useId, useRef, useState } from "react";
import { Turnstile, type TurnstileInstance } from "@marsidev/react-turnstile";
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
  subscribedTitle: string;
  subscribedDescription: string;
  resetLabel: string;
  turnstileSiteKey?: string;
  verificationRequiredMessage: string;
  unavailableMessage: string;
};

function interpolateSubmittedEmail(template: string, emailAddress: string) {
  return template.replace("%{email_address}", emailAddress);
}

export default function BlogSubscribeForm({
  createPath,
  title,
  description,
  emailLabel,
  emailPlaceholder,
  submitLabel,
  successMessage,
  subscribedTitle,
  subscribedDescription,
  resetLabel,
  turnstileSiteKey,
  verificationRequiredMessage,
  unavailableMessage,
}: BlogSubscribeFormProps) {
  const emailId = useId();
  const toast = useToast();
  const turnstileRef = useRef<TurnstileInstance | null>(null);
  const [emailAddress, setEmailAddress] = useState("");
  const [submittedEmailAddress, setSubmittedEmailAddress] = useState("");
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [turnstileToken, setTurnstileToken] = useState("");
  const [turnstileReady, setTurnstileReady] = useState(Boolean(!turnstileSiteKey));
  const [turnstileUnavailable, setTurnstileUnavailable] = useState(false);
  const { loading, getBaseErrors, getFieldError, clearErrors, makeRequest } =
    useApiRequest<{ message?: string }>({
      onSuccess: payload => {
        toast.success(payload?.message ?? successMessage ?? "");
        setSubmittedEmailAddress(emailAddress);
        setIsSubscribed(true);
        setTurnstileToken("");
        setTurnstileReady(false);

        turnstileRef.current?.reset();
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

    if (!turnstileToken) {
      toast.error(verificationRequiredMessage);
      return;
    }

    await makeRequest("POST", createPath, {
      email_address: emailAddress,
      turnstile_token: turnstileToken,
    });
  };

  const resetForm = () => {
    clearErrors();
    setEmailAddress("");
    setSubmittedEmailAddress("");
    setIsSubscribed(false);
    setTurnstileToken("");
    setTurnstileReady(Boolean(!turnstileSiteKey));
    setTurnstileUnavailable(false);
    turnstileRef.current?.reset();
  };

  return (
    <section className="rounded-[1.3rem] border border-border/80 bg-card/92 p-5 shadow-[0_18px_48px_rgba(15,23,42,0.07)] dark:shadow-[0_20px_52px_rgba(0,0,0,0.32)]">
      <div className="space-y-1.5">
        <h2 className="text-2xl font-semibold tracking-tight text-foreground">
          {isSubscribed ? subscribedTitle : title}
        </h2>
        <p className="max-w-2xl text-[0.97rem] leading-7 text-muted-foreground">
          {isSubscribed
            ? interpolateSubmittedEmail(subscribedDescription, submittedEmailAddress)
            : description}
        </p>
      </div>

      {isSubscribed ? (
        <Button className="mt-4 px-0" type="button" variant="link" onClick={resetForm}>
          {resetLabel}
        </Button>
      ) : (
        <form className="mt-4 space-y-4" onSubmit={onSubmit}>
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
              className="bg-background/78"
            />
            {getFieldError("email_address") ? (
              <p className="text-sm text-destructive">{getFieldError("email_address")}</p>
            ) : null}
          </div>

          <div className="space-y-2">
            {turnstileSiteKey ? (
              <Turnstile
                ref={turnstileRef}
                siteKey={turnstileSiteKey}
                options={{
                  appearance: "interaction-only",
                  size: "flexible",
                }}
                onWidgetLoad={() => {
                  setTurnstileReady(true);
                  setTurnstileUnavailable(false);
                }}
                onSuccess={token => {
                  setTurnstileToken(token);
                  setTurnstileReady(true);
                  setTurnstileUnavailable(false);
                }}
                onExpire={() => {
                  setTurnstileToken("");
                  setTurnstileReady(false);
                }}
                onError={() => {
                  setTurnstileToken("");
                  setTurnstileReady(false);
                  setTurnstileUnavailable(true);
                }}
                scriptOptions={{
                  async: true,
                  defer: true,
                }}
              />
            ) : null}
            {!turnstileSiteKey || turnstileUnavailable ? (
              <p className="text-sm text-muted-foreground">{unavailableMessage}</p>
            ) : null}
          </div>

          <Button
            type="submit"
            size="lg"
            className="h-9 rounded-lg px-4"
            disabled={loading || !turnstileSiteKey || turnstileUnavailable || !turnstileToken || !turnstileReady}
          >
            {submitLabel}
          </Button>
        </form>
      )}
    </section>
  );
}
