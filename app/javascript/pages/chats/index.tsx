import { useMemo, useState } from "react";
import { useApiRequest } from "@/hooks/useApiRequest";
import { useToast } from "@/hooks/useToast";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type { ChatRecord } from "@/lib/chats";

type AgentOption = {
  agent_type: string;
  label: string;
};

type ChatIndexProps = {
  chats: ChatRecord[];
  create_chat_path: string;
  available_agents?: AgentOption[];
  default_agent_type?: string;
};

export default function ChatsIndex({
  chats,
  create_chat_path,
  available_agents = [],
  default_agent_type = "",
}: ChatIndexProps) {
  const toast = useToast();
  const [selectedAgentType, setSelectedAgentType] = useState(default_agent_type);
  const formatter = useMemo(
    () =>
      new Intl.DateTimeFormat(undefined, {
        dateStyle: "medium",
        timeStyle: "short",
      }),
    [],
  );

  const { loading: isStarting, makeRequest } = useApiRequest<{ id: string; redirect_to: string }>({
    onSuccess: payload => {
      if (!payload?.redirect_to) {
        toast.error("Chat creation did not return a redirect target.");
        return;
      }

      window.location.assign(payload.redirect_to);
    },
    onError: (message, _errors, payload) => {
      if (payload?.redirect_to) {
        window.location.assign(payload.redirect_to);
        return;
      }

      toast.error(message);
    },
  });

  const startChat = async () => {
    await makeRequest(
      "POST",
      create_chat_path,
      selectedAgentType ? { agent_type: selectedAgentType } : {},
    );
  };

  return (
    <main className="min-h-screen bg-background">
      <section className="mx-auto max-w-4xl px-4 py-8 sm:px-6 sm:py-10">
        <Card>
          <CardHeader className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-1">
              <CardTitle className="text-xl">Your Chats</CardTitle>
              <p className="text-sm text-muted-foreground">
                Reopen an existing thread or start a new one.
              </p>
            </div>
            <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
              <Select value={selectedAgentType} onValueChange={setSelectedAgentType}>
                <SelectTrigger className="w-full sm:w-48">
                  <SelectValue placeholder="Choose an agent" />
                </SelectTrigger>
                <SelectContent>
                  {available_agents.map(agent => (
                    <SelectItem key={agent.agent_type} value={agent.agent_type}>
                      {agent.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Button
                type="button"
                onClick={startChat}
                disabled={isStarting || available_agents.length === 0}
                className="sm:min-w-28"
              >
                {isStarting ? "Starting..." : "Start Chat"}
              </Button>
            </div>
          </CardHeader>

          <CardContent>
            {chats.length > 0 ? (
              <div className="space-y-2.5">
                {chats.map(chat => (
                  <a
                    key={chat.id}
                    href={chat.path}
                    className="block rounded-lg border px-4 py-3 transition-colors hover:bg-muted/40"
                  >
                    <div className="flex items-center justify-between gap-3">
                      <div>
                        <p className="font-medium text-foreground">{chat.display_name}</p>
                        <p className="text-sm text-muted-foreground">
                          Updated {formatter.format(new Date(chat.updated_at))}
                        </p>
                      </div>
                      <span className="text-sm text-primary">Open</span>
                    </div>
                  </a>
                ))}
              </div>
            ) : (
              <div className="rounded-lg border border-dashed px-6 py-8 text-center">
                <p className="text-sm text-muted-foreground">
                  No chats yet. Start one to create your first thread.
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </section>
    </main>
  );
}
