type ProjectCard = {
  path: string;
  author: string;
  published_at: string;
  title: string;
  excerpt: string;
};

type ProjectsPageProps = {
  projects: ProjectCard[];
};

export default function ProjectsIndex({ projects }: ProjectsPageProps) {
  return (
    <section className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-10 lg:px-8">
      <div className="mb-6">
        <h1 className="text-3xl font-semibold tracking-tight">Projects</h1>
      </div>

      {projects.length > 0 ? (
        <div>
          {projects.map(project => (
            <article key={project.path} className="border-t py-6 first:border-t-0">
              <div className="space-y-1.5">
                <h2 className="text-[1.45rem] font-semibold tracking-tight text-foreground sm:text-[1.65rem]">
                  <a href={project.path} className="transition-colors hover:text-primary">
                    {project.title}
                  </a>
                </h2>
                <div className="flex flex-wrap items-center gap-2 text-sm text-muted-foreground">
                  <p>{project.published_at}</p>
                  <span>&bull;</span>
                  <p>{project.author}</p>
                </div>
                <p className="max-w-3xl text-[0.98rem] leading-7 text-muted-foreground">
                  {project.excerpt}
                </p>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <div className="border-t border-dashed py-8 text-muted-foreground">
          No project entries yet.
        </div>
      )}
    </section>
  );
}
