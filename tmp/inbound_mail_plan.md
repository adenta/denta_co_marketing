# Deferred inbound mail plan

Inbound mail is intentionally excluded from the current implementation pass.

If we add inbound later, the planned approach is:

1. Install Action Mailbox using the built-in Rails flow.
2. Mount the Action Mailbox routes.
3. Add `ApplicationMailbox` with a temporary catch-all route.
4. Add a dedicated mailbox class that handles the catch-all path.
5. Add a forwarding mailer and text template modeled on Denta's current behavior.
6. Add tests covering Postmark webhook ingestion and the forwarding mailer output.
7. Keep the forwarding path isolated so recipient-based routing can replace it later without changing outbound email setup.

Operational assumptions for that future work:

- One app owns one inbound stream/domain.
- `mail.denta.co` should be treated as a single-app inbound domain while this app owns it.
- If another app needs inbound mail later, it should get its own Postmark inbound stream/domain instead of sharing this one.
