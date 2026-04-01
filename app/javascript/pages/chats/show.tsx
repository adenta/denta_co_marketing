import type { ChatRecord, PersistedMessage } from "@/lib/chats";
import { ChatPanel } from "@/components/chats/ChatPanel";

type ChatShowProps = {
  chat: ChatRecord;
  messages: PersistedMessage[];
};

export default function ChatsShow({ chat, messages: initialMessages }: ChatShowProps) {
  return (
    <main className="mx-auto flex h-screen max-w-3xl overflow-hidden px-4 py-6">
      <ChatPanel chat={chat} messages={initialMessages} className="min-h-0 w-full" />
    </main>
  );
}
