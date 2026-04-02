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
      <section className="relative isolate overflow-hidden border-b border-border/70">
        <div className="absolute inset-0 -z-20 bg-[linear-gradient(180deg,rgba(248,250,252,0.98),rgba(244,247,250,0.98)_30%,rgba(239,243,247,1)_100%),radial-gradient(circle_at_top_left,rgba(15,23,42,0.08),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(21,94,99,0.1),transparent_26%),radial-gradient(circle_at_64%_56%,rgba(71,85,105,0.08),transparent_30%)] dark:bg-[linear-gradient(180deg,rgba(9,13,17,0.98),rgba(11,16,22,0.98)_30%,rgba(10,14,19,1)_100%),radial-gradient(circle_at_top_left,rgba(51,65,85,0.24),transparent_34%),radial-gradient(circle_at_82%_18%,rgba(44,155,170,0.16),transparent_28%),radial-gradient(circle_at_64%_56%,rgba(15,23,42,0.38),transparent_34%)]" />
        <div className="absolute inset-0 -z-10 opacity-75 [background-image:radial-gradient(circle_at_1px_1px,rgba(15,23,42,0.22)_1.15px,transparent_0)] [background-size:18px_18px] [mask-image:linear-gradient(180deg,rgba(0,0,0,0.9),rgba(0,0,0,0.38)_58%,transparent)] dark:[background-image:radial-gradient(circle_at_1px_1px,rgba(148,163,184,0.14)_1.1px,transparent_0)] dark:opacity-85" />
        <div className="mx-auto max-w-4xl px-4 py-10 sm:px-6 sm:py-12">
          <Card className="border border-foreground/10 bg-card/92 py-0 shadow-[0_22px_60px_rgba(15,23,42,0.08)] dark:shadow-[0_22px_60px_rgba(0,0,0,0.34)]">
            <CardHeader className="flex flex-col gap-4 border-b bg-muted/35 py-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="space-y-1">
                <CardTitle className="text-xl">Your Chats</CardTitle>
                <p className="text-sm text-muted-foreground">
                  Reopen an existing thread or start a new one.
                </p>
              </div>
              <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                <Select value={selectedAgentType} onValueChange={setSelectedAgentType}>
                  <SelectTrigger className="w-full bg-background/85 sm:w-48">
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

            <CardContent className="py-5">
              {chats.length > 0 ? (
                <div className="space-y-2.5">
                  {chats.map(chat => (
                    <a
                      key={chat.id}
                      href={chat.path}
                      className="block rounded-xl border border-border/80 bg-background/72 px-4 py-3.5 transition-colors hover:border-primary/20 hover:bg-background"
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
                <div className="rounded-xl border border-dashed border-border/80 px-6 py-8 text-center">
                  <p className="text-sm text-muted-foreground">
                    No chats yet. Start one to create your first thread.
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </section>
    </main>
  );
}
