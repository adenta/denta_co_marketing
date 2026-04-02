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
  recent_writing: {
    title: string;
    all_posts_label: string;
  };
};

type HomeIndexProps = {
  content: HomePageContent;
  blog_index_path: string;
  recent_posts: RecentPost[];
};

function HeroGlyphMarks() {
  return (
    <div aria-hidden className="pointer-events-none absolute inset-0 -z-10 overflow-hidden">
      <svg
        viewBox="0 0 280 170"
        className="absolute -left-8 top-8 h-28 w-48 text-[#c9d3dd] opacity-95 sm:left-4 sm:top-10 sm:h-36 sm:w-56 dark:text-[#27414b] dark:opacity-75"
        fill="none"
      >
        <rect x="20" y="18" width="56" height="56" rx="10" fill="currentColor" />
        <rect x="86" y="18" width="38" height="94" rx="10" fill="currentColor" />
      </svg>

      <svg
        viewBox="0 0 320 170"
        className="absolute left-[28%] top-8 hidden h-28 w-64 text-[#dbe4ec] opacity-90 md:block lg:left-[36%] dark:text-[#182833] dark:opacity-95"
        fill="none"
      >
        <rect x="18" y="52" width="188" height="52" rx="12" fill="currentColor" />
        <rect x="190" y="18" width="48" height="48" rx="10" fill="currentColor" />
      </svg>

      <svg
        viewBox="0 0 340 170"
        className="absolute bottom-12 right-6 h-28 w-48 text-[#9db3bd] opacity-70 sm:h-36 sm:w-60 dark:text-[#43616b] dark:opacity-55"
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

export default function HomeIndex({ content, blog_index_path, recent_posts }: HomeIndexProps) {
  const { hero, primary_cta, secondary_link, profile, recent_writing } = content;

  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-30 bg-[linear-gradient(180deg,rgba(248,250,252,0.98),rgba(244,247,250,0.98)_30%,rgba(239,243,247,1)_100%),radial-gradient(circle_at_top_left,rgba(15,23,42,0.08),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(21,94,99,0.1),transparent_26%),radial-gradient(circle_at_64%_56%,rgba(71,85,105,0.08),transparent_30%)] dark:bg-[linear-gradient(180deg,rgba(9,13,17,0.98),rgba(11,16,22,0.98)_30%,rgba(10,14,19,1)_100%),radial-gradient(circle_at_top_left,rgba(51,65,85,0.24),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(44,155,170,0.16),transparent_28%),radial-gradient(circle_at_64%_56%,rgba(15,23,42,0.38),transparent_34%)]" />
      <div className="absolute inset-0 -z-20 opacity-75 [background-image:radial-gradient(circle_at_1px_1px,rgba(15,23,42,0.22)_1.15px,transparent_0)] [background-size:18px_18px] [mask-image:linear-gradient(180deg,rgba(0,0,0,0.9),rgba(0,0,0,0.4)_58%,transparent)] dark:[background-image:radial-gradient(circle_at_1px_1px,rgba(148,163,184,0.14)_1.1px,transparent_0)] dark:opacity-85" />
      <HeroGlyphMarks />
      <div className="mx-auto max-w-7xl px-5 pb-16 pt-12 sm:px-8 sm:pt-16 lg:px-12">
        <div className="grid gap-6 lg:grid-cols-[minmax(0,1.1fr)_22rem] lg:items-start">
          <div className="space-y-5">
            <div className="space-y-3">
              <h1 className="max-w-4xl text-[clamp(2.4rem,6vw,4.7rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-foreground">
                {hero.title}
              </h1>
              <p className="max-w-3xl text-[0.97rem] leading-7 text-[#46505a] sm:text-[1.02rem] dark:text-[#a7b1bc]">
                {hero.body}
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-2.5">
              <Button
                asChild
                size="lg"
                className="h-9 rounded-lg px-4"
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

        <div id="recent-writing" className="mt-12 border-t border-[#0f3f46]/10 pt-6 dark:border-[#67c7d0]/12">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h2 className="text-2xl font-semibold tracking-[-0.03em] text-foreground">
              {recent_writing.title}
            </h2>
            <a
              href={blog_index_path}
              className="inline-flex items-center gap-2 rounded-full border border-[#155e63]/14 bg-white/92 px-4 py-2 text-sm font-medium text-[#355350] transition-colors hover:border-[#155e63]/28 hover:text-[#0c2726] dark:border-[#67c7d0]/16 dark:bg-[#131a21]/92 dark:text-[#a7b1bc] dark:hover:border-[#67c7d0]/30 dark:hover:text-[#f3f3f2]"
            >
              {recent_writing.all_posts_label}
              <ArrowRight className="size-4" />
            </a>
          </div>

          <div className="mt-6 grid gap-3 md:grid-cols-3">
            {recent_posts.map(post => (
              <a
                key={post.path}
                href={post.path}
                className="group rounded-2xl border border-[#0f172a]/8 bg-white/92 p-4 shadow-[0_14px_36px_rgba(15,23,42,0.05)] backdrop-blur transition-transform hover:-translate-y-0.5 hover:border-[#155e63]/16 dark:border-white/8 dark:bg-[#131a21]/92 dark:shadow-[0_18px_48px_rgba(0,0,0,0.32)]"
              >
                <div className="flex items-center justify-between gap-3 text-[0.68rem] font-medium uppercase tracking-[0.22em] text-[#155e63] dark:text-[#67c7d0]">
                  <p>{post.author}</p>
                  <p>{post.published_at}</p>
                </div>
                <h2 className="mt-3 text-xl font-semibold tracking-[-0.03em] text-[#0f172a] transition-colors group-hover:text-[#155e63] dark:text-foreground dark:group-hover:text-[#67c7d0]">
                  {post.title}
                </h2>
                <p className="mt-2.5 text-sm leading-6 text-[#4d5965] dark:text-[#9eabb8]">
                  {post.excerpt}
                </p>
              </a>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
