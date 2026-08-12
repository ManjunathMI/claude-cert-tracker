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

-- Feedback left on the welcome page ("would this help for other
-- courses?"). Not shown publicly anywhere in the app — you read it
-- directly in Supabase's Table Editor.
create table if not exists feedback (
  id bigint generated always as identity primary key,
  room_code text not null,
  learner_name text,
  message text not null,
  created_at timestamptz not null default now()
);

alter table learners enable row level security;
alter table pending_learners enable row level security;
alter table progress enable row level security;
alter table notes enable row level security;
alter table feedback enable row level security;

-- Anyone can read the public roster and progress/notes.
create policy "public read learners" on learners for select using (true);
create policy "public read progress" on progress for select using (true);
create policy "public read notes" on notes for select using (true);

-- Anyone can SUBMIT a join request (insert into pending_learners),
-- but nobody except you, working directly in the Supabase Table Editor,
-- can move a row from 'pending' to 'approved'. There is intentionally
-- no public read/update policy on pending_learners — visitors can
-- write a request but can never read the queue or approve themselves.
-- Name-uniqueness checks go through the is_name_taken() function below
-- instead, which answers true/false without exposing any row content.
create policy "public submit join request" on pending_learners for insert with check (status = 'pending');

-- Anyone can write progress and notes once approved — the app checks
-- learner_name against the public learners table before allowing this.
create policy "public write progress" on progress for insert with check (true);
create policy "public update progress" on progress for update using (true);
create policy "public write notes" on notes for insert with check (true);

-- Anyone can leave feedback; nobody can read it back except you,
-- directly in Supabase.
create policy "public submit feedback" on feedback for insert with check (true);

grant select on public.learners to anon;
grant insert on public.pending_learners to anon;
grant select, insert, update on public.progress to anon;
grant select, insert on public.notes to anon;
grant insert on public.feedback to anon;
grant usage, select on all sequences in schema public to anon;

-- ─────────────────────────────────────────────────────────────
-- NAME AVAILABILITY CHECK
--
-- The welcome page needs to know if a name is already taken — either
-- already approved, or already sitting in the pending queue — so it
-- can tell a new visitor to pick something unique. Rather than give
-- anon read access to the pending queue (which would expose who else
-- is waiting), this function answers only true/false.
-- ─────────────────────────────────────────────────────────────
create or replace function is_name_taken(p_room_code text, p_name text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(
    select 1 from learners
    where room_code = p_room_code and learner_name = p_name
  ) or exists(
    select 1 from pending_learners
    where room_code = p_room_code and learner_name = p_name and status in ('pending','approved')
  );
$$;

grant execute on function is_name_taken(text, text) to anon;

-- ─────────────────────────────────────────────────────────────
-- APPROVAL STATUS CHECK
--
-- The welcome page also needs to know, for a name someone typed,
-- whether it's approved (send them to the tracker), still pending
-- (show a waiting message), or unknown (start the join flow). This
-- answers that without exposing the pending queue's contents.
-- ─────────────────────────────────────────────────────────────
create or replace function check_learner_status(p_room_code text, p_name text)
returns text
language sql
security definer
set search_path = public
as $$
  select case
    when exists(select 1 from learners where room_code = p_room_code and learner_name = p_name)
      then 'approved'
    when exists(select 1 from pending_learners where room_code = p_room_code and learner_name = p_name and status = 'pending')
      then 'pending'
    when exists(select 1 from pending_learners where room_code = p_room_code and learner_name = p_name and status = 'rejected')
      then 'rejected'
    else 'unknown'
  end;
$$;

grant execute on function check_learner_status(text, text) to anon;

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