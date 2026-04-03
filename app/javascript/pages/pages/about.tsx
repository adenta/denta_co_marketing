type AboutContent = {
  hero: {
    eyebrow: string;
    title: string;
    body: string;
  };
  summary: {
    title: string;
    paragraphs: string[];
  };
  background: {
    title: string;
    items: string[];
  };
  working_style: {
    title: string;
    items: string[];
  };
  focus_areas: {
    title: string;
    items: string[];
  };
  cta: {
    label: string;
    href: string;
  };
};

type AboutPageProps = {
  content: AboutContent;
};

function ContentColumn({ title, items }: { title: string; items: string[] }) {
  return (
    <section className="rounded-[1.8rem] border border-[#0f172a]/10 bg-white/92 p-6 shadow-[0_20px_44px_rgba(15,23,42,0.08)] dark:border-white/8 dark:bg-[#131a21]/92 dark:shadow-[0_18px_48px_rgba(0,0,0,0.28)]">
      <h2 className="text-lg font-semibold tracking-[-0.03em] text-[#0f172a] dark:text-[#eef2f6]">
        {title}
      </h2>
      <div className="mt-4 space-y-3">
        {items.map(item => (
          <p key={item} className="text-sm leading-7 text-[#425466] dark:text-[#9eabb8]">
            {item}
          </p>
        ))}
      </div>
    </section>
  );
}

export default function AboutPage({ content }: AboutPageProps) {
  const { hero, summary, background, working_style, focus_areas, cta } = content;

  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[radial-gradient(circle_at_top_left,rgba(21,94,99,0.16),transparent_32%),radial-gradient(circle_at_82%_14%,rgba(15,23,42,0.14),transparent_26%),linear-gradient(180deg,rgba(244,247,250,1),rgba(231,238,244,0.96))] dark:bg-[radial-gradient(circle_at_top_left,rgba(103,199,208,0.14),transparent_30%),radial-gradient(circle_at_82%_14%,rgba(51,65,85,0.26),transparent_26%),linear-gradient(180deg,rgba(11,17,22,1),rgba(12,18,24,0.98))]" />
      <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6 sm:py-18 lg:px-8">
        <div className="grid gap-6 lg:grid-cols-[minmax(0,1.05fr)_22rem]">
          <section className="rounded-[2rem] border border-[#0f172a]/10 bg-white/82 p-7 shadow-[0_28px_70px_rgba(15,23,42,0.1)] backdrop-blur dark:border-white/8 dark:bg-[#131a21]/84 dark:shadow-[0_24px_68px_rgba(0,0,0,0.34)]">
            <p className="text-sm font-semibold uppercase tracking-[0.28em] text-[#155e63] dark:text-[#67c7d0]">
              {hero.eyebrow}
            </p>
            <h1 className="mt-4 max-w-4xl text-[clamp(2.35rem,6vw,4.4rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-[#0f172a] dark:text-[#eef2f6]">
              {hero.title}
            </h1>
            <p className="mt-4 max-w-3xl text-[1.02rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
              {hero.body}
            </p>

            <div className="mt-8 rounded-[1.5rem] border border-[#155e63]/14 bg-[linear-gradient(180deg,rgba(245,249,251,0.96),rgba(233,241,244,0.9))] p-5 dark:border-[#67c7d0]/12 dark:bg-[linear-gradient(180deg,rgba(19,26,33,0.95),rgba(17,23,30,0.9))]">
              <h2 className="text-lg font-semibold tracking-[-0.03em] text-[#0f172a] dark:text-[#eef2f6]">
                {summary.title}
              </h2>
              <div className="mt-4 space-y-3">
                {summary.paragraphs.map(paragraph => (
                  <p key={paragraph} className="text-sm leading-7 text-[#425466] dark:text-[#9eabb8]">
                    {paragraph}
                  </p>
                ))}
              </div>
              <a
                href={cta.href}
                className="mt-6 inline-flex rounded-full bg-[#155e63] px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-[#0f4d51] dark:bg-[#67c7d0] dark:text-[#071116] dark:hover:bg-[#8bd7de]"
              >
                {cta.label}
              </a>
            </div>
          </section>

          <div className="rounded-[2rem] border border-[#0f172a]/10 bg-[linear-gradient(180deg,rgba(21,94,99,0.94),rgba(12,39,38,0.98))] p-7 text-white shadow-[0_28px_70px_rgba(21,94,99,0.22)] dark:border-[#67c7d0]/10 dark:bg-[linear-gradient(180deg,rgba(20,53,61,0.96),rgba(10,18,24,0.98))]">
            <p className="text-sm font-semibold uppercase tracking-[0.28em] text-[#cdeff2]">
              Snapshot
            </p>
            <div className="mt-6 space-y-5 text-sm leading-7 text-[#e6f4f5]">
              <p>Founder of an acquired YC logistics company.</p>
              <p>Built product and systems in workflow-heavy environments at Uber Freight and Handshake.</p>
              <p>Now focused on AI systems that reduce operational drag instead of adding novelty.</p>
            </div>
          </div>
        </div>

        <div className="mt-8 grid gap-6 lg:grid-cols-3">
          <ContentColumn title={background.title} items={background.items} />
          <ContentColumn title={working_style.title} items={working_style.items} />
          <ContentColumn title={focus_areas.title} items={focus_areas.items} />
        </div>
      </div>
    </section>
  );
}
