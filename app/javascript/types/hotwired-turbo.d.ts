declare module "@hotwired/turbo" {
  export function visit(
    location: string | URL,
    options?: Record<string, unknown>,
  ): void;
}
