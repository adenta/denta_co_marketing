type HomeLink = {
  label: string;
  href: string;
};

type HomePost = {
  slug: string;
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type HomeIndexProps = {
  title: string;
  subtitle: string;
  recentPostsHeading: string;
  recentPostsPath: string;
  recentPostsEmpty: string;
  recentPosts: HomePost[];
  links: {
    linkedin: HomeLink;
    calendar: HomeLink;
  };
};

function ExternalLink({ link }: { link: HomeLink }) {
  return (
    <a
      href={link.href}
      target="_blank"
      rel="noreferrer"
      className="text-lg text-primary underline underline-offset-4 transition-colors hover:text-primary/80"
    >
      {link.label}
    </a>
  );
}

export default function HomeIndex({
  title,
  subtitle,
  recentPostsHeading,
  recentPostsPath,
  recentPostsEmpty,
  recentPosts,
  links,
}: HomeIndexProps) {
  return (
    <div className="mx-auto max-w-6xl px-4 py-10 sm:px-6 sm:py-14 lg:px-8">
      <section className="max-w-4xl space-y-6">
        <h1 className="max-w-3xl text-4xl font-semibold tracking-tight text-balance sm:text-5xl lg:text-6xl">
          {title}
        </h1>
        <p className="max-w-3xl text-base leading-8 text-muted-foreground sm:text-lg">
          {subtitle}
        </p>
        <div className="flex flex-wrap items-center gap-x-6 gap-y-3 pt-2">
          <ExternalLink link={links.linkedin} />
          <ExternalLink link={links.calendar} />
        </div>
      </section>

      <section className="mt-16 border-t border-border pt-8">
        <div className="mb-5 flex items-end justify-between gap-4">
          <a
            href={recentPostsPath}
            className="text-xl font-semibold tracking-tight text-primary underline underline-offset-8 transition-colors hover:text-primary/80 sm:text-2xl"
          >
            {recentPostsHeading}
          </a>
        </div>

        {recentPosts.length > 0 ? (
          <ul className="space-y-8">
            {recentPosts.map(post => (
              <li key={post.slug}>
                <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                  <span className="text-muted-foreground">-</span>
                  <a
                    href={post.path}
                    className="text-lg text-primary underline underline-offset-4 transition-colors hover:text-primary/80"
                  >
                    {post.title}
                  </a>
                  <span className="text-sm text-muted-foreground">{post.published_at}</span>
                </div>
              </li>
            ))}
          </ul>
        ) : (
          <div className="py-6 text-muted-foreground">
            {recentPostsEmpty}
          </div>
        )}
      </section>
    </div>
  );
}
