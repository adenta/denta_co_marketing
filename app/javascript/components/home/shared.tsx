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
    <div className="overflow-hidden rounded-[1.75rem] border border-[#237671]/12 bg-white shadow-[0_22px_70px_rgba(17,52,49,0.08)] backdrop-blur">
      <img
        src="/andrew-denta-2026.jpeg"
        alt={imageAlt}
        className="aspect-square w-full object-cover"
      />
      <div className="space-y-2 border-t border-[#237671]/10 bg-white p-4">
        <p className="text-[0.68rem] font-medium uppercase tracking-[0.24em] text-[#237671]">
          {name}
        </p>
        <p className="text-sm leading-7 text-[#486067]">{body}</p>
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
      className="inline-flex items-center gap-2 rounded-full border border-[#237671]/12 bg-white/70 px-3 py-2 text-sm text-[#355350] transition-colors hover:border-[#237671]/30 hover:text-[#0c2726]"
    >
      {label}
      <ArrowUpRight className="size-4" />
    </a>
  );
}
