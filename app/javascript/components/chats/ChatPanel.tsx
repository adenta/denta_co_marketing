import { FormEvent, useMemo, useState } from "react";
import { useChat } from "@ai-sdk/react";
import type { UIMessage } from "ai";
import {
  Message,
  MessageContent,
  MessageResponse,
} from "@/components/ai-elements/message";
import { ActionCableChatTransport } from "@/lib/action-cable-chat-transport";
import type { ChatRecord, PersistedMessage } from "@/lib/chats";
import {
  Conversation,
  ConversationContent,
  ConversationEmptyState,
  ConversationScrollButton,
} from "@/components/ai-elements/conversation";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { resolveToolRenderer } from "@/components/chat-tool-renderers";
import { cn } from "@/lib/utils";

type ChatPanelProps = {
  chat: ChatRecord;
  messages: PersistedMessage[];
  title?: string;
  description?: string;
  className?: string;
  contentClassName?: string;
  messagesClassName?: string;
};

const SUPPORTED_ROLES = new Set<UIMessage["role"]>(["assistant", "user", "system"]);
const DEFAULT_TITLE_PREFIX = "Chat";

function toUiMessageRole(role: string): UIMessage["role"] {
  return SUPPORTED_ROLES.has(role as UIMessage["role"])
    ? (role as UIMessage["role"])
    : "assistant";
}

function formatValue(value: unknown): string {
  if (typeof value === "string") {
    return value;
  }

  return JSON.stringify(value, null, 2);
}

function normalizedPath(path: string): string {
  try {
    return new URL(path, window.location.origin).pathname;
  } catch {
    return path;
  }
}

export function ChatPanel({
  chat,
  messages: initialMessages,
  title,
  description,
  className,
  contentClassName,
  messagesClassName,
}: ChatPanelProps) {
  const [input, setInput] = useState("");
  const initialMessageIds = useMemo(
    () => new Set(initialMessages.map(message => message.id)),
    [initialMessages],
  );
  const linkedResource = chat.linked_resource ?? undefined;
  const showLinkedResource =
    !!linkedResource &&
    (typeof window === "undefined" ||
      normalizedPath(linkedResource.path) !== window.location.pathname);
  const resolvedTitle = title || chat.display_name || `${DEFAULT_TITLE_PREFIX} ${chat.id}`;

  const initialUiMessages = useMemo<UIMessage[]>(
    () =>
      initialMessages.map(message => ({
        ...message,
        role: toUiMessageRole(message.role),
      })),
    [initialMessages],
  );

  const transport = useMemo(
    () =>
      new ActionCableChatTransport({
        chatId: chat.id,
      }),
    [chat.id],
  );

  const { messages, sendMessage, status, stop } = useChat({
    id: chat.id,
    messages: initialUiMessages,
    transport,
  });

  const onSubmit = async (event: FormEvent) => {
    event.preventDefault();
    const text = input.trim();
    if (!text) {
      return;
    }

    setInput("");
    await sendMessage({ text });
  };

  return (
    <Card
      className={cn(
        "flex min-h-0 flex-1 border bg-background shadow-sm",
        className,
      )}
    >
      <CardHeader className="shrink-0 space-y-2">
        <CardTitle>{resolvedTitle}</CardTitle>
        {description ? <CardDescription>{description}</CardDescription> : null}
        {showLinkedResource ? (
          <div>
            <Button type="button" size="sm" variant="outline" asChild>
              <a href={linkedResource.path}>Open {linkedResource.label}</a>
            </Button>
          </div>
        ) : null}
      </CardHeader>

      <CardContent
        className={cn("flex min-h-0 flex-1 flex-col overflow-hidden gap-4", contentClassName)}
      >
        <Conversation className={cn("min-h-0 flex-1", messagesClassName)}>
          <ConversationContent className="gap-4 p-0 pr-1">
            {messages.length > 0 ? (
              messages.map(message => (
                <Message key={message.id} from={message.role}>
                  <MessageContent>
                    {message.parts.map((part, index) => {
                      if (part.type === "text") {
                        return (
                          <MessageResponse key={`${message.id}-${index}`}>
                            {part.text}
                          </MessageResponse>
                        );
                      }

                      if (part.type === "dynamic-tool") {
                        const Renderer = resolveToolRenderer(part.toolName);

                        return (
                          <Renderer
                            key={`${message.id}-${index}`}
                            part={part}
                            formatValue={formatValue}
                            isInitialMessage={initialMessageIds.has(message.id)}
                          />
                        );
                      }

                      return null;
                    })}
                  </MessageContent>
                </Message>
              ))
            ) : (
              <ConversationEmptyState
                title="Start the conversation"
                description="Continue the conversation from this thread."
                className="rounded-2xl border border-dashed"
              />
            )}
          </ConversationContent>
          <ConversationScrollButton />
        </Conversation>
      </CardContent>

      <CardFooter className="shrink-0 flex-col items-stretch gap-3">
        <form onSubmit={onSubmit} className="flex gap-2">
          <Input
            value={input}
            onChange={event => setInput(event.target.value)}
            placeholder="Type a message"
          />
          <Button
            type="submit"
            disabled={status === "submitted" || status === "streaming"}
            className="min-w-20"
          >
            Send
          </Button>
        </form>

        <div className="flex items-center justify-between text-xs text-muted-foreground">
          <span>Status: {status}</span>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => stop()}
            disabled={status !== "submitted" && status !== "streaming"}
          >
            Stop
          </Button>
        </div>
      </CardFooter>
    </Card>
  );
}
