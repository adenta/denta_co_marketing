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
  children: ReactNode;
  footer?: ReactNode;
};

export function AuthShell({
  eyebrow,
  title,
  description,
  children,
  footer,
}: AuthShellProps) {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background px-4 py-10 sm:py-16">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(15,23,42,0.08),_transparent_42%),linear-gradient(180deg,_rgba(15,23,42,0.04),_transparent_55%)]" />
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-foreground/20 to-transparent" />

      <div className="relative mx-auto flex min-h-[calc(100vh-5rem)] max-w-5xl items-center justify-center">
        <div className="grid w-full gap-8 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <section className="hidden space-y-6 lg:block">
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-muted-foreground">
              denta_co_marketing
            </p>
            <div className="space-y-4">
              <h1 className="max-w-xl text-4xl font-semibold tracking-tight text-foreground">
                A clean Rails and React starting point for authenticated product flows.
              </h1>
              <p className="max-w-lg text-base leading-7 text-muted-foreground">
                Pages stay client-rendered, submissions stay native, and redirect-based
                flash lands in a single global toaster that is easy to carry forward.
              </p>
            </div>
          </section>

          <Card className="border border-foreground/10 bg-card/95 py-0 shadow-2xl shadow-foreground/5">
            <CardHeader className="border-b bg-muted/40 py-6">
              <p className="text-xs font-semibold uppercase tracking-[0.22em] text-muted-foreground">
                {eyebrow}
              </p>
              <CardTitle className="text-2xl">{title}</CardTitle>
              <CardDescription className="text-sm leading-6">
                {description}
              </CardDescription>
            </CardHeader>

            <CardContent className="space-y-6 py-6">
              {children}
              {footer ? (
                <div className="border-t pt-4 text-sm text-muted-foreground">{footer}</div>
              ) : null}
            </CardContent>
          </Card>
        </div>
      </div>
    </main>
  );
}
