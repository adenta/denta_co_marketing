import { ToolOutput } from "@/components/ai-elements/tool";
import type { ToolRendererProps } from "@/components/chat-tool-renderers/types";
import {
  hasError,
  toolOutput,
  ToolRendererFrame,
} from "@/components/chat-tool-renderers/shared";

export function DefaultToolRenderer({ part, formatValue }: ToolRendererProps) {
  const output = toolOutput(part);
  const errorText = hasError(part);

  return (
    <ToolRendererFrame part={part}>
      <ToolOutput output={output} errorText={errorText} />
    </ToolRendererFrame>
  );
}
