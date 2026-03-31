import ChatsIndex from "@/pages/chats/index";
import type { ChatRecord } from "@/lib/chats";

type AgentOption = {
  agent_type: string;
  label: string;
};

type HomeIndexProps = {
  chats: ChatRecord[];
  create_chat_path: string;
  available_agents: AgentOption[];
  default_agent_type: string;
};

export default function HomeIndex(props: HomeIndexProps) {
  return <ChatsIndex {...props} />;
}
