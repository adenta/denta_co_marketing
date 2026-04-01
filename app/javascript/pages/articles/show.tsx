type Article = {
  slug: string;
  path: string;
  title: string;
  category: string;
  published_at: string;
  summary: string;
  body: string[];
};

type ArticleShowProps = {
  article: Article;
};

export default function ArticlesShow({ article }: ArticleShowProps) {
  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-30 bg-[linear-gradient(180deg,rgba(234,240,238,0.18),rgba(244,247,245,1)_34%),radial-gradient(circle_at_top_left,rgba(114,142,146,0.18),transparent_32%),radial-gradient(circle_at_82%_12%,rgba(121,153,136,0.14),transparent_28%)]" />
      <div className="absolute inset-0 -z-20 opacity-60 [background-image:radial-gradient(circle_at_1px_1px,rgba(63,84,88,0.14)_1px,transparent_0)] [background-size:14px_14px] [mask-image:linear-gradient(180deg,rgba(0,0,0,0.88),rgba(0,0,0,0.28)_58%,transparent)]" />

      <div className="mx-auto max-w-4xl px-5 pb-20 pt-10 sm:px-8 lg:px-12">
        <a
          href="/"
          className="inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
        >
          Back to home
        </a>

        <article className="mt-8 rounded-[2rem] border border-foreground/10 bg-white/72 p-6 shadow-[0_20px_70px_rgba(42,61,67,0.06)] backdrop-blur sm:p-8">
          <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-[0.72rem] font-medium uppercase tracking-[0.24em] text-muted-foreground">
            <span>{article.category}</span>
            <span>{article.published_at}</span>
          </div>

          <header className="mt-5 space-y-4 border-b border-foreground/8 pb-8">
            <h1 className="max-w-3xl text-[clamp(2.2rem,5vw,4rem)] font-semibold leading-[1.02] tracking-[-0.045em] text-[#21363b]">
              {article.title}
            </h1>
            <p className="max-w-2xl text-[1rem] leading-8 text-[#4b646a]">
              {article.summary}
            </p>
          </header>

          <div className="mt-8 space-y-6 text-[1.02rem] leading-8 text-[#334b51]">
            {article.body.map(paragraph => (
              <p key={paragraph}>{paragraph}</p>
            ))}
          </div>
        </article>
      </div>
    </section>
  );
}
