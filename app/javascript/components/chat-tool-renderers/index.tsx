import type { ComponentType } from "react";
import { DefaultToolRenderer } from "@/components/chat-tool-renderers/default-tool-renderer";
import { GetSfWeatherToolRenderer } from "@/components/chat-tool-renderers/get-sf-weather-tool-renderer";
import type { ToolRendererProps } from "@/components/chat-tool-renderers/types";

function normalizeToolName(toolName: string): string {
  return toolName.replace(/^tools--/, "");
}

function buildToolRendererRegistry(
  renderers: Record<string, ComponentType<ToolRendererProps>>,
): Record<string, ComponentType<ToolRendererProps>> {
  const registry: Record<string, ComponentType<ToolRendererProps>> = {};

  for (const [toolName, renderer] of Object.entries(renderers)) {
    const normalizedToolName = normalizeToolName(toolName);
    registry[normalizedToolName] = renderer;
  }

  return registry;
}

export const toolRenderers: Record<string, ComponentType<ToolRendererProps>> =
  buildToolRendererRegistry({
    get_sf_weather: GetSfWeatherToolRenderer,
  });

export function resolveToolRenderer(toolName: string): ComponentType<ToolRendererProps> {
  const normalizedToolName = normalizeToolName(toolName);
  return toolRenderers[normalizedToolName] ?? DefaultToolRenderer;
}

export type { DynamicToolPart, ToolRendererProps } from "@/components/chat-tool-renderers/types";
