import type { ReactNode } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

type AuthShellProps = {
  eyebrow: string;
  title: string;
  description: string;
  marketing: {
    eyebrow: string;
    title: string;
    description: string;
  };
  children: ReactNode;
  footer?: ReactNode;
};

export function AuthShell({
  eyebrow,
  title,
  description,
  marketing,
  children,
  footer,
}: AuthShellProps) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background px-4 py-8 sm:py-12">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(15,23,42,0.09),_transparent_42%),linear-gradient(180deg,_rgba(15,23,42,0.05),_transparent_55%)] dark:bg-[radial-gradient(circle_at_top,_rgba(71,85,105,0.22),_transparent_38%),linear-gradient(180deg,_rgba(15,23,42,0.22),_transparent_60%)]" />
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-foreground/20 to-transparent" />

      <div className="relative mx-auto flex min-h-[calc(100vh-5rem)] max-w-5xl items-center justify-center">
        <div className="grid w-full gap-6 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <section className="hidden space-y-5 lg:block">
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">
              {marketing.eyebrow}
            </p>
            <div className="space-y-3">
              <h1 className="max-w-xl text-4xl font-semibold tracking-tight text-foreground">
                {marketing.title}
              </h1>
              <p className="max-w-lg text-[0.97rem] leading-7 text-muted-foreground">
                {marketing.description}
              </p>
            </div>
          </section>

          <Card className="border border-foreground/10 bg-card/95 py-0 shadow-[0_22px_60px_rgba(15,23,42,0.08)] dark:shadow-[0_22px_60px_rgba(0,0,0,0.34)]">
            <CardHeader className="border-b bg-muted/35 py-5">
              <p className="text-xs font-semibold uppercase tracking-[0.22em] text-muted-foreground">
                {eyebrow}
              </p>
              <CardTitle className="text-2xl">{title}</CardTitle>
              <CardDescription className="text-sm leading-6">
                {description}
              </CardDescription>
            </CardHeader>

            <CardContent className="space-y-5 py-5">
              {children}
              {footer ? (
                <div className="border-t pt-3 text-sm text-muted-foreground">{footer}</div>
              ) : null}
            </CardContent>
          </Card>
        </div>
      </div>
    </main>
  );
}
