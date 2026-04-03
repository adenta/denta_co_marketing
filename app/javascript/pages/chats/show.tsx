import type { ChatRecord, PersistedMessage } from "@/lib/chats";
import { ChatPanel } from "@/components/chats/ChatPanel";

type ChatShowProps = {
  chat: ChatRecord;
  messages: PersistedMessage[];
};

export default function ChatsShow({ chat, messages: initialMessages }: ChatShowProps) {
  return (
    <main className="min-h-screen bg-background">
      <section className="mx-auto flex min-h-screen w-full max-w-4xl px-4 py-5 sm:px-6 sm:py-6">
        <ChatPanel chat={chat} messages={initialMessages} className="min-h-0 w-full" />
      </section>
    </main>
  );
}
