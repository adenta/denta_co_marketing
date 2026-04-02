import { visit } from "@hotwired/turbo";
import { Moon, Sun } from "lucide-react";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { useApiRequest } from "@/hooks/useApiRequest";
import {
  applyTheme,
  getStoredThemePreference,
  persistThemePreference,
  resolveTheme,
  subscribeToSystemThemeChange,
  type ThemePreference,
} from "@/lib/theme";
import { useToast } from "@/hooks/useToast";

type AuthControlsProps = {
  authenticated: boolean;
  analytics_path: string;
  developer_sign_in_enabled: boolean;
  developer_sign_in_path: string;
  home_path: string;
  logout_path: string;
};

export default function AuthControls({
  authenticated,
  analytics_path,
  developer_sign_in_enabled,
  developer_sign_in_path,
  home_path,
  logout_path,
}: AuthControlsProps) {
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

      visit(payload?.redirect_to ?? home_path);
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

  if (!authenticated && !developer_sign_in_enabled) {
    return null;
  }

  const signOut = async () => {
    await makeRequest("DELETE", logout_path);
  };

  const developerSignIn = async () => {
    await makeRequest("POST", developer_sign_in_path, {});
  };

  const nextTheme = resolvedTheme === "dark" ? "light" : "dark";
  const themeToggleLabel =
    resolvedTheme === "dark" ? "Switch to light mode" : "Switch to dark mode";

  return (
    <div className="pointer-events-none fixed right-4 top-4 z-50">
      <div className="pointer-events-auto flex items-center gap-1 rounded-xl border border-border/80 bg-background/88 p-1 shadow-[0_12px_30px_rgba(15,23,42,0.12)] backdrop-blur dark:shadow-[0_16px_42px_rgba(0,0,0,0.42)]">
        {authenticated ? (
          <div className="flex items-center gap-1">
            <Button asChild type="button" variant="ghost" className="rounded-lg px-2.5">
              <a href={analytics_path}>Analytics</a>
            </Button>
            <Button
              type="button"
              variant="ghost"
              className="rounded-lg px-2.5"
              onClick={signOut}
              disabled={loading}
            >
              {loading ? "Logging out..." : "Logout"}
            </Button>
          </div>
        ) : developer_sign_in_enabled ? (
          <Button
            type="button"
            variant="ghost"
            className="rounded-lg px-2.5"
            onClick={developerSignIn}
            disabled={loading}
          >
            {loading ? "Signing in..." : "Developer Sign In"}
          </Button>
        ) : null}
        <Button
          type="button"
          variant="ghost"
          size="icon-sm"
          className="rounded-lg"
          aria-label={themeToggleLabel}
          title={themeToggleLabel}
          onClick={() => setThemePreference(nextTheme)}
        >
          {resolvedTheme === "dark" ? <Sun /> : <Moon />}
        </Button>
      </div>
    </div>
  );
}
