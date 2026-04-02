import type { ChatRecord, PersistedMessage } from "@/lib/chats";
import { ChatPanel } from "@/components/chats/ChatPanel";

type ChatShowProps = {
  chat: ChatRecord;
  messages: PersistedMessage[];
};

export default function ChatsShow({ chat, messages: initialMessages }: ChatShowProps) {
  return (
    <main className="min-h-screen bg-background">
      <section className="relative isolate flex min-h-screen overflow-hidden">
        <div className="absolute inset-0 -z-20 bg-[linear-gradient(180deg,rgba(248,250,252,0.98),rgba(244,247,250,0.98)_30%,rgba(239,243,247,1)_100%),radial-gradient(circle_at_top_left,rgba(15,23,42,0.08),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(21,94,99,0.1),transparent_26%),radial-gradient(circle_at_64%_56%,rgba(71,85,105,0.08),transparent_30%)] dark:bg-[linear-gradient(180deg,rgba(9,13,17,0.98),rgba(11,16,22,0.98)_30%,rgba(10,14,19,1)_100%),radial-gradient(circle_at_top_left,rgba(51,65,85,0.24),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(44,155,170,0.16),transparent_28%),radial-gradient(circle_at_64%_56%,rgba(15,23,42,0.38),transparent_34%)]" />
        <div className="absolute inset-0 -z-10 opacity-75 [background-image:radial-gradient(circle_at_1px_1px,rgba(15,23,42,0.22)_1.15px,transparent_0)] [background-size:18px_18px] dark:[background-image:radial-gradient(circle_at_1px_1px,rgba(148,163,184,0.14)_1.1px,transparent_0)] dark:opacity-85" />
        <div className="mx-auto flex min-h-screen w-full max-w-4xl overflow-hidden px-4 py-5 sm:px-6 sm:py-6">
          <ChatPanel chat={chat} messages={initialMessages} className="min-h-0 w-full" />
        </div>
      </section>
    </main>
  );
}
