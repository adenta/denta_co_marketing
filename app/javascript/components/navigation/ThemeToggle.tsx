import { useEffect, useState } from "react";
import { Moon, Sun } from "lucide-react";
import {
  applyTheme,
  getStoredThemePreference,
  persistThemePreference,
  resolveTheme,
  subscribeToSystemThemeChange,
  type ThemePreference,
} from "@/lib/theme";

export default function ThemeToggle() {
  const [themePreference, setThemePreference] = useState<ThemePreference | null>(() =>
    getStoredThemePreference(),
  );
  const [resolvedTheme, setResolvedTheme] = useState<ThemePreference>(() =>
    resolveTheme(getStoredThemePreference()),
  );

  useEffect(() => {
    persistThemePreference(themePreference);
    setResolvedTheme(applyTheme(themePreference));
  }, [themePreference]);

  useEffect(() => {
    if (themePreference !== null) {
      return;
    }

    return subscribeToSystemThemeChange(nextResolvedTheme => {
      setResolvedTheme(nextResolvedTheme);
      applyTheme(null);
    });
  }, [themePreference]);

  const nextTheme = resolvedTheme === "dark" ? "light" : "dark";
  const themeToggleLabel =
    resolvedTheme === "dark" ? "Switch to light mode" : "Switch to dark mode";

  return (
    <button
      type="button"
      aria-label={themeToggleLabel}
      title={themeToggleLabel}
      onClick={() => setThemePreference(nextTheme)}
      className="inline-flex size-5 items-center justify-center text-muted-foreground transition-colors hover:text-primary"
    >
      {resolvedTheme === "dark" ? <Sun className="size-4" /> : <Moon className="size-4" />}
    </button>
  );
}
