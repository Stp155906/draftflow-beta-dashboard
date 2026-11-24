-- DraftFlow production data model (Postgres / Neon)
--
-- This schema intentionally stores references and encrypted OAuth-token payloads,
-- never plaintext passwords or credentials. Authentication is handled by a
-- managed identity provider. All application queries must be scoped to the
-- authenticated user's `auth_user_id`.

create extension if not exists pgcrypto;

create type subscription_status as enum (
  'trialing', 'active', 'past_due', 'canceled', 'unpaid'
);

create type connection_status as enum (
  'pending', 'connected', 'expired', 'revoked', 'error'
);

create type workflow_status as enum (
  'active', 'paused', 'needs_attention'
);

create type run_status as enum (
  'queued', 'checking_folder', 'ready_for_consent', 'uploading',
  'inbox_delivered', 'skipped', 'failed', 'canceled'
);

create table app_users (
  id uuid primary key default gen_random_uuid(),
  auth_user_id text not null unique,
  email text not null,
  display_name text,
  timezone text not null default 'America/Aruba',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_users(id) on delete cascade,
  stripe_customer_id text unique,
  stripe_subscription_id text unique,
  plan_code text not null check (plan_code in ('monthly', 'annual', 'beta')),
  status subscription_status not null default 'trialing',
  current_period_end timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table google_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references app_users(id) on delete cascade,
  google_subject_id text not null,
  email text,
  encrypted_refresh_token bytea not null,
  status connection_status not null default 'pending',
  granted_scopes text[] not null default '{}',
  connected_at timestamptz,
  updated_at timestamptz not null default now()
);

create table tiktok_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references app_users(id) on delete cascade,
  tiktok_open_id text not null,
  tiktok_username text,
  encrypted_access_token bytea not null,
  encrypted_refresh_token bytea not null,
  access_token_expires_at timestamptz not null,
  refresh_token_expires_at timestamptz,
  status connection_status not null default 'pending',
  granted_scopes text[] not null default '{}',
  connected_at timestamptz,
  updated_at timestamptz not null default now(),
  unique (tiktok_open_id)
);

create table workflows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references app_users(id) on delete cascade,
  name text not null,
  drive_parent_folder_id text not null,
  drive_parent_folder_name text,
  timezone text not null default 'America/Aruba',
  scheduled_times time[] not null,
  max_daily_drafts smallint not null default 1 check (max_daily_drafts between 1 and 2),
  expected_format text not null check (expected_format in ('single_image', 'carousel')),
  csv_file_name text not null default 'post-copy.csv',
  status workflow_status not null default 'paused',
  alert_email text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table workflow_runs (
  id uuid primary key default gen_random_uuid(),
  workflow_id uuid not null references workflows(id) on delete cascade,
  scheduled_for timestamptz not null,
  source_date date not null,
  source_folder_id text,
  source_fingerprint text,
  tiktok_publish_id text,
  status run_status not null default 'queued',
  failure_code text,
  failure_detail text,
  consented_at timestamptz,
  inbox_delivered_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (workflow_id, source_date, source_fingerprint)
);

create table audit_events (
  id bigint generated always as identity primary key,
  user_id uuid references app_users(id) on delete set null,
  workflow_id uuid references workflows(id) on delete set null,
  event_type text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create index workflow_runs_workflow_created_idx
  on workflow_runs (workflow_id, created_at desc);
create index audit_events_user_created_idx
  on audit_events (user_id, created_at desc);

