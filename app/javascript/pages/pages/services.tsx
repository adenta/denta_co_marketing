export default function ServicesPage() {
  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[radial-gradient(circle_at_top_left,rgba(15,23,42,0.12),transparent_28%),radial-gradient(circle_at_86%_16%,rgba(21,94,99,0.16),transparent_25%),linear-gradient(180deg,rgba(245,248,251,1),rgba(232,239,244,0.96))] dark:bg-[radial-gradient(circle_at_top_left,rgba(51,65,85,0.22),transparent_28%),radial-gradient(circle_at_86%_16%,rgba(103,199,208,0.14),transparent_25%),linear-gradient(180deg,rgba(11,17,22,1),rgba(12,18,24,0.98))]" />
      <div className="mx-auto max-w-4xl px-4 py-14 sm:px-6 sm:py-18 lg:px-8">
        <section className="rounded-[2rem] border border-[#0f172a]/10 bg-white/88 p-8 shadow-[0_28px_64px_rgba(15,23,42,0.08)] backdrop-blur dark:border-white/8 dark:bg-[#131a21]/88 dark:shadow-[0_24px_64px_rgba(0,0,0,0.32)]">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-[#155e63] dark:text-[#67c7d0]">
            Services
          </p>
          <h1 className="mt-4 text-[clamp(2.3rem,6vw,4.2rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-[#0f172a] dark:text-[#eef2f6]">
            The offer page is now a placeholder instead of a pretend finalized pitch.
          </h1>
          <p className="mt-4 max-w-3xl text-[1rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
            Keep this route if you want a future services page, but rebuild the actual engagement structure from first principles when the positioning is ready.
          </p>
        </section>
      </div>
    </section>
  );
}
