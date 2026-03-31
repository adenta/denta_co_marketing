import type { UIMessage } from "ai";

export type LinkedResource = {
  label: string;
  path: string;
};

export type PersistedMessage = {
  id: string;
  role: string;
  parts: UIMessage["parts"];
};

export type ChatRecord = {
  id: string;
  agent_type: string;
  display_name: string;
  path: string;
  updated_at: string;
  chatable_type?: string | null;
  chatable_id?: string | null;
  linked_resource: LinkedResource | null;
};
