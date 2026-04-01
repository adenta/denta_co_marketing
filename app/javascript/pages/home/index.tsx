import { ArrowRight } from "lucide-react";
import { HeadshotCard, ExternalMangroveLink } from "@/components/home/shared";
import { Button } from "@/components/ui/button";

type RecentPost = {
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type HomeIndexProps = {
  recent_posts: RecentPost[];
};

export default function HomeIndex({ recent_posts }: HomeIndexProps) {
  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-30 bg-[linear-gradient(180deg,rgba(234,240,238,0.22),rgba(243,246,244,0.92)_35%,rgba(244,247,245,1)),radial-gradient(circle_at_top_left,rgba(114,142,146,0.22),transparent_33%),radial-gradient(circle_at_82%_12%,rgba(121,153,136,0.18),transparent_30%),radial-gradient(circle_at_50%_90%,rgba(92,116,123,0.11),transparent_28%)]" />
      <div className="absolute inset-0 -z-20 opacity-70 [background-image:radial-gradient(circle_at_1px_1px,rgba(63,84,88,0.16)_1.1px,transparent_0)] [background-size:14px_14px] [mask-image:linear-gradient(180deg,rgba(0,0,0,0.9),rgba(0,0,0,0.32)_54%,transparent)]" />
      <div className="mx-auto max-w-7xl px-5 pb-20 pt-10 sm:px-8 lg:px-12">
        <div className="grid gap-8 lg:grid-cols-[minmax(0,1.1fr)_22rem] lg:items-start">
          <div className="space-y-6">
            <div className="space-y-4">
              <h1 className="max-w-4xl text-[clamp(2.4rem,6vw,4.7rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-[#1f3136]">
                A friendly place to think through useful AI and the software around it.
              </h1>
              <p className="max-w-3xl text-[0.98rem] leading-8 text-[#4b646a] sm:text-[1.04rem]">
                This is primarily a personal blog. It also happens to be the easiest way
                to understand how I approach product, systems, and consulting work.
                A lot of the examples come from workflow-heavy environments because they
                make operational friction easy to see.
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-3">
              <Button asChild size="lg" className="h-10 rounded-full px-5">
                <a href="mailto:andrew@denta.co">
                  Say hello
                  <ArrowRight className="size-4" />
                </a>
              </Button>
              <ExternalMangroveLink />
            </div>
          </div>

          <HeadshotCard />
        </div>

        <div
          id="recent-writing"
          className="mt-14 grid gap-4 border-t border-foreground/8 pt-8 md:grid-cols-3"
        >
          {recent_posts.map(post => (
            <a
              key={post.path}
              href={post.path}
              className="group rounded-[1.7rem] border border-foreground/10 bg-white/72 p-5 shadow-[0_16px_50px_rgba(42,61,67,0.05)] backdrop-blur transition-transform hover:-translate-y-0.5"
            >
              <div className="flex items-center justify-between gap-3 text-[0.68rem] font-medium uppercase tracking-[0.22em] text-muted-foreground">
                <p>{post.author}</p>
                <p>{post.published_at}</p>
              </div>
              <h2 className="mt-4 text-xl font-semibold tracking-[-0.03em] text-[#22383d] group-hover:text-[#314f55]">
                {post.title}
              </h2>
              <p className="mt-3 text-sm leading-7 text-[#4a6469]">{post.excerpt}</p>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
