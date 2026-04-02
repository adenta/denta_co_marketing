import { ArrowUpRight } from "lucide-react";

type HeadshotCardProps = {
  name: string;
  imageAlt: string;
  body: string;
};

type ExternalMangroveLinkProps = {
  href: string;
  label: string;
};

export function HeadshotCard({ name, imageAlt, body }: HeadshotCardProps) {
  return (
    <div className="overflow-hidden rounded-[1.2rem] border border-[#0f172a]/8 bg-[#f8fafc]/95 shadow-[0_18px_48px_rgba(15,23,42,0.07)] backdrop-blur dark:border-white/8 dark:bg-[#131a21]/92 dark:shadow-[0_20px_52px_rgba(0,0,0,0.34)]">
      <img
        src="/andrew-denta-2026.jpeg"
        alt={imageAlt}
        className="aspect-square w-full object-cover"
      />
      <div className="space-y-1.5 border-t border-[#0f172a]/8 bg-[#f8fafc]/96 p-3 dark:border-white/8 dark:bg-[#131a21]/92">
        <p className="text-[0.68rem] font-medium uppercase tracking-[0.24em] text-[#155e63] dark:text-[#67c7d0]">
          {name}
        </p>
        <p className="text-sm leading-6 text-[#475569] dark:text-[#9eabb8]">{body}</p>
      </div>
    </div>
  );
}

export function ExternalMangroveLink({ href, label }: ExternalMangroveLinkProps) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noreferrer"
      className="inline-flex items-center gap-2 rounded-lg border border-[#0f172a]/8 bg-white/72 px-3 py-1.5 text-sm text-[#334155] transition-colors hover:border-[#155e63]/28 hover:text-[#0f172a] dark:border-white/8 dark:bg-[#131a21]/78 dark:text-[#9eabb8] dark:hover:border-[#67c7d0]/24 dark:hover:text-[#eef2f6]"
    >
      {label}
      <ArrowUpRight className="size-4" />
    </a>
  );
}
