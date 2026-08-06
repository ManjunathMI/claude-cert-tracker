-- Run this once in your Supabase project's SQL editor
-- (Project → SQL Editor → New query → paste this → Run)
--
-- This creates two small tables and locks them down with Row Level
-- Security so that the public "anon" key (which is safe to put in
-- client-side code) can only insert/select rows, never run raw SQL
-- or touch anything outside these two tables.

create table if not exists progress (
  id bigint generated always as identity primary key,
  room_code text not null,
  item_key text not null,
  learner_name text not null,
  done boolean not null default true,
  updated_at timestamptz not null default now(),
  unique (room_code, item_key, learner_name)
);

create table if not exists notes (
  id bigint generated always as identity primary key,
  room_code text not null,
  item_key text not null,
  learner_name text not null,
  note_text text not null,
  created_at timestamptz not null default now()
);

alter table progress enable row level security;
alter table notes enable row level security;

-- Anyone with the anon key can read and write rows.
-- This is intentional: this app has no login system, it's meant for
-- a small trusted group sharing one link. Don't put sensitive data
-- in learner_name or note_text.
create policy "public read progress" on progress for select using (true);
create policy "public write progress" on progress for insert with check (true);
create policy "public update progress" on progress for update using (true);

create policy "public read notes" on notes for select using (true);
create policy "public write notes" on notes for insert with check (true);
