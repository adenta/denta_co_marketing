declare module "@rails/actioncable" {
  export type Subscription = {
    perform(action: string, data?: Record<string, unknown>): unknown;
    unsubscribe(): unknown;
  };

  export type Consumer = {
    subscriptions: {
      create(
        params: Record<string, unknown>,
        mixin: Record<string, unknown>,
      ): Subscription;
    };
  };

  export function createConsumer(url?: string): Consumer;
}
