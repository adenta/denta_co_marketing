export type ToastType = "info" | "success" | "warning" | "error";

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  duration?: number;
}

export interface ToastEventDetail {
  message: string;
  type: ToastType;
  duration?: number;
}

declare global {
  interface WindowEventMap {
    "toast:add": CustomEvent<ToastEventDetail>;
  }
}
