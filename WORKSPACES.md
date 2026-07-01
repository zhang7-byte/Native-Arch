# Shared workspaces (Stage 7.6)

LabTrack data now lives under a **workspace**. Members of a workspace see the
same projects, experiments, tasks, strains, reagents, manuscripts and images.
Access is gated by role:

| Role   | Read | Write | Manage members |
|--------|:----:|:-----:|:--------------:|
| viewer | ✅   | —     | —              |
| editor | ✅   | ✅    | —              |
| owner  | ✅   | ✅    | ✅             |

Your existing data was automatically migrated into a **default workspace ("My
Lab") that you own** — on first launch, `ensureDefaultWorkspace()` creates the
workspace and moves every pre-workspace row into it. You become its **owner** the
first time you sign in and sync (a database trigger grants the workspace creator
the owner role).

This **replaces** the Stage 5 per-user row-level security: rows are now gated by
*workspace membership + role*, not by `user_id`.

---

## 1. Apply the schema

In the Supabase dashboard → **SQL Editor**, paste and run
[`supabase/schema.sql`](supabase/schema.sql). It is idempotent and upgrades an
existing Stage 5 project in place (adds `workspace_id` to every table, creates
`workspaces` / `memberships` / `workspace_invites`, installs the membership
helper functions + owner trigger, and rewrites every policy).

It also creates a **private Storage bucket `images`** with member/editor
policies. If the bucket already exists, the `on conflict do nothing` keeps it.

Run the app pointed at your project:

```
flutter run -d chrome ^
  --dart-define=SUPABASE_URL=https://YOUR.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

---

## 2. Account A — confirm your data migrated and that you own it

1. Open the app. Go to **Workspace** (nav). You'll see **"My Lab"** as the
   current workspace and your projects/strains/etc. still present.
2. Open **Account** → sign in (or sign up) as account **A**.
3. Wait for a sync (it runs on sign-in; or background/foreground the app).
4. Back on **Workspace → Members**, you should now appear as **Owner**. (Before
   the first sync you're treated as owner locally; the sync makes it official by
   creating your owner membership server-side.)

Your projects/experiments/… now carry `workspace_id = <My Lab>` on the server.

---

## 3. Invite account B

1. As account **A**, go to **Workspace → Members → Invite** (the FAB; visible
   only to owners).
2. Enter account **B**'s email and pick a role — try **Viewer** first to see the
   read-only gate, then change it to **Editor** later.
3. Send. It appears under **Pending invites**. (Under the hood this writes a row
   to `workspace_invites`, which syncs to Supabase.)

> The invite is addressed by **email**. Account B doesn't need to exist yet — the
> invite is claimed when they first sign in with that email.

---

## 4. Account B — sign in and confirm shared data

Use a second browser profile / incognito window (so it's a separate session),
run the same `flutter run` command, then:

1. **Account** → sign up / sign in as **B** (the invited email).
2. On sign-in the app syncs. During sync it **claims** any invites addressed to
   B's email: it inserts B's membership server-side **before** pulling data, so
   row-level security then lets B pull "My Lab"'s rows.
3. Open **Projects / Strains / …** — B now sees **the same data** as A. Open an
   experiment or strain with an attached image; the file downloads from Storage
   into B's local cache and renders.
4. **Workspace → Members** shows both A (Owner) and B (their role).

> If the shared data doesn't appear on the very first sync, trigger one more sync
> (background → foreground the app, or sign out/in). The claim runs first, then
> the next pull brings the data.

---

## 5. Confirm the permissions

- **As viewer (B):** the lists are visible, but creating/editing is rejected by
  the server. (Writes are gated by `is_editor()` in RLS; a viewer's push of a new
  row is refused.)
- **Promote B to editor:** as **A**, Members → B → **Change role → Editor**.
  After both sync, B can create/edit rows and they show up for A.
- **Owner-only:** the **Invite** button and the per-member **Change role /
  Remove** menu only appear for owners. A non-owner attempting to write a
  membership/invite is refused by RLS even if the UI were bypassed.
- **Remove a member / cancel an invite:** owners can, from the Members screen.

---

## How it works (under the hood)

- **Scoping.** Every entity row has `workspace_id`. The app reads/writes the
  **current workspace** (stored locally in `sync_meta`); list queries are scoped
  with a SQL predicate that's a no-op when nothing is selected, so the same repos
  work in the app and in unit tests. Switch workspaces on the **Workspace**
  screen.
- **RLS without recursion.** `is_member()/is_editor()/is_owner()` are
  `SECURITY DEFINER` functions, so entity policies can check membership without
  the policy recursing on the `memberships` table.
- **Becoming owner.** A trigger on `workspaces` inserts an owner membership for
  the creator (`auth.uid()`), so the first membership doesn't need a pre-existing
  owner.
- **Claiming invites.** On sync the client finds invites matching its email,
  self-inserts the membership (RLS allows it *because a matching invite exists*),
  and deletes the invite — all before pulling workspace data.
- **Images.** Files live in Storage under `<workspace_id>/<image_id>`; the bucket
  policies grant read to members and write to editors — the same gate as the
  data. Bytes never touch Postgres.

## Tests

`flutter test test/workspace_test.dart` covers the local guarantees: the default
workspace is created and pre-workspace rows are backfilled into it; reads/writes
scope to the current workspace; roles resolve correctly; and member/invite
management writes rows and tombstones. (The cross-account RLS/claim path needs a
live Supabase project, per the steps above.)
