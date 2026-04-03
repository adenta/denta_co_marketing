type ServiceOffer = {
  name: string;
  tagline: string;
  summary: string;
  cadence: string;
  featured?: boolean;
  what_you_get: string[];
  best_fit: string[];
};

type ServicesContent = {
  hero: {
    eyebrow: string;
    title: string;
    body: string;
  };
  offers: ServiceOffer[];
  proof_strip: {
    title: string;
    items: string[];
  };
  cta: {
    title: string;
    body: string;
    label: string;
    href: string;
  };
};

type ServicesPageProps = {
  content: ServicesContent;
};

function OfferCard({ offer }: { offer: ServiceOffer }) {
  return (
    <article
      className={[
        "relative rounded-[2rem] p-6 shadow-[0_24px_56px_rgba(15,23,42,0.08)]",
        offer.featured
          ? "border-2 border-[#155e63] bg-[linear-gradient(180deg,rgba(255,255,255,0.98),rgba(241,247,249,0.95))] dark:border-[#67c7d0] dark:bg-[linear-gradient(180deg,rgba(19,26,33,0.98),rgba(15,22,29,0.94))]"
          : "border border-[#0f172a]/10 bg-white/96 dark:border-white/8 dark:bg-[#131a21]/94",
      ].join(" ")}
    >
      {offer.featured ? (
        <div className="absolute -top-3 left-6 rounded-full bg-[#155e63] px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-white dark:bg-[#67c7d0] dark:text-[#071116]">
          Recommended
        </div>
      ) : null}
      <p className="text-sm font-semibold uppercase tracking-[0.26em] text-[#155e63] dark:text-[#67c7d0]">
        {offer.tagline}
      </p>
      <h2 className="mt-3 text-2xl font-semibold tracking-[-0.03em] text-[#0f172a] dark:text-[#eef2f6]">
        {offer.name}
      </h2>
      <p className="mt-3 text-sm leading-7 text-[#425466] dark:text-[#9eabb8]">{offer.summary}</p>
      <p className="mt-4 text-sm font-medium text-[#0f172a] dark:text-[#dfe7ee]">{offer.cadence}</p>

      <div className="mt-6 grid gap-5 lg:grid-cols-1">
        <section>
          <h3 className="text-sm font-semibold uppercase tracking-[0.2em] text-[#0f172a] dark:text-[#eef2f6]">
            How it works
          </h3>
          <ul className="mt-3 space-y-2.5">
            {offer.what_you_get.map(item => (
              <li key={item} className="flex gap-2 text-sm leading-6 text-[#425466] dark:text-[#9eabb8]">
                <span className="mt-1 text-[#155e63] dark:text-[#67c7d0]">→</span>
                <span>{item}</span>
              </li>
            ))}
          </ul>
        </section>

        <section>
          <h3 className="text-sm font-semibold uppercase tracking-[0.2em] text-[#0f172a] dark:text-[#eef2f6]">
            Best fit
          </h3>
          <ul className="mt-3 space-y-2.5">
            {offer.best_fit.map(item => (
              <li key={item} className="flex gap-2 text-sm leading-6 text-[#425466] dark:text-[#9eabb8]">
                <span className="mt-1 text-[#155e63] dark:text-[#67c7d0]">→</span>
                <span>{item}</span>
              </li>
            ))}
          </ul>
        </section>
      </div>
    </article>
  );
}

export default function ServicesPage({ content }: ServicesPageProps) {
  const { hero, offers, proof_strip, cta } = content;

  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[radial-gradient(circle_at_top_left,rgba(15,23,42,0.12),transparent_28%),radial-gradient(circle_at_86%_16%,rgba(21,94,99,0.16),transparent_25%),linear-gradient(180deg,rgba(245,248,251,1),rgba(232,239,244,0.96))] dark:bg-[radial-gradient(circle_at_top_left,rgba(51,65,85,0.22),transparent_28%),radial-gradient(circle_at_86%_16%,rgba(103,199,208,0.14),transparent_25%),linear-gradient(180deg,rgba(11,17,22,1),rgba(12,18,24,0.98))]" />
      <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6 sm:py-18 lg:px-8">
        <section className="mx-auto max-w-3xl text-center">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-[#155e63] dark:text-[#67c7d0]">
            {hero.eyebrow}
          </p>
          <h1 className="mt-4 text-[clamp(2.3rem,6vw,4.3rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-[#0f172a] dark:text-[#eef2f6]">
            {hero.title}
          </h1>
          <p className="mt-4 text-[1.02rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
            {hero.body}
          </p>
        </section>

        <div className="mt-10 grid gap-6 lg:grid-cols-3">
          {offers.map(offer => (
            <OfferCard key={offer.name} offer={offer} />
          ))}
        </div>

        <section className="mt-10 rounded-[2rem] bg-[linear-gradient(180deg,rgba(15,23,42,0.95),rgba(30,41,59,0.98))] p-7 text-white shadow-[0_28px_70px_rgba(15,23,42,0.22)] dark:bg-[linear-gradient(180deg,rgba(19,26,33,0.96),rgba(15,22,29,0.98))]">
          <h2 className="text-center text-2xl font-semibold tracking-[-0.03em]">{proof_strip.title}</h2>
          <div className="mt-6 grid gap-4 md:grid-cols-3">
            {proof_strip.items.map(item => (
              <div
                key={item}
                className="rounded-[1.4rem] border border-white/10 bg-white/6 p-4 text-sm leading-7 text-[#dbe4ec]"
              >
                {item}
              </div>
            ))}
          </div>
        </section>

        <section className="mx-auto mt-10 max-w-2xl text-center">
          <h2 className="text-2xl font-semibold tracking-[-0.03em] text-[#0f172a] dark:text-[#eef2f6]">
            {cta.title}
          </h2>
          <p className="mt-3 text-[1.02rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
            {cta.body}
          </p>
          <a
            href={cta.href}
            className="mt-6 inline-flex rounded-full bg-[#155e63] px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-[#0f4d51] dark:bg-[#67c7d0] dark:text-[#071116] dark:hover:bg-[#8bd7de]"
          >
            {cta.label}
          </a>
        </section>
      </div>
    </section>
  );
}
