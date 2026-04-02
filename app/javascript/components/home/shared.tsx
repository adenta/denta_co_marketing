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
    <div className="overflow-hidden rounded-[1.75rem] border border-foreground/10 bg-white/70 shadow-[0_18px_60px_rgba(44,63,69,0.08)] backdrop-blur">
      <img
        src="/andrew-denta-2026.jpeg"
        alt={imageAlt}
        className="aspect-square w-full object-cover"
      />
      <div className="space-y-2 p-4">
        <p className="text-[0.68rem] font-medium uppercase tracking-[0.24em] text-muted-foreground">
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
      className="inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
    >
      {label}
      <ArrowUpRight className="size-4" />
    </a>
  );
}
