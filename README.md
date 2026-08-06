# Claude Cert Tracker

A free, open-source pair-learning tracker for Anthropic's Claude courses and certifications. Two (or more) learners share one link, check off lessons as they finish them, and leave notes for each other — all synced live.

Built to prepare for the **Claude Certified Associate — Foundations** and **Claude Certified Developer — Foundations** certifications, but the course plan is a swappable JSON file, so it works for any learning path.

**Live demo:** _add your GitHub Pages URL here after deploying_

## Why this exists

Anthropic's course catalog (anthropic.skilljar.com) has no built-in way for two people to study together and see each other's progress. This fills that gap with:

- A day-by-day plan with direct links to every course, quiz, and exam
- Two-person progress tracking (see your checkmark and your partner's, side by side)
- A notes thread per lesson, for blockers or questions
- Zero backend to run yourself — hosted free on GitHub Pages, synced free on Supabase

## Stack

- Plain HTML/CSS/JS — no build step, no framework, no `node_modules`
- [Supabase](https://supabase.com) free tier as the sync backend (Postgres + REST API)
- [GitHub Pages](https://pages.github.com) for hosting

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

### 3. Fill in `config.js`

```js
const SUPABASE_URL = "https://your-project.supabase.co";
const SUPABASE_ANON_KEY = "your-anon-key";
```

The anon key is safe to commit — the SQL script locks the tables down with Row Level Security so it can only read/write the two tables this app uses.

### 4. Enable GitHub Pages

Repo → **Settings → Pages** → Source: `main` branch, `/ (root)` folder → Save.

Your tracker is now live at `https://YOUR_USERNAME.github.io/claude-cert-tracker/`.

### 5. Share the link

Send it to whoever you're studying with. Each person types their name once (stored locally in their browser) and everyone sees everyone's progress and notes.

## Using this for a different course path

Edit [`data/plan.json`](./data/plan.json) — it's a plain array of phases → days → items, each with a title, a URL, an optional `tag` (`hands` or `exam`), and time estimate. No code changes needed.

## Project structure

```
├── index.html          # the whole app — UI, rendering, Supabase calls
├── config.js            # your Supabase credentials + plan file pointer (edit this)
├── data/plan.json        # the course plan — swap this for any learning path
├── supabase-setup.sql   # run once to create the two tables + security rules
└── README.md
```

## License

MIT — use it, fork it, adapt it for your own study group.
