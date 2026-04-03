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
    <header className="sticky top-0 z-40 border-b bg-background">
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
          <Button
            asChild
            variant="ghost"
            className="w-fit px-0 text-sm font-semibold text-muted-foreground hover:bg-transparent hover:text-foreground"
          >
            <a href="/">Andrew Denta</a>
          </Button>
          <nav aria-label="Site" className="flex flex-wrap items-center gap-1.5">
            {items.map(item => {
              const active = currentKey === item.key;

              return (
                <Button key={item.key} asChild variant={active ? "default" : "ghost"} size="sm">
                  <a href={item.href} aria-current={active ? "page" : undefined}>
                    {item.label}
                  </a>
                </Button>
              );
            })}
          </nav>
        </div>

        <ButtonGroup className="w-fit self-end">
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
