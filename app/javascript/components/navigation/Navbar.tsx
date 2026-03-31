import { visit } from "@hotwired/turbo";
import { Button } from "@/components/ui/button";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";

type NavbarProps = {
  app_name: string;
  authenticated: boolean;
  current_user_email?: string | null;
  home_path: string;
  sign_in_path: string;
  sign_up_path: string;
  developer_sign_in_path: string;
  developer_sign_in_enabled: boolean;
  logout_path: string;
};

export default function Navbar({
  app_name,
  authenticated,
  current_user_email,
  home_path,
  sign_in_path,
  sign_up_path,
  developer_sign_in_path,
  developer_sign_in_enabled,
  logout_path,
}: NavbarProps) {
  const toast = useToast();
  const { loading, makeRequest } = useApiRequest<{ redirect_to: string; message?: string }>({
    onSuccess: payload => {
      if (payload?.message) {
        toast.success(payload.message);
      }

      visit(payload?.redirect_to ?? sign_in_path);
    },
    onError: message => {
      toast.error(message);
    },
  });

  const signOut = async () => {
    await makeRequest("DELETE", logout_path);
  };

  const developerSignIn = async () => {
    await makeRequest("POST", developer_sign_in_path, {});
  };

  return (
    <header className="sticky top-0 z-40 border-b border-border/70 bg-background/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8">
        <a
          href={home_path}
          className="text-sm font-semibold uppercase tracking-[0.28em] text-foreground"
        >
          {app_name}
        </a>

        <div className="flex items-center gap-3">
          {authenticated ? (
            <>
              {current_user_email ? (
                <span className="hidden text-sm text-muted-foreground sm:inline">
                  {current_user_email}
                </span>
              ) : null}
              <Button type="button" onClick={signOut} disabled={loading}>
                {loading ? "Logging out..." : "Logout"}
              </Button>
            </>
          ) : (
            <>
              {developer_sign_in_enabled ? (
                <Button
                  type="button"
                  variant="secondary"
                  onClick={developerSignIn}
                  disabled={loading}
                >
                  {loading ? "Signing in..." : "Developer Sign In"}
                </Button>
              ) : null}
              <Button type="button" variant="ghost" asChild>
                <a href={sign_in_path}>Sign in</a>
              </Button>
              <Button type="button" asChild>
                <a href={sign_up_path}>Sign up</a>
              </Button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
