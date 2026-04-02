import { ArrowUpRight } from "lucide-react";

export function HeadshotCard() {
  return (
    <div className="overflow-hidden rounded-[1.75rem] border border-[#237671]/12 bg-white shadow-[0_22px_70px_rgba(17,52,49,0.08)] backdrop-blur">
      <img
        src="/andrew-denta-2026.jpeg"
        alt="Andrew Denta"
        className="aspect-square w-full object-cover"
      />
      <div className="space-y-2 border-t border-[#237671]/10 bg-white p-4">
        <p className="text-[0.68rem] font-medium uppercase tracking-[0.24em] text-[#237671]">
          Andrew Denta
        </p>
        <p className="text-sm leading-7 text-[#355350]">
          Writing about AI, software, and the operational problems that reveal where
          better systems actually matter.
        </p>
      </div>
    </div>
  );
}

export function ExternalMangroveLink() {
  return (
    <a
      href="https://mangrovetechnology.com"
      target="_blank"
      rel="noreferrer"
      className="inline-flex items-center gap-2 rounded-full border border-[#237671]/12 bg-white/70 px-3 py-2 text-sm text-[#355350] transition-colors hover:border-[#237671]/30 hover:text-[#0c2726]"
    >
      Mangrove Technology
      <ArrowUpRight className="size-4" />
    </a>
  );
}
