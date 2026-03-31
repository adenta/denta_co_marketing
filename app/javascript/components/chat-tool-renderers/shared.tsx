import type { ReactNode } from "react";
import {
  Tool,
  ToolContent,
  ToolHeader,
  ToolInput,
} from "@/components/ai-elements/tool";
import { cn } from "@/lib/utils";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import type { DynamicToolPart } from "@/components/chat-tool-renderers/types";

export function toolOutput(part: DynamicToolPart): unknown | undefined {
  if ("output" in part && part.output !== undefined) {
    return part.output;
  }

  return undefined;
}

export function hasError(part: DynamicToolPart): string | undefined {
  if ("errorText" in part && part.errorText) {
    return part.errorText;
  }

  return undefined;
}

export function toolDefaultOpen(part: DynamicToolPart): boolean {
  return false;
}

export function ToolRendererFrame({
  part,
  title,
  className,
  contentClassName,
  children,
}: {
  part: DynamicToolPart;
  title?: string;
  className?: string;
  contentClassName?: string;
  children: ReactNode;
}) {
  return (
    <Tool defaultOpen={toolDefaultOpen(part)} className={className}>
      <ToolHeader
        type={part.type}
        state={part.state}
        toolName={part.toolName}
        title={title}
      />
      <ToolContent className={cn("space-y-4", contentClassName)}>
        <ToolInput input={part.input} />
        {children}
      </ToolContent>
    </Tool>
  );
}

export function ToolOutputAccordion({
  title = "Tool output",
  value,
  formatValue,
}: {
  title?: string;
  value: unknown;
  formatValue: (value: unknown) => string;
}) {
  return (
    <Accordion type="single" collapsible className="mt-2 w-full rounded bg-background px-3">
      <AccordionItem value="output" className="border-none">
        <AccordionTrigger className="py-2 text-xs font-medium uppercase tracking-wide text-muted-foreground hover:no-underline">
          {title}
        </AccordionTrigger>
        <AccordionContent className="pb-0">
          <pre className="overflow-x-auto rounded bg-muted/40 p-2 text-xs">
            {formatValue(value)}
          </pre>
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  );
}
