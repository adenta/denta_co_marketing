import BlogSubscribeForm from "@/components/blog/BlogSubscribeForm";
import { Separator } from "@/components/ui/separator";

type PostCard = {
  slug: string;
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type SubscribeFormProps = {
  createPath: string;
  title: string;
  description: string;
  emailLabel: string;
  emailPlaceholder?: string;
  submitLabel: string;
  successMessage?: string;
  subscribedTitle: string;
  subscribedDescription: string;
  resetLabel: string;
  turnstileSiteKey?: string;
  verificationRequiredMessage: string;
  unavailableMessage: string;
};

type WritingsIndexProps = {
  writings: PostCard[];
  projects: PostCard[];
  subscribeForm: SubscribeFormProps;
};

function PostList({
  posts,
  emptyState,
}: {
  posts: PostCard[];
  emptyState: string;
}) {
  if (posts.length === 0) {
    return (
      <div className="border-t border-dashed border-border/80 py-8 text-muted-foreground">
        {emptyState}
      </div>
    );
  }

  return (
    <div>
      {posts.map(post => (
        <article key={post.slug} className="border-t py-6 first:border-t-0">
          <div className="space-y-1.5">
            <h2 className="text-[1.45rem] font-semibold tracking-tight text-foreground sm:text-[1.65rem]">
              <a href={post.path} className="transition-colors hover:text-primary">
                {post.title}
              </a>
            </h2>
            <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
              <p>{post.published_at}</p>
              <span>&bull;</span>
              <p>{post.author}</p>
            </div>
            <p className="max-w-3xl text-[0.98rem] leading-7 text-muted-foreground">
              {post.excerpt}
            </p>
          </div>
        </article>
      ))}
    </div>
  );
}

export default function WritingsIndex({
  writings,
  projects,
  subscribeForm,
}: WritingsIndexProps) {
  return (
    <section className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10 lg:px-8">
      <div className="space-y-3">
        <h1 className="text-3xl font-semibold tracking-tight text-foreground">Writing</h1>
        <p className="max-w-3xl text-[0.98rem] leading-7 text-muted-foreground">
          Notes from client work, production systems, and the projects that shaped them.
        </p>
      </div>

      <div className="mt-8">
        <PostList
          posts={writings}
          emptyState="Add markdown files to publish the first post."
        />
      </div>

      <Separator className="my-10" />

      <div className="space-y-3">
        <h2 className="text-2xl font-semibold tracking-tight text-foreground">Projects</h2>
        <p className="max-w-3xl text-[0.98rem] leading-7 text-muted-foreground">
          Focused build notes from products, internal tools, and AI systems shipped with clients.
        </p>
      </div>

      <div className="mt-6">
        <PostList
          posts={projects}
          emptyState="No project entries yet."
        />
      </div>

      <Separator className="my-10" />

      <BlogSubscribeForm {...subscribeForm} />
    </section>
  );
}
