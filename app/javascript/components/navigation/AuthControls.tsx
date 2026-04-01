import { visit } from "@hotwired/turbo";
import { Button } from "@/components/ui/button";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";

type AuthControlsProps = {
  authenticated: boolean;
  developer_sign_in_enabled: boolean;
  developer_sign_in_path: string;
  home_path: string;
  logout_path: string;
};

export default function AuthControls({
  authenticated,
  developer_sign_in_enabled,
  developer_sign_in_path,
  home_path,
  logout_path,
}: AuthControlsProps) {
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

  if (!authenticated && !developer_sign_in_enabled) {
    return null;
  }

  const signOut = async () => {
    await makeRequest("DELETE", logout_path);
  };

  const developerSignIn = async () => {
    await makeRequest("POST", developer_sign_in_path, {});
  };

  return (
    <div className="pointer-events-none fixed right-4 top-4 z-50">
      <div className="pointer-events-auto rounded-full border border-border/70 bg-background/88 p-1 shadow-[0_12px_30px_rgba(26,41,46,0.14)] backdrop-blur">
        {authenticated ? (
          <Button
            type="button"
            variant="ghost"
            className="rounded-full px-3"
            onClick={signOut}
            disabled={loading}
          >
            {loading ? "Logging out..." : "Logout"}
          </Button>
        ) : developer_sign_in_enabled ? (
          <Button
            type="button"
            variant="ghost"
            className="rounded-full px-3"
            onClick={developerSignIn}
            disabled={loading}
          >
            {loading ? "Signing in..." : "Developer Sign In"}
          </Button>
        ) : null}
      </div>
    </div>
  );
}
