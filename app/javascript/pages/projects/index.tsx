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
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[radial-gradient(circle_at_top_left,rgba(21,94,99,0.14),transparent_28%),radial-gradient(circle_at_86%_18%,rgba(15,23,42,0.12),transparent_26%),linear-gradient(180deg,rgba(245,248,251,1),rgba(232,239,244,0.96))] dark:bg-[radial-gradient(circle_at_top_left,rgba(103,199,208,0.14),transparent_28%),radial-gradient(circle_at_86%_18%,rgba(51,65,85,0.22),transparent_26%),linear-gradient(180deg,rgba(11,17,22,1),rgba(12,18,24,0.98))]" />
      <div className="mx-auto max-w-6xl px-4 py-14 sm:px-6 sm:py-18 lg:px-8">
        <div className="max-w-3xl">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-[#155e63] dark:text-[#67c7d0]">
            Projects
          </p>
          <h1 className="mt-4 text-[clamp(2.3rem,6vw,4.3rem)] font-semibold leading-[0.98] tracking-[-0.045em] text-[#0f172a] dark:text-[#eef2f6]">
            Project entries can stay, but the sales wrapper is gone.
          </h1>
          <p className="mt-4 max-w-3xl text-[1rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
            This route is now a straightforward index for case studies or work samples. If no entries exist yet, it stays intentionally quiet.
          </p>
        </div>

        {projects.length > 0 ? (
          <div className="mt-10 grid gap-4 lg:grid-cols-2">
            {projects.map(project => (
              <a
                key={project.path}
                href={project.path}
                className="group rounded-[2rem] border border-[#0f172a]/10 bg-white/94 p-6 shadow-[0_22px_56px_rgba(15,23,42,0.08)] transition-transform hover:-translate-y-0.5 hover:border-[#155e63]/24 dark:border-white/8 dark:bg-[#131a21]/94 dark:shadow-[0_22px_56px_rgba(0,0,0,0.3)]"
              >
                <div className="flex flex-wrap items-center gap-3 text-[0.72rem] font-semibold uppercase tracking-[0.22em] text-[#155e63] dark:text-[#67c7d0]">
                  <p>{project.author}</p>
                  <p>{project.published_at}</p>
                </div>
                <h2 className="mt-4 text-2xl font-semibold tracking-[-0.03em] text-[#0f172a] transition-colors group-hover:text-[#155e63] dark:text-[#eef2f6] dark:group-hover:text-[#67c7d0]">
                  {project.title}
                </h2>
                <p className="mt-3 text-sm leading-7 text-[#425466] dark:text-[#9eabb8]">
                  {project.excerpt}
                </p>
              </a>
            ))}
          </div>
        ) : (
          <div className="mt-10 rounded-[2rem] border border-dashed border-[#0f172a]/16 bg-white/72 p-10 text-center text-sm leading-7 text-[#425466] dark:border-white/12 dark:bg-[#131a21]/70 dark:text-[#9eabb8]">
            No project entries yet.
          </div>
        )}
      </div>
    </section>
  );
}
