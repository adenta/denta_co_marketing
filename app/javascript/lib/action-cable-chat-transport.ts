import type {
  ChatRequestOptions,
  ChatTransport,
  UIMessage,
  UIMessageChunk,
} from "ai";
import type { Subscription } from "@rails/actioncable";
import { getCableConsumer } from "@/lib/cable";

type TransportOptions = {
  chatId: string;
};

type Envelope = {
  event: "chunk" | "done" | "error";
  request_id: string;
  seq: number;
  chunk?: UIMessageChunk;
  error?: string;
};

type Pending = {
  controller: ReadableStreamDefaultController<UIMessageChunk>;
  nextSeq: number;
  buffer: Map<number, Envelope>;
  cleanup: () => void;
};

export class ActionCableChatTransport<
  UI_MESSAGE extends UIMessage,
> implements ChatTransport<UI_MESSAGE>
{
  private readonly options: TransportOptions;
  private subscription: Subscription | null = null;
  private connected: Promise<void> | null = null;
  private readonly pending = new Map<string, Pending>();

  constructor(options: TransportOptions) {
    this.options = options;
  }

  async sendMessages({
    trigger,
    chatId,
    messageId,
    messages,
    abortSignal,
    ...options
  }: {
    trigger: "submit-message" | "regenerate-message";
    chatId: string;
    messageId: string | undefined;
    messages: UI_MESSAGE[];
    abortSignal: AbortSignal | undefined;
  } & ChatRequestOptions): Promise<ReadableStream<UIMessageChunk>> {
    await this.ensureSubscribed();

    const requestId = this.generateRequestId();

    return new ReadableStream<UIMessageChunk>({
      start: controller => {
        const abortHandler = () => {
          this.cancelRequest(requestId);

          controller.enqueue({ type: "abort", reason: "user-cancelled" });
          controller.close();

          this.finishRequest(requestId);
        };

        if (abortSignal) {
          abortSignal.addEventListener("abort", abortHandler, { once: true });
        }

        this.pending.set(requestId, {
          controller,
          nextSeq: 1,
          buffer: new Map(),
          cleanup: () => {
            abortSignal?.removeEventListener("abort", abortHandler);
          },
        });

        this.subscription?.perform("start", {
          request_id: requestId,
          chat_id: chatId,
          trigger,
          message_id: messageId,
          messages,
          body: options.body,
          metadata: options.metadata,
        });
      },
      cancel: () => {
        this.cancelRequest(requestId);
        this.finishRequest(requestId);
      },
    });
  }

  async reconnectToStream(_options: {
    chatId: string;
  } & ChatRequestOptions): Promise<ReadableStream<UIMessageChunk> | null> {
    return null;
  }

  private async ensureSubscribed(): Promise<void> {
    if (this.connected) {
      return this.connected;
    }

    const consumer = getCableConsumer();

    this.connected = new Promise((resolve, reject) => {
      this.subscription = consumer.subscriptions.create(
        {
          channel: "ChatChannel",
          chat_id: this.options.chatId,
        },
        {
          connected: () => resolve(),
          rejected: () => {
            this.subscription = null;
            this.connected = null;
            reject(new Error("ChatChannel subscription was rejected."));
          },
          received: (payload: Envelope) => this.handleEnvelope(payload),
        },
      );
    });

    return this.connected;
  }

  private handleEnvelope(payload: Envelope): void {
    const pending = this.pending.get(payload.request_id);
    if (!pending) {
      return;
    }

    pending.buffer.set(payload.seq, payload);

    while (pending.buffer.has(pending.nextSeq)) {
      const current = pending.buffer.get(pending.nextSeq);
      pending.buffer.delete(pending.nextSeq);
      pending.nextSeq += 1;

      if (!current) {
        continue;
      }

      if (current.event === "chunk" && current.chunk) {
        pending.controller.enqueue(current.chunk);
        continue;
      }

      if (current.event === "error") {
        pending.controller.enqueue({
          type: "error",
          errorText: current.error || "Unknown stream error",
        });
      }

      if (current.event === "done" || current.event === "error") {
        pending.controller.close();
        this.finishRequest(payload.request_id);
        break;
      }
    }
  }

  private cancelRequest(requestId: string): void {
    this.subscription?.perform("cancel", { request_id: requestId });
  }

  private finishRequest(requestId: string): void {
    const pending = this.pending.get(requestId);
    if (!pending) {
      return;
    }

    pending.cleanup();
    this.pending.delete(requestId);
  }

  private generateRequestId(): string {
    if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
      return crypto.randomUUID();
    }

    return `req-${Date.now()}-${Math.random().toString(16).slice(2)}`;
  }
}
