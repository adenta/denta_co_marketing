module ChatContinuation
  class Broadcaster
    def initialize(chat:, request_id:, broadcaster:)
      @chat = chat
      @request_id = request_id
      @broadcaster = broadcaster
      @sequence = 0
    end

    def chunk(**chunk)
      broadcast(event: "chunk", chunk: chunk)
    end

    def done
      broadcast(event: "done")
    end

    def error(message)
      broadcast(event: "error", error: message)
    end

    private

    attr_reader :broadcaster, :chat, :request_id

    def broadcast(payload)
      broadcaster.broadcast_to(chat, payload.merge(request_id: request_id, seq: next_sequence))
    end

    def next_sequence
      @sequence += 1
    end
  end
end
