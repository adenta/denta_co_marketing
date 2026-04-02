import { ArrowRight } from "lucide-react";
import { trackAnalyticsEvent } from "@/lib/analytics";
import { HeadshotCard, ExternalMangroveLink } from "@/components/home/shared";
import { Button } from "@/components/ui/button";

type RecentPost = {
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type HomePageContent = {
  hero: {
    title: string;
    body: string;
  };
  primary_cta: {
    label: string;
    href: string;
  };
  secondary_link: {
    label: string;
    href: string;
  };
  profile: {
    name: string;
    image_alt: string;
    body: string;
  };
};

type HomeIndexProps = {
  content: HomePageContent;
  recent_posts: RecentPost[];
};

function HeroGlyphMarks() {
  return (
    <div aria-hidden className="pointer-events-none absolute inset-0 -z-10 overflow-hidden">
      <svg
        viewBox="0 0 280 170"
        className="absolute -left-8 top-10 h-28 w-48 text-[#b0e8e4] opacity-90 sm:left-4 sm:top-12 sm:h-36 sm:w-56 dark:text-[#2e9e97] dark:opacity-55"
        fill="none"
      >
        <rect x="20" y="18" width="56" height="56" rx="10" fill="currentColor" />
        <rect x="86" y="18" width="38" height="94" rx="10" fill="currentColor" />
      </svg>

      <svg
        viewBox="0 0 320 170"
        className="absolute left-[28%] top-10 hidden h-28 w-64 text-[#d8f3f2] opacity-95 md:block lg:left-[36%] dark:text-[#174f4b] dark:opacity-90"
        fill="none"
      >
        <rect x="18" y="52" width="188" height="52" rx="12" fill="currentColor" />
        <rect x="190" y="18" width="48" height="48" rx="10" fill="currentColor" />
      </svg>

      <svg
        viewBox="0 0 340 170"
        className="absolute bottom-12 right-6 h-28 w-48 text-[#b0e8e4] opacity-80 sm:h-36 sm:w-60 dark:text-[#61d1ca] dark:opacity-45"
        fill="none"
      >
        <rect x="0" y="84" width="52" height="52" rx="10" fill="currentColor" />
        <rect x="64" y="84" width="100" height="52" rx="10" fill="currentColor" />
        <rect x="238" y="20" width="52" height="52" rx="10" fill="currentColor" />
        <rect x="238" y="84" width="52" height="52" rx="10" fill="currentColor" />
        <rect x="304" y="20" width="36" height="116" rx="10" fill="currentColor" />
      </svg>
    </div>
  );
}

export default function HomeIndex({ content, recent_posts }: HomeIndexProps) {
  const { hero, primary_cta, secondary_link, profile } = content;

  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-30 bg-[linear-gradient(180deg,rgba(235,249,248,0.9),rgba(243,243,242,0.92)_28%,rgba(243,243,242,1)_100%),radial-gradient(circle_at_top_left,rgba(97,209,202,0.26),transparent_32%),radial-gradient(circle_at_82%_14%,rgba(137,220,215,0.22),transparent_28%),radial-gradient(circle_at_64%_55%,rgba(46,158,151,0.09),transparent_32%),radial-gradient(circle_at_50%_100%,rgba(32,110,105,0.08),transparent_32%)] dark:bg-[linear-gradient(180deg,rgba(6,20,19,0.96),rgba(13,13,12,0.95)_28%,rgba(13,13,12,1)_100%),radial-gradient(circle_at_top_left,rgba(97,209,202,0.22),transparent_34%),radial-gradient(circle_at_82%_14%,rgba(35,118,113,0.28),transparent_30%),radial-gradient(circle_at_64%_55%,rgba(46,158,151,0.1),transparent_32%),radial-gradient(circle_at_50%_100%,rgba(137,220,215,0.08),transparent_32%)]" />
      <div className="absolute inset-0 -z-20 opacity-85 [background-image:radial-gradient(circle_at_1px_1px,rgba(35,118,113,0.28)_1.35px,transparent_0)] [background-size:16px_16px] [mask-image:linear-gradient(180deg,rgba(0,0,0,0.92),rgba(0,0,0,0.44)_58%,transparent)] dark:[background-image:radial-gradient(circle_at_1px_1px,rgba(137,220,215,0.16)_1.35px,transparent_0)] dark:opacity-90" />
      <HeroGlyphMarks />
      <div className="mx-auto max-w-7xl px-5 pb-20 pt-16 sm:px-8 sm:pt-20 lg:px-12">
        <div className="grid gap-8 lg:grid-cols-[minmax(0,1.1fr)_22rem] lg:items-start">
          <div className="space-y-6">
            <div className="space-y-4">
              <h1 className="max-w-4xl text-[clamp(2.4rem,6vw,4.7rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-foreground">
                {hero.title}
              </h1>
              <p className="max-w-3xl text-[0.98rem] leading-8 text-[#4f5b57] sm:text-[1.04rem] dark:text-[#b5b5b0]">
                {hero.body}
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Button
                asChild
                size="lg"
                className="h-10 rounded-full border border-[#174f4b] bg-[#237671] px-5 shadow-[0_14px_30px_rgba(35,118,113,0.18)] hover:bg-[#206e69] dark:border-[#89dcd7]/28 dark:bg-[#89dcd7] dark:text-[#061413] dark:shadow-[0_16px_32px_rgba(97,209,202,0.16)] dark:hover:bg-[#61d1ca]"
              >
                <a
                  href={primary_cta.href}
                  onClick={() =>
                    trackAnalyticsEvent("Clicked contact CTA", {
                      location: "home hero",
                      href: primary_cta.href,
                    })
                  }
                >
                  {primary_cta.label}
                  <ArrowRight className="size-4" />
                </a>
              </Button>
              <ExternalMangroveLink href={secondary_link.href} label={secondary_link.label} />
            </div>
          </div>

          <HeadshotCard name={profile.name} imageAlt={profile.image_alt} body={profile.body} />
        </div>

        <div
          id="recent-writing"
          className="mt-14 grid gap-4 border-t border-[#237671]/10 pt-8 md:grid-cols-3 dark:border-[#89dcd7]/14"
        >
          {recent_posts.map(post => (
            <a
              key={post.path}
              href={post.path}
              className="group rounded-[1.7rem] border border-[#237671]/12 bg-white p-5 shadow-[0_16px_50px_rgba(17,52,49,0.05)] backdrop-blur transition-transform hover:-translate-y-0.5 dark:border-[#89dcd7]/14 dark:bg-[#1a1a19]/92 dark:shadow-[0_20px_58px_rgba(0,0,0,0.34)]"
            >
              <div className="flex items-center justify-between gap-3 text-[0.68rem] font-medium uppercase tracking-[0.22em] text-[#237671] dark:text-[#89dcd7]">
                <p>{post.author}</p>
                <p>{post.published_at}</p>
              </div>
              <h2 className="mt-4 text-xl font-semibold tracking-[-0.03em] text-[#1a1a19] transition-colors group-hover:text-[#174f4b] dark:text-foreground dark:group-hover:text-[#89dcd7]">
                {post.title}
              </h2>
              <p className="mt-3 text-sm leading-7 text-[#4f5b57] dark:text-[#b5b5b0]">{post.excerpt}</p>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
