# Claude Cert Tracker

A free, open-source group learning tracker for Anthropic's Claude courses and certifications. Any number of learners request to join one shared board, get approved by an admin, check off lessons as they finish them, and leave notes for each other — all synced live on a public leaderboard.

Built to prepare for the **Claude Certified Associate — Foundations** and **Claude Certified Developer — Foundations** certifications, but the course plan is a swappable JSON file, so it works for any learning path.

**Live demo:** _add your GitHub Pages URL here after deploying_

## Why this exists

Anthropic's course catalog (anthropic.skilljar.com) has no built-in way for a group to study together and see everyone's progress. This fills that gap with:

- A day-by-day plan with direct links to every course, quiz, and exam
- A leaderboard listing every approved learner, ranked by lessons completed
- New learners request to join; they only appear on the board once the admin approves them directly in Supabase — no extra admin panel needed
- A notes thread per lesson, for blockers or questions
- Anyone with the link can view the whole board without joining
- Zero backend to run yourself — hosted free on GitHub Pages, synced free on Supabase

## Stack

- Plain HTML/CSS/JS — no build step, no framework, no `node_modules`
- [Supabase](https://supabase.com) free tier as the sync backend (Postgres + REST API)
- [GitHub Pages](https://pages.github.com) for hosting

## How access works, in order

This app has two checkpoints between "found the link" and "actively tracking progress":

| # | Checkpoint | Required? | Controlled by |
|---|---|---|---|
| 1 | **Join code** — shown before someone can submit a request to join | Optional, recommended | `JOIN_CODE_HASH` in `config.js` |
| 2 | **Admin approval** — every join request sits in a queue until the admin approves it | Always on, not configurable | You, working directly in Supabase |

Checkpoint 2 is the real gate: `pending_learners` has no public read or update policy, so nobody can approve themselves no matter what code they enter. Checkpoint 1 just keeps that approval queue from filling with noise. Once someone is approved, they can check off items and leave notes immediately — there's no separate lock at edit time, since approval already established they're meant to be here.

## Setup (10 minutes, all free)

### 1. Fork or clone this repo

```bash
git clone https://github.com/YOUR_USERNAME/claude-cert-tracker.git
cd claude-cert-tracker
```

### 2. Create a free Supabase project

1. Go to [supabase.com](https://supabase.com) → sign in with GitHub → New project
2. Any name/region, free tier is enough
3. Once created, open the **SQL Editor** and run everything in [`supabase-setup.sql`](./supabase-setup.sql)
4. Go to **Project Settings → API** and copy:
   - **Project URL**
   - **anon public** key

### 3. Fill in your Supabase credentials — required

In `config.js`:

```js
const SUPABASE_URL = "https://your-project.supabase.co";
const SUPABASE_ANON_KEY = "your-anon-key";
```

The anon key is safe to commit — the SQL script locks the tables down with Row Level Security so it can only read/write the tables this app uses. **Both values must be wrapped in quotes** — a bare URL without quotes breaks the whole page with a JavaScript syntax error.

### 4. Set a join code — optional, recommended

Generate a hash — open any browser console (F12 → Console) and run:

```js
crypto.subtle.digest("SHA-256", new TextEncoder().encode("iKnowManju"))
  .then(b => console.log(Array.from(new Uint8Array(b)).map(x => x.toString(16).padStart(2,"0")).join("")))
```

Paste the result into `config.js`:

```js
const JOIN_CODE_HASH = "the hash you just generated";
const JOIN_CODE_PROMPT = "Quick check — do you know why you're here? Enter the code:";
```

**If you skip this:** leave `JOIN_CODE_HASH` as the placeholder text. Anyone can submit a join request with no code, straight into your approval queue — you still approve every name manually in step 5, so this is safe to skip, just noisier.

Share the plain phrase (not the hash) with your group separately — chat, email, whatever — never in the repo.

### 5. Approving new learners — always required, this is the real gate

When someone submits a join request, it lands in the `pending_learners` table — not the public board. To approve them:

1. In Supabase, go to **Table Editor → pending_learners**
2. Find their row (`status = 'pending'`)
3. Open the **SQL Editor** and run, swapping in their name:

```sql
with moved as (
  update pending_learners
  set status = 'approved', decided_at = now()
  where learner_name = 'Their Name' and room_code = 'claude-cert-2026'
  returning room_code, learner_name
)
insert into learners (room_code, learner_name)
select room_code, learner_name from moved;
```

Their name now appears on the public board immediately. Their browser checks for approval automatically every 15 seconds, so they don't need to do anything once you've approved them — just wait, or refresh.

To reject someone instead:

```sql
update pending_learners set status = 'rejected', decided_at = now()
where learner_name = 'Their Name' and room_code = 'claude-cert-2026';
```

### 6. Enable GitHub Pages

Repo → **Settings → Pages** → Source: `main` branch, `/ (root)` folder → Save.

Your tracker is now live at `https://YOUR_USERNAME.github.io/claude-cert-tracker/`.

### 7. Share the link

Send it to your study group, along with the join code if you set one. Each person requests to join, you approve them from Supabase, and they appear on the leaderboard.

## Using this for a different course path

Edit [`data/plan.json`](./data/plan.json) — it's a plain array of phases → days → items, each with a title, a URL, an optional `tag` (`hands` or `exam`), and time estimate. No code changes needed.

## Project structure

```
├── index.html          # the whole app — UI, rendering, Supabase calls
├── config.js            # your Supabase credentials + access control + plan pointer (edit this)
├── data/plan.json        # the course plan — swap this for any learning path
├── supabase-setup.sql   # run once to create the tables + security rules
└── README.md
```

## Security notes

- The Supabase anon key is meant to be public — Supabase's Row Level Security policies are the actual access boundary, not secrecy of the key. This is normal and expected for client-side apps.
- The join code (checkpoint 1) is light protection, not strong security: it's checked client-side and its hash lives in a public file. It filters out casual/accidental access, not a determined attacker.
- The approval queue (checkpoint 2) is the strongest control here: `pending_learners` has no public read or update policy, so a visitor can submit a request but can never read the queue, see other pending names, or approve themselves — only you, working directly in Supabase, can move someone from pending to approved.
- If you need real access control beyond this, add [Supabase Auth](https://supabase.com/docs/guides/auth) instead.

## License

MIT — use it, fork it, adapt it for your own study group.