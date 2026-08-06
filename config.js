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

const SUPABASE_URL = https://qiqlfmsrgklkthqrkfef.supabase.co;
const SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpcWxmbXNyZ2tsa3RocXJrZmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5OTY4NzAsImV4cCI6MjEwMTU3Mjg3MH0.BNZXR4XOHgmUWH5a7Lj4A0Htzbd-pAEli3gRYpAqKt0;

// Which plan file to load. Point this at any JSON file that follows
// the same shape as data/plan.json to reuse this tracker for a
// different course path.
const PLAN_URL = "data/plan.json";

// A short code that separates one group's tracker data from another's
// inside the same Supabase tables. Change this if you fork the repo
// for a different cohort so your data doesn't mix with anyone else's.
const ROOM_CODE = "claude-cert-2026";
