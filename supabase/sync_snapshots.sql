-- LabTrack snapshot sync (run once in the Supabase SQL editor).
--
-- Replaces per-row replication with ONE compressed full-database snapshot per
-- user. Devices upload/download this blob with last-writer-wins, which sidesteps
-- the per-table row-level-security that kept producing 42501 errors.

create table if not exists public.sync_snapshots (
  user_id      text primary key,
  payload      text not null,            -- gzip + base64 full-database JSON
  data_version text not null default '', -- newest local updated_at (the version)
  updated_at   timestamptz not null default now()
);

alter table public.sync_snapshots enable row level security;

drop policy if exists snap_owner on public.sync_snapshots;
create policy snap_owner on public.sync_snapshots
  for all to authenticated
  using (user_id = auth.uid()::text)
  with check (user_id = auth.uid()::text);

grant all on public.sync_snapshots to authenticated;
