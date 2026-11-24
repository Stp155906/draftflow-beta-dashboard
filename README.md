# DraftFlow beta dashboard

The live preview is at https://draftflow-beta-dashboard.vercel.app.

This repository currently contains the public dashboard interface plus the
production foundation for the customer version. It does **not** contain
customer credentials, live payment code, or TikTok secrets.

## Before enabling real users

1. Provision managed authentication and a Postgres database.
2. Apply [`database/schema.sql`](database/schema.sql).
3. Add the environment-variable names from [`.env.example`](.env.example) in
   the deployment provider; real values must never be committed.
4. Add Stripe products/webhooks for the $5 monthly and $50 annual plans.
5. Build and test the Google Drive connection in read-only mode.
6. Wait for TikTok approval before enabling public TikTok connection/upload.

See [`docs/architecture.md`](docs/architecture.md) for the safety model and
rollout order.
