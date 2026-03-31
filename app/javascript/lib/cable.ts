import { createConsumer, type Consumer } from "@rails/actioncable";

let consumer: Consumer | null = null;

export function getCableConsumer(): Consumer {
  if (!consumer) {
    consumer = createConsumer();
  }

  return consumer;
}
