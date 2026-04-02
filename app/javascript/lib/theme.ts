export const THEME_STORAGE_KEY = "denta-theme";

export type ThemePreference = "light" | "dark";

const DARK_MODE_MEDIA_QUERY = "(prefers-color-scheme: dark)";

export function getStoredThemePreference(): ThemePreference | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    const storedPreference = window.localStorage.getItem(THEME_STORAGE_KEY);

    return storedPreference === "light" || storedPreference === "dark"
      ? storedPreference
      : null;
  } catch {
    return null;
  }
}

export function resolveTheme(preference: ThemePreference | null): ThemePreference {
  if (preference) {
    return preference;
  }

  if (typeof window !== "undefined" && typeof window.matchMedia === "function") {
    return window.matchMedia(DARK_MODE_MEDIA_QUERY).matches ? "dark" : "light";
  }

  return "light";
}

export function applyTheme(preference: ThemePreference | null): ThemePreference {
  const resolvedTheme = resolveTheme(preference);

  if (typeof document === "undefined") {
    return resolvedTheme;
  }

  const root = document.documentElement;
  const darkModeEnabled = resolvedTheme === "dark";

  root.classList.toggle("dark", darkModeEnabled);
  root.dataset.theme = resolvedTheme;
  root.style.colorScheme = resolvedTheme;

  return resolvedTheme;
}

export function persistThemePreference(preference: ThemePreference | null) {
  if (typeof window === "undefined") {
    return;
  }

  try {
    if (preference) {
      window.localStorage.setItem(THEME_STORAGE_KEY, preference);
    } else {
      window.localStorage.removeItem(THEME_STORAGE_KEY);
    }
  } catch {
    // Ignore storage failures so theme changes still apply for the session.
  }
}

export function subscribeToSystemThemeChange(
  onThemeChange: (resolvedTheme: ThemePreference) => void,
) {
  if (typeof window === "undefined" || typeof window.matchMedia !== "function") {
    return () => {};
  }

  const mediaQuery = window.matchMedia(DARK_MODE_MEDIA_QUERY);
  const handleChange = (event: MediaQueryListEvent) => {
    onThemeChange(event.matches ? "dark" : "light");
  };

  mediaQuery.addEventListener("change", handleChange);

  return () => {
    mediaQuery.removeEventListener("change", handleChange);
  };
}
