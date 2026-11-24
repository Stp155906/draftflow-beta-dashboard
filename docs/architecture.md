# DraftFlow: safe production architecture

DraftFlow will help a creator move prepared images and `post-copy.csv` from a
chosen Google Drive folder into a *TikTok inbox draft*. It is not a public
posting bot. The user finishes editing and posting inside TikTok.

## What is ready today

- Product dashboard design is deployed.
- The database structure and service-boundary plan are committed in this repo.
- Customer data, billing, Drive OAuth, and TikTok OAuth are **not live yet**.

## Service choices

| Need | Chosen direction | Why |
| --- | --- | --- |
| Web app and scheduled server work | Vercel | Existing deployed home for DraftFlow. |
| Customer accounts | Managed auth provider (Clerk preferred) | Password handling, sessions, and account recovery are not hand-built. |
| Relational data | Neon Postgres | Workflows, connection status, subscriptions, and audit history need durable relational records. |
| Billing | Stripe | Subscription status comes from webhooks, never only from a browser button. |
| Google Drive | Google OAuth | Each user grants access only to their chosen content folder. |
| TikTok | TikTok OAuth + Upload API | One connected account per customer; sends an inbox draft only after explicit consent. |

## Data we may store

- Account identifier, email, timezone, plan, and workflow schedule.
- The Drive folder ID the customer selected (not their whole Drive).
- Encrypted Google and TikTok refresh/access token records.
- A delivery log: folder/date fingerprint, TikTok publish ID, status, and error
  code. This is how duplicate drafts are prevented and failures are explained.

## Data we will not store

- Passwords.
- Customer TikTok passwords.
- Raw API secrets in browser code, GitHub, or public Google Apps Script.
- Automatic public TikTok posts.

## Required consent flow

1. Customer signs in.
2. Customer connects Google and chooses one Drive parent folder.
3. Customer connects TikTok in TikTok's official approval screen.
4. DraftFlow previews the folder/content that is ready.
5. Customer explicitly tells DraftFlow to send the draft, or enables a clearly
   disclosed recurring delivery preference that meets TikTok's approved product
   requirements.
6. TikTok sends the creator an inbox notification; they edit and post in TikTok.

## Rollout order

1. Provision managed auth + Postgres. Apply `database/schema.sql`.
2. Add sign-up/sign-in and protect the dashboard.
3. Add Stripe products: $5 monthly and $50 annual. Use webhook-driven access.
4. Add Google Drive OAuth and folder picker. Start read-only.
5. Add workflow creation, preview, validation, duplicate detection, and email
   alerts. Test with the owner and one invited beta creator.
6. After TikTok approves the public production use case, enable TikTok OAuth
   and Upload API delivery for the beta cohort.
7. Before public launch, publish DraftFlow-specific Terms, Privacy, data
   deletion instructions, and support contact—not the private Studio Post
   Uploader pages.

## Non-negotiable safety rules

- A server route, never browser JavaScript, handles OAuth exchanges and tokens.
- Tokens are encrypted at rest and never logged.
- Every database operation is scoped to the signed-in user.
- A run cannot be marked delivered until TikTok confirms inbox delivery.
- Missing media, malformed CSV, expired access, or any API error emails the
  owner and does not send a substitute or older post.
- Maximum allowed delivery frequency is two drafts/day/customer.

