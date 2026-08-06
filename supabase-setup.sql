-- Run this once in your Supabase project's SQL editor
-- (Project → SQL Editor → New query → paste this → Run)
--
-- This creates three tables:
--   learners  — every name that has ever joined this board, visible
--               immediately even before they check anything off
--   progress  — which learner has completed which item
--   notes     — per-item notes learners leave for each other
--
-- Reads are fully open (anyone with the link can see the board).
-- Writes are allowed by policy for approved learners; the app itself
-- checks a learner is approved (present in the learners table) before
-- ever sending a write. New join requests go through a separate
-- approval queue — see pending_learners below.

create table if not exists learners (
  id bigint generated always as identity primary key,
  room_code text not null,
  learner_name text not null,
  joined_at timestamptz not null default now(),
  unique (room_code, learner_name)
);

-- New learners land here first. Nothing in this table is public-facing —
-- it exists purely so you (the admin) can review and approve names
-- before they ever appear on the board.
create table if not exists pending_learners (
  id bigint generated always as identity primary key,
  room_code text not null,
  learner_name text not null,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  requested_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (room_code, learner_name)
);

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

alter table learners enable row level security;
alter table pending_learners enable row level security;
alter table progress enable row level security;
alter table notes enable row level security;

-- Anyone can read the public roster and progress/notes.
create policy "public read learners" on learners for select using (true);
create policy "public read progress" on progress for select using (true);
create policy "public read notes" on notes for select using (true);

-- Anyone can SUBMIT a join request (insert into pending_learners),
-- but nobody except you, working directly in the Supabase Table Editor,
-- can move a row from 'pending' to 'approved'. There is intentionally
-- no public update/select policy on pending_learners — visitors can
-- write a request but can never read the queue or approve themselves.
create policy "public submit join request" on pending_learners for insert with check (status = 'pending');

-- Anyone can write progress and notes once approved — the app checks
-- learner_name against the public learners table before allowing this.
create policy "public write progress" on progress for insert with check (true);
create policy "public update progress" on progress for update using (true);
create policy "public write notes" on notes for insert with check (true);

grant select on public.learners to anon;
grant select, insert on public.pending_learners to anon;
grant select, insert, update on public.progress to anon;
grant select, insert on public.notes to anon;
grant usage, select on all sequences in schema public to anon;

-- ─────────────────────────────────────────────────────────────
-- HOW TO APPROVE A NEW LEARNER (do this manually, per request):
--
-- 1. In Supabase, go to Table Editor → pending_learners
-- 2. Find the row with status = 'pending' for the name you recognize
-- 3. Run this, swapping in their name:
--
--    with moved as (
--      update pending_learners
--      set status = 'approved', decided_at = now()
--      where learner_name = 'Their Name' and room_code = 'claude-cert-2026'
--      returning room_code, learner_name
--    )
--    insert into learners (room_code, learner_name)
--    select room_code, learner_name from moved;
--
-- 4. Their name now appears on the public board. That's it.
--
-- To reject someone instead, just:
--    update pending_learners set status = 'rejected', decided_at = now()
--    where learner_name = 'Their Name' and room_code = 'claude-cert-2026';
-- ─────────────────────────────────────────────────────────────