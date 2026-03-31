import { useCallback } from "react";
import type { ToastEventDetail, ToastType } from "@/types/toast";

export function useToast() {
  const addToast = useCallback(
    (message: string, type: ToastType = "info", duration?: number) => {
      const detail: ToastEventDetail = { message, type };

      if (duration !== undefined) {
        detail.duration = duration;
      }

      window.dispatchEvent(new CustomEvent("toast:add", { detail }));
    },
    [],
  );

  const success = useCallback(
    (message: string, duration?: number) => addToast(message, "success", duration),
    [addToast],
  );

  const error = useCallback(
    (message: string, duration?: number) => addToast(message, "error", duration),
    [addToast],
  );

  const warning = useCallback(
    (message: string, duration?: number) => addToast(message, "warning", duration),
    [addToast],
  );

  const info = useCallback(
    (message: string, duration?: number) => addToast(message, "info", duration),
    [addToast],
  );

  return {
    addToast,
    success,
    error,
    warning,
    info,
  };
}
