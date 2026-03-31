# Scratch Postmark + Cloudflare Setup

These scripts are intentionally one-off and live under `tmp/`, so they are easy to throw away after we settle the exact flow.

Defaults:

- Cloudflare zone: `denta.co`
- Mail domain: `mail.denta.co`
- Return-path domain: `pm-bounces.mail.denta.co`
- DMARC record: `_dmarc.mail.denta.co` with `v=DMARC1; p=none;`

Read from `.env`:

- `POSTMARK_API_TOKEN`
- `POSTMARK_ACCOUNT_TOKEN`
- `CLOUDFLARE_TOKEN`
- Optional: `CLOUDFLARE_ZONE_NAME`
- Optional: `MAIL_DOMAIN`
- Optional: `POSTMARK_RETURN_PATH_DOMAIN`
- Optional: `DMARC_VALUE`
- Optional: `POSTMARK_SERVER_TOKEN`

`POSTMARK_ACCOUNT_TOKEN` / `POSTMARK_SERVER_TOKEN` are treated as the canonical names.
The scripts still fall back to the earlier `POSTMARK_API_TOKEN` / `POSTMARK_SENDING_TOKEN`
aliases while we are iterating.

Run step by step:

```bash
ruby tmp/postmark_mail/01_verify_tokens.rb
ruby tmp/postmark_mail/02_ensure_postmark_domain.rb
ruby tmp/postmark_mail/03_apply_cloudflare_mail_dns.rb
ruby tmp/postmark_mail/04_probe_postmark_server.rb
```

Or run all at once:

```bash
ruby tmp/postmark_mail/99_run_all.rb
```

Each step writes a JSON snapshot into `tmp/postmark_mail/output/`.
