import { CloudSun, Sun, Wind } from "lucide-react";
import { DefaultToolRenderer } from "@/components/chat-tool-renderers/default-tool-renderer";
import {
  hasError,
  toolOutput,
  ToolOutputAccordion,
  ToolRendererFrame,
} from "@/components/chat-tool-renderers/shared";
import type { ToolRendererProps } from "@/components/chat-tool-renderers/types";

type WeatherToolOutput = {
  location?: string;
  temperature_f?: number | string;
  conditions?: string;
  source?: string;
};

function isWeatherToolOutput(value: unknown): value is WeatherToolOutput {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function weatherConditionIcon(conditions: string | undefined) {
  const value = conditions?.toLowerCase() ?? "";
  if (value.includes("wind")) {
    return Wind;
  }
  if (value.includes("cloud") || value.includes("fog")) {
    return CloudSun;
  }

  return Sun;
}

function weatherTheme(conditions: string | undefined) {
  const value = conditions?.toLowerCase() ?? "";

  if (value.includes("wind")) {
    return {
      card: "border-sky-300/50 from-sky-100 via-cyan-50 to-blue-100 dark:border-sky-500/30 dark:from-sky-950/70 dark:via-cyan-950/50 dark:to-blue-950/70",
      iconBubble: "bg-sky-200/80 text-sky-800 dark:bg-sky-400/18 dark:text-sky-100",
    };
  }

  if (value.includes("cloud") || value.includes("fog")) {
    return {
      card: "border-slate-300/60 from-slate-100 via-sky-50 to-blue-100 dark:border-slate-500/30 dark:from-slate-900/90 dark:via-sky-950/45 dark:to-blue-950/65",
      iconBubble: "bg-slate-200/80 text-slate-700 dark:bg-slate-200/12 dark:text-slate-100",
    };
  }

  return {
    card: "border-amber-300/60 from-amber-100 via-yellow-50 to-orange-100 dark:border-amber-500/30 dark:from-amber-950/70 dark:via-yellow-950/35 dark:to-orange-950/70",
    iconBubble: "bg-amber-200/80 text-amber-800 dark:bg-amber-300/18 dark:text-amber-100",
  };
}

export function GetSfWeatherToolRenderer({
  part,
  formatValue,
  isInitialMessage,
}: ToolRendererProps) {
  const output = toolOutput(part);
  const errorText = hasError(part);

  if (errorText || !isWeatherToolOutput(output)) {
    return (
      <DefaultToolRenderer
        part={part}
        formatValue={formatValue}
        isInitialMessage={isInitialMessage}
      />
    );
  }

  const location = typeof output.location === "string" ? output.location : "San Francisco, CA";
  const conditions = typeof output.conditions === "string" ? output.conditions : "Unknown";
  const source = typeof output.source === "string" ? output.source : "tool";
  const temperature =
    typeof output.temperature_f === "number" || typeof output.temperature_f === "string"
      ? `${output.temperature_f}`
      : "--";

  const ConditionIcon = weatherConditionIcon(conditions);
  const theme = weatherTheme(conditions);

  return (
    <ToolRendererFrame part={part} title="Weather">
      <section
        className={`relative overflow-hidden rounded-2xl border bg-gradient-to-br p-4 shadow-sm ${theme.card}`}
      >
        <div className="pointer-events-none absolute -right-10 -top-10 size-28 rounded-full bg-background/40 blur-xl dark:bg-foreground/8" />
        <div className="pointer-events-none absolute -left-12 bottom-0 size-24 rounded-full bg-background/30 blur-xl dark:bg-foreground/6" />

        <div className="relative flex items-start justify-between gap-3">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.12em] text-muted-foreground">
              San Francisco
            </p>
            <p className="text-sm font-medium text-foreground/85">{location}</p>
          </div>

          <span className={`rounded-full p-2 shadow-sm motion-safe:animate-pulse ${theme.iconBubble}`}>
            <ConditionIcon className="size-5" aria-hidden />
          </span>
        </div>

        <div className="relative mt-4">
          <div className="flex items-end gap-1">
            <p className="text-5xl font-black leading-none tracking-tight text-foreground">{temperature}</p>
            <p className="pb-1 text-xl font-semibold text-foreground/80">F</p>
          </div>
          <p className="mt-1 text-sm font-medium text-foreground/90">{conditions}</p>
        </div>

        <div className="relative mt-4 grid grid-cols-1 gap-2 text-xs sm:grid-cols-2">
          <div className="rounded-xl border bg-background/70 p-2.5 backdrop-blur-sm dark:bg-background/20">
            <p className="font-medium text-muted-foreground">Forecast</p>
            <p className="text-sm font-semibold">Current conditions</p>
          </div>
          <div className="rounded-xl border bg-background/70 p-2.5 backdrop-blur-sm dark:bg-background/20">
            <p className="font-medium text-muted-foreground">Source</p>
            <p className="text-sm">{source}</p>
          </div>
        </div>
      </section>

      <ToolOutputAccordion title="Tool details" value={output} formatValue={formatValue} />
    </ToolRendererFrame>
  );
}
