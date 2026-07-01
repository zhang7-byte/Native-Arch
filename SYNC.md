# LabTrack — Cloud Sync (Supabase)

Two-way, **local-first** sync. The app always works offline against local SQLite;
signing in turns on syncing to your Supabase account. Nothing is sent to the
network until you configure Supabase and sign in.

- Local SQLite is the offline source of truth.
- Each sync **pushes** local changes since the last cursor, then **pulls** remote
  changes, resolving conflicts by **last-writer-wins** on `updated_at`.
- Deletes propagate via a `tombstones` table.
- **Row-level security** ensures each user sees only their own rows.

No keys are hard-coded — they're passed at run time via `--dart-define`.

---

## 1. Create the Supabase project + schema

1. Create a project at <https://supabase.com> (free tier is fine).
2. Open **SQL Editor → New query**, paste the entire contents of
   [supabase/schema.sql](supabase/schema.sql), and click **Run**. This creates
   all seven tables (the six from SPEC §3 + `tombstones`), foreign keys,
   indexes, and the row-level-security policies.

## 2. Auth settings

1. Go to **Authentication → Sign In / Providers** and make sure **Email** is
   enabled (it is by default).
2. **For easy testing**, turn **off** "Confirm email" (Authentication →
   Sign In / Providers → Email → *Confirm email* = off). Then `Create account`
   signs you in immediately. If you leave it on, you must click the confirmation
   link in the email before signing in.

## 3. Find your URL and key

**Project Settings → API**:

| Setting | Goes into |
| --- | --- |
| **Project URL** (e.g. `https://abcd1234.supabase.co`) | `SUPABASE_URL` |
| **Project API keys → `anon` / publishable** | `SUPABASE_ANON_KEY` |

The anon/publishable key is safe to ship in a client build — RLS is what protects
the data. (Never use the **service_role** key in the app.)

## 4. Enable sync

**Option A — in the app (no rebuild; recommended for installed builds).**
Open **Settings → Cloud sync**, paste your **Project URL** and **anon key**,
tap **Save**, then **restart LabTrack**. The values are stored locally on the
device (never synced) and read on the next launch.

**Option B — at build time** with `--dart-define` (these take priority over the
in-app fields; read by
[lib/sync/supabase_config.dart](lib/sync/supabase_config.dart)):

```sh
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Without either, the app runs **local-only** and the account screen says so.

Tap the **cloud icon** (top-right of any list) to open **Account & sync**.

---

## 5. Test it across two devices

"Device" = any second browser profile, a second machine, or a phone — anything
running the app against the **same** Supabase project.

> Tip: for the cleanest test, start both devices from a fresh state (clear site
> data / use a new browser profile). Seed data uses stable ids, so the demo
> records dedupe across devices instead of duplicating.

1. **Device A** — run with the two `--dart-define`s. Open **Account & sync →
   Create account** (email + password). It signs in and runs an initial sync.
2. On **Device A**, create a new project, e.g. **"Sync test from A"**. (It saves
   locally immediately.)
3. On **Device A**, open **Account & sync → Sync now**. You'll see
   `Pushed N · pulled 0 · deleted 0`.
4. **Device B** — run with the same two `--dart-define`s. Open **Account & sync →
   Sign in** with the *same* email + password. It auto-syncs on sign-in.
5. Go to **Projects** on Device B — **"Sync test from A"** is now there. ✅
6. Edit or delete it on B, **Sync now**, then **Sync now** on A — the change
   appears on A (edits win by newest `updated_at`; deletes propagate via
   tombstones).

Sync also runs automatically on sign-in and whenever the app is resumed.

---

## How it works & limitations

- **Timestamps are client-authoritative.** `updated_at` is set on the writing
  device and is never overwritten server-side, so last-writer-wins is consistent
  — but device clocks should be roughly in sync.
- **Deletes:** deleting a row records a tombstone (and tombstones for any
  cascade-removed children); sync pushes tombstones and removes the server rows,
  and other devices apply them. A delete loses to a strictly newer edit on
  another device (it "resurrects").
- **Offline:** if a sync fails (no network), the local app is unaffected; the
  next sync (manual, on sign-in, or on resume) catches up.
- **Realtime:** not wired up yet — sync is incremental and on-demand. Supabase
  Realtime could later trigger pulls automatically.
- Configuration is read at build time; rebuild to change the Supabase project.
