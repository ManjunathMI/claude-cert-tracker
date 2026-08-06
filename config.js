// ─────────────────────────────────────────────────────────────
// CONFIG — edit these two lines after creating your own free
// Supabase project. Everything else in this repo works as-is.
//
// How to get these values (2 minutes, free, no credit card):
//   1. Go to https://supabase.com → "Start your project" → sign in with GitHub
//   2. Create a new project (pick any name/region, free tier)
//   3. In the SQL editor, run the contents of supabase-setup.sql
//      (included in this repo) to create the two tables
//   4. Go to Project Settings → API
//   5. Copy "Project URL" into SUPABASE_URL below
//   6. Copy the "anon public" key into SUPABASE_ANON_KEY below
//      (this key is SAFE to expose publicly — it only allows the
//      access your Row Level Security rules permit, see the .sql file)
// ─────────────────────────────────────────────────────────────

const SUPABASE_URL = "https://qiqlfmsrgklkthqrkfef.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpcWxmbXNyZ2tsa3RocXJrZmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5OTY4NzAsImV4cCI6MjEwMTU3Mjg3MH0.BNZXR4XOHgmUWH5a7Lj4A0Htzbd-pAEli3gRYpAqKt0";

// Which plan file to load. Point this at any JSON file that follows
// the same shape as data/plan.json to reuse this tracker for a
// different course path.
const PLAN_URL = "data/plan.json";

// A short code that separates one group's tracker data from another's
// inside the same Supabase tables. Change this if you fork the repo
// for a different cohort so your data doesn't mix with anyone else's.
const ROOM_CODE = "claude-cert-2026";

// ─────────────────────────────────────────────────────────────
// ACCESS CONTROL
//
// Anyone with the link can view the board. To actually appear on it
// and start tracking progress, a person goes through two steps:
//
//   1. They enter the join code below when requesting to join.
//      This is a first filter, not the real gate — it just keeps
//      your approval queue free of noise from people who found the
//      link with no context.
//   2. Their request sits in Supabase's pending_learners table until
//      YOU approve them manually (see the README). This is the real
//      gate. Nobody can approve themselves, no matter what code they
//      enter — pending_learners has no public read/update access.
//
// Once approved, a learner can check off items and leave notes
// immediately — there's no separate edit-time lock, since approval
// already established they're meant to be here.
//
// To generate the join code hash, open any browser console
// (F12 → Console) and run:
//
//   crypto.subtle.digest("SHA-256", new TextEncoder().encode("yourphrase"))
//     .then(b => console.log(Array.from(new Uint8Array(b)).map(x => x.toString(16).padStart(2,"0")).join("")))
//
// Paste the resulting hash below. Share the PLAIN phrase with your
// group separately (chat, not the repo) — only the hash belongs here.
// ─────────────────────────────────────────────────────────────
 
const JOIN_CODE_HASH = "5136d330a996be754baf55b3efc952246af1d86ace312e536f55572fa148248f";
 
// The question shown in the join popup, alongside the code box.
// Customize this to whatever fits your group.
const JOIN_CODE_PROMPT = "Quick check — do you know why you're here? Enter the code Manju gave you:";
 