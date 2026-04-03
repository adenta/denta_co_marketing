import { ArrowRight } from "lucide-react";

type HomeIndexProps = {
  aboutPath: string;
  blogPath: string;
  projectsPath: string;
  servicesPath: string;
};

const sections = [
  {
    title: "About",
    description: "Reserve this page for positioning, background, or operator notes.",
    key: "aboutPath" as const,
  },
  {
    title: "Services",
    description: "Use this slot once there is a real offer structure to explain.",
    key: "servicesPath" as const,
  },
  {
    title: "Projects",
    description: "Keep project case studies or work samples behind a dedicated index.",
    key: "projectsPath" as const,
  },
  {
    title: "Writing",
    description: "The blog remains available if you want to publish long-form content.",
    key: "blogPath" as const,
  },
];

export default function HomeIndex(props: HomeIndexProps) {
  return (
    <section className="relative isolate overflow-hidden bg-background">
      <div className="absolute inset-0 -z-20 bg-[linear-gradient(180deg,rgba(246,248,250,0.98),rgba(233,238,243,0.98)_40%,rgba(223,230,236,1)_100%),radial-gradient(circle_at_top_left,rgba(15,23,42,0.1),transparent_34%),radial-gradient(circle_at_85%_15%,rgba(21,94,99,0.12),transparent_24%)] dark:bg-[linear-gradient(180deg,rgba(9,13,17,0.98),rgba(11,16,22,0.98)_34%,rgba(10,14,19,1)_100%),radial-gradient(circle_at_top_left,rgba(51,65,85,0.24),transparent_34%),radial-gradient(circle_at_85%_15%,rgba(44,155,170,0.14),transparent_28%)]" />
      <div className="mx-auto max-w-6xl px-5 pb-16 pt-14 sm:px-8 lg:px-12">
        <div className="max-w-3xl rounded-[2rem] border border-[#0f172a]/10 bg-white/88 p-8 shadow-[0_28px_64px_rgba(15,23,42,0.08)] backdrop-blur dark:border-white/8 dark:bg-[#131a21]/88 dark:shadow-[0_24px_64px_rgba(0,0,0,0.32)]">
          <p className="text-sm font-semibold uppercase tracking-[0.3em] text-[#155e63] dark:text-[#67c7d0]">
            Blank slate
          </p>
          <h1 className="mt-4 text-[clamp(2.5rem,6vw,4.6rem)] font-semibold leading-[0.98] tracking-[-0.05em] text-[#0f172a] dark:text-[#eef2f6]">
            The application shell is intact. The marketing layer is gone.
          </h1>
          <p className="mt-4 max-w-2xl text-[1rem] leading-8 text-[#425466] dark:text-[#9eabb8]">
            Navigation, page mounting, auth flows, and content routes still work. The home page now acts as a reset point instead of carrying a full personal-site narrative.
          </p>
        </div>

        <div className="mt-8 grid gap-4 md:grid-cols-2">
          {sections.map(section => (
            <a
              key={section.title}
              href={props[section.key]}
              className="group rounded-[1.75rem] border border-[#0f172a]/10 bg-white/94 p-6 shadow-[0_22px_48px_rgba(15,23,42,0.07)] transition-transform hover:-translate-y-0.5 hover:border-[#155e63]/24 dark:border-white/8 dark:bg-[#131a21]/92 dark:shadow-[0_20px_48px_rgba(0,0,0,0.3)]"
            >
              <div className="flex items-center justify-between gap-3">
                <h2 className="text-2xl font-semibold tracking-[-0.03em] text-[#0f172a] dark:text-[#eef2f6]">
                  {section.title}
                </h2>
                <ArrowRight className="size-4 text-[#155e63] transition-transform group-hover:translate-x-0.5 dark:text-[#67c7d0]" />
              </div>
              <p className="mt-3 text-sm leading-7 text-[#425466] dark:text-[#9eabb8]">
                {section.description}
              </p>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
