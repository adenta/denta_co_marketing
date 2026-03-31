import { useEffect, useMemo, useRef, useState } from "react";
import { CircleAlert, CircleCheckBig, Info, TriangleAlert, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import type { Toast, ToastEventDetail, ToastType } from "@/types/toast";

type ToastContainerProps = Record<string, string | undefined>;

const DEFAULT_DURATION = 6000;

function createToastId(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

function getToastType(flashKey: string): ToastType {
  switch (flashKey) {
    case "notice":
    case "success":
      return "success";
    case "alert":
    case "error":
      return "error";
    case "warning":
      return "warning";
    default:
      return "info";
  }
}

function getToastStyles(type: ToastType) {
  switch (type) {
    case "success":
      return {
        icon: CircleCheckBig,
        className:
          "border-emerald-500/25 bg-emerald-500/10 text-emerald-950 dark:text-emerald-50",
        iconClassName: "text-emerald-600 dark:text-emerald-300",
      };
    case "error":
      return {
        icon: CircleAlert,
        className:
          "border-destructive/25 bg-destructive/10 text-rose-950 dark:text-rose-50",
        iconClassName: "text-destructive",
      };
    case "warning":
      return {
        icon: TriangleAlert,
        className:
          "border-amber-500/25 bg-amber-500/10 text-amber-950 dark:text-amber-50",
        iconClassName: "text-amber-600 dark:text-amber-300",
      };
    case "info":
    default:
      return {
        icon: Info,
        className:
          "border-sky-500/25 bg-sky-500/10 text-sky-950 dark:text-sky-50",
        iconClassName: "text-sky-600 dark:text-sky-300",
      };
  }
}

export default function ToastContainer(props: ToastContainerProps) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const lastFlashSignature = useRef<string | null>(null);
  const flashSignature = useMemo(() => JSON.stringify(props), [props]);

  const flashToasts = useMemo(
    () =>
      Object.entries(props).flatMap(([key, message]) => {
        if (!message) {
          return [];
        }

        return [
          {
            id: createToastId(`flash-${key}`),
            message,
            type: getToastType(key),
            duration: DEFAULT_DURATION,
          } satisfies Toast,
        ];
      }),
    [props],
  );

  useEffect(() => {
    if (flashToasts.length === 0 || flashSignature === lastFlashSignature.current) {
      return;
    }

    lastFlashSignature.current = flashSignature;
    setToasts(prev => [...prev, ...flashToasts]);
  }, [flashSignature, flashToasts]);

  useEffect(() => {
    const handleToastAdd = ({ detail }: CustomEvent<ToastEventDetail>) => {
      setToasts(prev => [
        ...prev,
        {
          id: createToastId("toast"),
          message: detail.message,
          type: detail.type,
          duration: detail.duration ?? DEFAULT_DURATION,
        },
      ]);
    };

    window.addEventListener("toast:add", handleToastAdd as EventListener);
    return () =>
      window.removeEventListener("toast:add", handleToastAdd as EventListener);
  }, []);

  useEffect(() => {
    if (toasts.length === 0) {
      return;
    }

    const timers = toasts.map(toast =>
      window.setTimeout(() => {
        setToasts(current => current.filter(item => item.id !== toast.id));
      }, toast.duration ?? DEFAULT_DURATION),
    );

    return () => {
      timers.forEach(window.clearTimeout);
    };
  }, [toasts]);

  if (toasts.length === 0) {
    return null;
  }

  return (
    <div className="pointer-events-none fixed inset-x-0 top-4 z-50 px-4">
      <div className="mx-auto flex w-full max-w-md flex-col gap-3">
        {toasts.map(toast => {
          const styles = getToastStyles(toast.type);
          const Icon = styles.icon;

          return (
            <Card
              key={toast.id}
              role="status"
              aria-live="polite"
              className={cn(
                "pointer-events-auto gap-0 rounded-2xl border px-4 py-3 shadow-lg shadow-foreground/5 backdrop-blur",
                styles.className,
              )}
            >
              <div className="flex items-start gap-3">
                <Icon className={cn("mt-0.5 size-4 shrink-0", styles.iconClassName)} />
                <div className="min-w-0 flex-1 text-sm leading-6">{toast.message}</div>
                <Button
                  type="button"
                  variant="ghost"
                  size="icon-sm"
                  className="size-7 shrink-0 rounded-full"
                  aria-label="Dismiss notification"
                  onClick={() =>
                    setToasts(current => current.filter(item => item.id !== toast.id))
                  }
                >
                  <X className="size-4" />
                </Button>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
