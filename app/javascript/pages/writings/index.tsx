import BlogSubscribeForm from "@/components/blog/BlogSubscribeForm";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";

type PostCard = {
  slug: string;
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
  "project?": boolean;
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
  posts: PostCard[];
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
            <h2 className="flex flex-wrap items-center gap-3 text-[1.45rem] font-semibold tracking-tight text-foreground sm:text-[1.65rem]">
              <a href={post.path} className="transition-colors hover:text-primary">
                {post.title}
              </a>
              {post["project?"] ? (
                <Badge
                  variant="outline"
                  className="border-orange-200 bg-orange-100 text-orange-700 uppercase dark:border-orange-400/30 dark:bg-orange-500/15 dark:text-orange-200"
                >
                  Project
                </Badge>
              ) : null}
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
  posts,
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
          posts={posts}
          emptyState="Add markdown files to publish the first post."
        />
      </div>

      <Separator className="my-10" />

      <BlogSubscribeForm {...subscribeForm} />
    </section>
  );
}
