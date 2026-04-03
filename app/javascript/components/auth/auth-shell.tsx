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
    <main className="min-h-screen bg-background px-4 py-8 sm:py-12">
      <div className="mx-auto flex min-h-[calc(100vh-5rem)] max-w-xl items-center justify-center">
        <div className="w-full">
          <Card>
            <CardHeader>
              <p className="text-xs font-semibold uppercase tracking-[0.22em] text-muted-foreground">
                {eyebrow}
              </p>
              <CardTitle className="text-2xl">{title}</CardTitle>
              <CardDescription className="text-sm leading-6">
                {description}
              </CardDescription>
            </CardHeader>

            <CardContent className="space-y-5">
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
