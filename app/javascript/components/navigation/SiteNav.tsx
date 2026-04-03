import { visit } from "@hotwired/turbo";
import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { ButtonGroup, ButtonGroupSeparator } from "@/components/ui/button-group";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import {
  applyTheme,
  getStoredThemePreference,
  persistThemePreference,
  resolveTheme,
  subscribeToSystemThemeChange,
  type ThemePreference,
} from "@/lib/theme";

type NavItem = {
  key: string;
  label: string;
  href: string;
};

type SiteNavProps = {
  currentKey?: string;
  items: NavItem[];
  authenticated: boolean;
  analyticsPath: string;
  developerSignInEnabled: boolean;
  developerSignInPath: string;
  homePath: string;
  logoutPath: string;
};

export default function SiteNav({
  currentKey,
  items,
  authenticated,
  analyticsPath,
  developerSignInEnabled,
  developerSignInPath,
  homePath,
  logoutPath,
}: SiteNavProps) {
  const [themePreference, setThemePreference] = useState<ThemePreference | null>(() =>
    getStoredThemePreference(),
  );
  const [resolvedTheme, setResolvedTheme] = useState<ThemePreference>(() =>
    resolveTheme(getStoredThemePreference()),
  );
  const toast = useToast();
  const { loading, makeRequest } = useApiRequest<{ redirect_to: string; message?: string }>({
    onSuccess: payload => {
      if (payload?.message) {
        toast.success(payload.message);
      }

      visit(payload?.redirect_to ?? homePath);
    },
    onError: message => {
      toast.error(message);
    },
  });

  useEffect(() => {
    persistThemePreference(themePreference);
    setResolvedTheme(applyTheme(themePreference));
  }, [themePreference]);

  useEffect(() => {
    if (themePreference !== null) {
      return;
    }

    return subscribeToSystemThemeChange(() => {
      setResolvedTheme(applyTheme(null));
    });
  }, [themePreference]);

  const hasAuthActions = authenticated || developerSignInEnabled;
  const nextTheme = resolvedTheme === "dark" ? "light" : "dark";
  const themeToggleLabel =
    resolvedTheme === "dark" ? "Switch to light mode" : "Switch to dark mode";

  const signOut = async () => {
    await makeRequest("DELETE", logoutPath);
  };

  const developerSignIn = async () => {
    await makeRequest("POST", developerSignInPath, {});
  };

  return (
    <header className="sticky top-0 z-40 border-b border-[#0f172a]/8 bg-[rgba(244,247,250,0.82)] backdrop-blur dark:border-white/8 dark:bg-[rgba(11,17,22,0.82)]">
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
          <Button asChild variant="ghost" className="w-fit rounded-full px-0 text-sm font-semibold tracking-[0.22em] text-[#155e63] uppercase hover:bg-transparent hover:text-[#0f172a] dark:text-[#67c7d0] dark:hover:bg-transparent dark:hover:text-[#eef2f6]">
            <a href="/">Andrew Denta</a>
          </Button>
          <nav aria-label="Site" className="flex flex-wrap items-center gap-1.5">
          {items.map(item => {
            const active = currentKey === item.key;

            return (
              <Button
                key={item.key}
                asChild
                variant={active ? "default" : "ghost"}
                size="sm"
                className={active ? "rounded-full" : "rounded-full text-[#425466] hover:bg-white dark:text-[#9eabb8] dark:hover:bg-[#131a21]"}
              >
                <a href={item.href} aria-current={active ? "page" : undefined}>
                  {item.label}
                </a>
              </Button>
            );
          })}
        </nav>
        </div>

        <ButtonGroup className="w-fit self-end rounded-xl border border-border/80 bg-background/88 p-1 shadow-[0_12px_30px_rgba(15,23,42,0.12)] backdrop-blur dark:shadow-[0_16px_42px_rgba(0,0,0,0.42)]">
          {authenticated ? (
            <>
              <Button asChild type="button" variant="ghost" size="sm">
                <a href={analyticsPath}>Analytics</a>
              </Button>
              <Button type="button" variant="ghost" size="sm" onClick={signOut} disabled={loading}>
                {loading ? "Logging out..." : "Logout"}
              </Button>
            </>
          ) : developerSignInEnabled ? (
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={developerSignIn}
              disabled={loading}
            >
              {loading ? "Signing in..." : "Developer Sign In"}
            </Button>
          ) : null}
          {hasAuthActions ? <ButtonGroupSeparator /> : null}
          <Button
            type="button"
            variant="ghost"
            size="icon-sm"
            aria-label={themeToggleLabel}
            title={themeToggleLabel}
            onClick={() => setThemePreference(nextTheme)}
          >
            {resolvedTheme === "dark" ? <Sun /> : <Moon />}
          </Button>
        </ButtonGroup>
      </div>
    </header>
  );
}
