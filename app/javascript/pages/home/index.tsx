export default function HomeIndex() {
  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[linear-gradient(180deg,rgba(17,24,39,0.04),transparent_38%),radial-gradient(circle_at_top_left,rgba(14,165,233,0.18),transparent_32%),radial-gradient(circle_at_80%_20%,rgba(249,115,22,0.14),transparent_28%)]" />
      <div className="absolute inset-x-0 top-0 -z-10 h-px bg-gradient-to-r from-transparent via-foreground/20 to-transparent" />

      <div className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-6xl items-center px-6 py-16 sm:px-8 lg:px-12">
        <div className="grid gap-10 lg:grid-cols-[1.2fr_0.8fr] lg:items-end">
          <div className="space-y-8">
            <p className="text-xs font-semibold uppercase tracking-[0.36em] text-muted-foreground">
              Denta Co Marketing
            </p>
            <div className="space-y-4">
              <h1 className="max-w-3xl text-5xl font-semibold tracking-tight text-foreground sm:text-6xl">
                Dental growth systems, refined behind the scenes.
              </h1>
              <p className="max-w-2xl text-lg leading-8 text-muted-foreground">
                This workspace is currently a private operating surface for campaign
                development, messaging, and internal tooling. The public-facing splash
                page will evolve from here.
              </p>
            </div>
          </div>

          <div className="rounded-[2rem] border border-border/70 bg-card/85 p-8 shadow-2xl shadow-foreground/5 backdrop-blur">
            <p className="text-sm font-medium uppercase tracking-[0.24em] text-muted-foreground">
              Current status
            </p>
            <div className="mt-6 space-y-4">
              <p className="text-2xl font-semibold tracking-tight text-foreground">
                Private preview
              </p>
              <p className="text-sm leading-7 text-muted-foreground">
                Authentication remains available by direct sign-in for the owner, while
                account creation and password reset are intentionally disabled.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
