export function getCsrfToken(): string | undefined {
  return (
    document.querySelector('meta[name="csrf-token"]')?.getAttribute("content") ??
    undefined
  );
}
