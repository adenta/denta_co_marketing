import type { UIMessage } from "ai";

type MessagePart = UIMessage["parts"][number];

export type DynamicToolPart = Extract<MessagePart, { type: "dynamic-tool" }>;

export type ToolRendererProps = {
  part: DynamicToolPart;
  formatValue: (value: unknown) => string;
  isInitialMessage: boolean;
};
