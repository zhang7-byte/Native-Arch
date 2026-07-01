-- LabTrack - Supabase schema for shared-workspace sync (SPEC.md Stage 7.6).
-- Paste this whole file into the Supabase SQL Editor and run it. It is
-- idempotent: safe to run on a fresh project or to upgrade an existing Stage 5
-- (per-user) database in place.
--
-- Model: data lives under a WORKSPACE. A user sees/edits rows in workspaces they
-- belong to, gated by their role:
--   * viewer - read-only
--   * editor - read + write
--   * owner  - read + write + manage members
--
-- Conventions:
--   * id is text (client-generated UUID v4); foreign keys are text.
--   * Timestamps are timestamptz, CLIENT-authoritative (last-writer-wins).
--   * Deletes are recorded in `tombstones`; the client also removes the row.
--   * Image bytes live in Storage (bucket 'images'), never in a row.

-- ====================================================================== tables

-- A shared workspace.
create table if not exists public.workspaces (
  id         text primary key,
  name       text        not null default 'My Lab',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Ties a user to a workspace with a role. user_id is the member's auth uid (text).
create table if not exists public.memberships (
  id           text primary key,
  workspace_id text        not null references public.workspaces(id) on delete cascade,
  user_id      text        not null,
  email        text        not null default '',
  role         text        not null default 'viewer',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  unique (workspace_id, user_id)
);

-- A pending invitation addressed by email; claimed into a membership on sign-in.
create table if not exists public.workspace_invites (
  id           text primary key,
  workspace_id text        not null references public.workspaces(id) on delete cascade,
  email        text        not null,
  role         text        not null default 'editor',
  invited_by   text        not null default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table if not exists public.projects (
  id          text primary key,
  title       text        not null default '',
  description text        not null default '',
  status      text        not null default 'planning',
  priority    text        not null default 'medium',
  start_date  timestamptz,
  target_date timestamptz,
  tags        text        not null default '[]',
  workspace_id text       not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  user_id     uuid        default auth.uid()
);

create table if not exists public.experiments (
  id            text primary key,
  project_id    text        not null references public.projects(id) on delete cascade,
  title         text        not null default '',
  hypothesis    text        not null default '',
  status        text        not null default 'planned',
  date          timestamptz,
  strain_ids    text        not null default '[]',
  protocol_ref  text        not null default '',
  methodology_steps text    not null default '[]',
  results_notes text        not null default '',
  conclusion    text        not null default '',
  further_plan  text        not null default '',
  data_links    text        not null default '[]',
  workspace_id  text        not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  user_id       uuid        default auth.uid()
);
-- Added post-v17 for existing deployments:
alter table public.experiments add column if not exists methodology_steps text not null default '[]';
alter table public.experiments add column if not exists conclusion        text not null default '';
alter table public.experiments add column if not exists further_plan       text not null default '';

create table if not exists public.tasks (
  id            text primary key,
  project_id    text references public.projects(id)    on delete cascade,
  experiment_id text references public.experiments(id) on delete cascade,
  title         text        not null default '',
  description   text        not null default '',
  due_date      timestamptz,
  status        text        not null default 'todo',
  priority      text        not null default 'medium',
  workspace_id  text        not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  user_id       uuid        default auth.uid()
);

create table if not exists public.strains (
  id               text primary key,
  name             text        not null default '',
  serial_number    text        not null default '',
  host_organism    text        not null default '',
  genotype         text        not null default '',
  plasmid          text        not null default '',
  construct_notes  text        not null default '',
  selection_markers text       not null default '[]',
  freezer_location text        not null default '',
  notes            text        not null default '',
  workspace_id     text        not null default '',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  user_id          uuid        default auth.uid()
);
alter table public.strains add column if not exists selection_markers text not null default '[]';
alter table public.strains add column if not exists serial_number    text not null default '';

create table if not exists public.reagents (
  id          text primary key,
  name        text        not null default '',
  supplier    text        not null default '',
  catalog_no  text        not null default '',
  lot         text        not null default '',
  location    text        not null default '',
  expiry_date timestamptz,
  quantity    text        not null default '',
  notes       text        not null default '',
  workspace_id text       not null default '',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  user_id     uuid        default auth.uid()
);

create table if not exists public.manuscripts (
  id             text primary key,
  project_id     text        not null references public.projects(id) on delete cascade,
  title          text        not null default '',
  target_journal text        not null default '',
  status         text        not null default 'drafting',
  submission_id  text        not null default '',
  submitted_date timestamptz,
  notes          text        not null default '',
  workspace_id   text        not null default '',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  user_id        uuid        default auth.uid()
);

-- A culture started from a strain; lifecycle is status-only (no hard delete).
create table if not exists public.cultures (
  id           text primary key,
  name         text        not null default '',
  strain_id    text references public.strains(id) on delete set null,
  status       text        not null default 'active',
  medium       text        not null default '',
  vessel       text        not null default '',
  started_date timestamptz,
  ended_date   timestamptz,
  notes        text        not null default '',
  inoculum_amount text     not null default '',
  selection_markers text   not null default '[]',
  parent_culture_id   text,
  parent_inoculated_at timestamptz,
  workspace_id text        not null default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  user_id      uuid        default auth.uid()
);
alter table public.cultures add column if not exists inoculum_amount      text not null default '';
alter table public.cultures add column if not exists selection_markers    text not null default '[]';
alter table public.cultures add column if not exists parent_culture_id    text;
alter table public.cultures add column if not exists parent_inoculated_at timestamptz;

-- Logged operations performed on a culture (sampling/reagent/induction/split/...).
create table if not exists public.culture_events (
  id           text primary key,
  culture_id   text references public.cultures(id) on delete cascade,
  happened_at  timestamptz,
  type         text        not null default 'note',
  agent        text        not null default '',
  amount       text        not null default '',
  note         text        not null default '',
  workspace_id text        not null default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  user_id      uuid        default auth.uid()
);

-- Oligonucleotide primer inventory.
create table if not exists public.primers (
  id            text primary key,
  name          text        not null default '',
  serial_number text        not null default '',
  sequence      text        not null default '',
  target_gene   text        not null default '',
  direction     text        not null default '',
  tm            text        not null default '',
  supplier      text        not null default '',
  notes         text        not null default '',
  workspace_id  text        not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  user_id       uuid        default auth.uid()
);
alter table public.primers add column if not exists serial_number text not null default '';

-- PI progress reports: header + written summary. The data sections are gathered
-- at PDF-export time on the client, so only these fields are stored/synced.
create table if not exists public.reports (
  id           text primary key,
  title        text        not null default 'Progress report',
  recipient    text        not null default '',
  author       text        not null default '',
  period_start timestamptz,
  period_end   timestamptz,
  summary      text        not null default '',
  project_ids    text      not null default '[]',
  experiment_ids text      not null default '[]',
  workspace_id text        not null default '',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  user_id      uuid        default auth.uid()
);
-- Upgrading: add the report selection columns if they predate this version.
alter table public.reports add column if not exists project_ids    text not null default '[]';
alter table public.reports add column if not exists experiment_ids text not null default '[]';

-- Gibson clone constructions (cloning designs). Fragments stored as JSON text.
create table if not exists public.clone_constructions (
  id                 text primary key,
  name               text        not null default '',
  notes              text        not null default '',
  backbone_name      text        not null default '',
  backbone_strain_id text        not null default '',
  enzymes            text        not null default '',
  fragments          text        not null default '[]',
  workspace_id       text        not null default '',
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  user_id            uuid        default auth.uid()
);

-- Timestamped progress-log entries on an experiment (lab-notebook style).
create table if not exists public.experiment_updates (
  id            text primary key,
  experiment_id text references public.experiments(id) on delete cascade,
  happened_at   timestamptz not null default now(),
  note          text        not null default '',
  workspace_id  text        not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  user_id       uuid        default auth.uid()
);

-- User-created Schedule events (birthdays, personal, ...).
create table if not exists public.custom_events (
  id              text primary key,
  title           text        not null default '',
  date            timestamptz,
  category        text        not null default 'personal',
  note            text        not null default '',
  repeat_annually boolean     not null default false,
  workspace_id    text        not null default '',
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  user_id         uuid        default auth.uid()
);

-- Image attachment METADATA only - bytes live in Storage, never here.
create table if not exists public.images (
  id            text primary key,
  experiment_id text references public.experiments(id)         on delete cascade,
  strain_id     text references public.strains(id)             on delete cascade,
  culture_id    text references public.cultures(id)            on delete cascade,
  update_id     text references public.experiment_updates(id)  on delete cascade,
  report_id     text references public.reports(id)             on delete cascade,
  caption       text        not null default '',
  notes         text        not null default '',
  annotations   text        not null default '[]',
  content_type  text        not null default 'image/jpeg',
  storage_path  text        not null default '',
  workspace_id  text        not null default '',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  user_id       uuid        default auth.uid()
);
-- Upgrading: add columns if the images table predates them.
alter table public.images add column if not exists culture_id text
  references public.cultures(id) on delete cascade;
alter table public.images add column if not exists update_id text
  references public.experiment_updates(id) on delete cascade;
alter table public.images add column if not exists report_id text
  references public.reports(id) on delete cascade;
alter table public.images add column if not exists notes       text not null default '';
alter table public.images add column if not exists annotations text not null default '[]';

create table if not exists public.tombstones (
  id         text primary key,
  table_name text        not null,
  deleted_at timestamptz not null default now(),
  user_id    uuid        default auth.uid()
);

-- One preferences row per user (theme / accent / density) - stays per-user.
create table if not exists public.user_settings (
  user_id      uuid primary key references auth.users(id) on delete cascade,
  theme_mode   text        not null default 'system',
  accent_color bigint      not null default 4280391816, -- 0xFF009688 (teal)
  density      text        not null default 'comfortable',
  bg_mode      text        not null default 'none',
  bg_color_a   bigint      not null default 4279070247, -- 0xFF0F2027
  bg_color_b   bigint      not null default 4281089380, -- 0xFF2C5364
  bg_image     text        not null default '',
  bg_dim       double precision not null default 0.35,
  surface_opacity double precision not null default 0.78,
  surface_blur    double precision not null default 18,
  updated_at   timestamptz not null default now()
);
-- Upgrading: add the background columns if the table predates them.
alter table public.user_settings add column if not exists bg_mode    text not null default 'none';
alter table public.user_settings add column if not exists bg_color_a bigint not null default 4279070247;
alter table public.user_settings add column if not exists bg_color_b bigint not null default 4281089380;
alter table public.user_settings add column if not exists bg_image   text not null default '';
alter table public.user_settings add column if not exists bg_dim     double precision not null default 0.35;
alter table public.user_settings add column if not exists surface_opacity double precision not null default 0.78;
alter table public.user_settings add column if not exists surface_blur    double precision not null default 18;

-- Upgrading a Stage 5 database: add workspace_id to pre-existing entity tables.
do $$
declare t text;
begin
  foreach t in array array['projects','experiments','tasks','strains',
                           'reagents','manuscripts','images','cultures','primers','reports',
                           'clone_constructions','experiment_updates','custom_events',
                           'culture_events']
  loop
    execute format(
      'alter table public.%I add column if not exists workspace_id text not null default '''';', t);
  end loop;
end $$;

-- ===================================================================== indexes
create index if not exists idx_experiments_project  on public.experiments(project_id);
create index if not exists idx_tasks_project         on public.tasks(project_id);
create index if not exists idx_tasks_experiment      on public.tasks(experiment_id);
create index if not exists idx_manuscripts_project   on public.manuscripts(project_id);
create index if not exists idx_images_experiment     on public.images(experiment_id);
create index if not exists idx_images_strain         on public.images(strain_id);
create index if not exists idx_memberships_user      on public.memberships(user_id);
create index if not exists idx_memberships_workspace on public.memberships(workspace_id);
create index if not exists idx_invites_email         on public.workspace_invites(email);
-- workspace_id + updated_at speed up scoped incremental pulls.
do $$
declare t text;
begin
  foreach t in array array['projects','experiments','tasks','strains',
                           'reagents','manuscripts','images','cultures','primers','reports',
                           'clone_constructions','experiment_updates','custom_events',
                           'culture_events']
  loop
    execute format('create index if not exists idx_%s_workspace on public.%I(workspace_id);', t, t);
    execute format('create index if not exists idx_%s_updated   on public.%I(updated_at);', t, t);
  end loop;
end $$;

-- ============================================ membership helpers (no recursion)
-- SECURITY DEFINER so they read `memberships` bypassing RLS - this is what lets
-- entity policies check membership without the policy recursing on itself.
create or replace function public.is_member(ws text) returns boolean
  language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.memberships m
                 where m.workspace_id = ws and m.user_id = auth.uid()::text);
$$;

create or replace function public.is_editor(ws text) returns boolean
  language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.memberships m
                 where m.workspace_id = ws and m.user_id = auth.uid()::text
                   and m.role in ('owner','editor'));
$$;

create or replace function public.is_owner(ws text) returns boolean
  language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.memberships m
                 where m.workspace_id = ws and m.user_id = auth.uid()::text
                   and m.role = 'owner');
$$;

-- Diagnostic: what uid/role/email the server sees for the caller's request
-- (used by the app's "Test connection" button). security INVOKER so it runs as
-- the caller, reflecting their JWT.
create or replace function public.whoami() returns json
  language sql stable security invoker set search_path = public as $$
  select json_build_object('uid', auth.uid(), 'role', auth.role(),
                           'email', auth.jwt() ->> 'email');
$$;
grant execute on function public.whoami() to anon, authenticated;

-- The creator of a workspace automatically becomes its owner.
create or replace function public.add_owner_membership() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  insert into public.memberships (id, workspace_id, user_id, email, role, created_at, updated_at)
  values (gen_random_uuid()::text, new.id, auth.uid()::text,
          coalesce((select email from auth.users where id = auth.uid()), ''),
          'owner', now(), now())
  on conflict (workspace_id, user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_workspace_owner on public.workspaces;
create trigger trg_workspace_owner after insert on public.workspaces
  for each row execute function public.add_owner_membership();

-- ========================================================= row-level security

-- Drop any Stage 5 per-user policies that may still exist.
do $$
declare t text;
begin
  foreach t in array array['projects','experiments','tasks','strains','reagents',
                           'manuscripts','images','cultures','primers','reports',
                           'clone_constructions','experiment_updates','custom_events',
                           'culture_events','tombstones','workspaces',
                           'memberships','workspace_invites']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists own_select on public.%I;', t);
    execute format('drop policy if exists own_insert on public.%I;', t);
    execute format('drop policy if exists own_update on public.%I;', t);
    execute format('drop policy if exists own_delete on public.%I;', t);
  end loop;
end $$;

-- Entity tables: read = member, write = editor (or owner).
do $$
declare t text;
begin
  foreach t in array array['projects','experiments','tasks','strains',
                           'reagents','manuscripts','images','cultures','primers','reports',
                           'clone_constructions','experiment_updates','custom_events',
                           'culture_events']
  loop
    execute format('drop policy if exists ws_select on public.%I;', t);
    execute format('drop policy if exists ws_insert on public.%I;', t);
    execute format('drop policy if exists ws_update on public.%I;', t);
    execute format('drop policy if exists ws_delete on public.%I;', t);
    execute format('create policy ws_select on public.%I for select using (public.is_member(workspace_id));', t);
    execute format('create policy ws_insert on public.%I for insert with check (public.is_editor(workspace_id));', t);
    execute format('create policy ws_update on public.%I for update using (public.is_editor(workspace_id)) with check (public.is_editor(workspace_id));', t);
    execute format('create policy ws_delete on public.%I for delete using (public.is_editor(workspace_id));', t);
  end loop;
end $$;

-- workspaces: members read; anyone authenticated may create one (trigger makes
-- them owner); owners rename/delete.
drop policy if exists ws_select on public.workspaces;
drop policy if exists ws_insert on public.workspaces;
drop policy if exists ws_update on public.workspaces;
drop policy if exists ws_delete on public.workspaces;
create policy ws_select on public.workspaces for select using (public.is_member(id));
create policy ws_insert on public.workspaces for insert to authenticated with check (true);
-- WITH CHECK is (true), not is_owner: the client pushes workspaces via UPSERT
-- (INSERT ... ON CONFLICT DO UPDATE), and Postgres evaluates the UPDATE
-- WITH CHECK even on a fresh insert — at which point the owner membership doesn't
-- exist yet (it's created by the AFTER-INSERT trigger). USING (is_owner) still
-- restricts which existing rows an update can target, so only owners can rename.
create policy ws_update on public.workspaces for update using (public.is_owner(id)) with check (true);
create policy ws_delete on public.workspaces for delete using (public.is_owner(id));

-- memberships: members see co-members; owners manage; a user may self-insert a
-- membership that matches an invite addressed to them, and may remove themselves.
drop policy if exists m_select on public.memberships;
drop policy if exists m_insert on public.memberships;
drop policy if exists m_update on public.memberships;
drop policy if exists m_delete on public.memberships;
create policy m_select on public.memberships for select using (public.is_member(workspace_id));
create policy m_insert on public.memberships for insert to authenticated with check (
  public.is_owner(workspace_id)
  or (user_id = auth.uid()::text and exists (
        select 1 from public.workspace_invites i
        where i.workspace_id = memberships.workspace_id
          and i.email = (auth.jwt() ->> 'email')
          and i.role = memberships.role)));
create policy m_update on public.memberships for update using (public.is_owner(workspace_id)) with check (public.is_owner(workspace_id));
create policy m_delete on public.memberships for delete using (
  public.is_owner(workspace_id) or user_id = auth.uid()::text);

-- invites: owners manage; the addressee can see + consume (delete) their invite.
drop policy if exists i_select on public.workspace_invites;
drop policy if exists i_insert on public.workspace_invites;
drop policy if exists i_update on public.workspace_invites;
drop policy if exists i_delete on public.workspace_invites;
create policy i_select on public.workspace_invites for select using (
  public.is_owner(workspace_id) or email = (auth.jwt() ->> 'email'));
create policy i_insert on public.workspace_invites for insert with check (public.is_owner(workspace_id));
create policy i_update on public.workspace_invites for update using (public.is_owner(workspace_id)) with check (public.is_owner(workspace_id));
create policy i_delete on public.workspace_invites for delete using (
  public.is_owner(workspace_id) or email = (auth.jwt() ->> 'email'));

-- tombstones: any authenticated user. (The real gate is the entity-table delete
-- policy above; pulling a tombstone only removes a local row you already have.)
alter table public.tombstones enable row level security;
drop policy if exists t_all on public.tombstones;
create policy t_all on public.tombstones for all to authenticated using (true) with check (true);

-- user_settings: strictly per-user.
alter table public.user_settings enable row level security;
drop policy if exists own_settings on public.user_settings;
create policy own_settings on public.user_settings for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ============================================================ storage (images)
-- Private bucket; files live under <workspace_id>/<image_id>. Members read,
-- editors write - same gate as the data.
insert into storage.buckets (id, name, public)
  values ('images', 'images', false)
  on conflict (id) do nothing;

drop policy if exists images_workspace_read on storage.objects;
drop policy if exists images_workspace_write on storage.objects;
create policy images_workspace_read on storage.objects
  for select to authenticated
  using (bucket_id = 'images' and public.is_member((storage.foldername(name))[1]));
create policy images_workspace_write on storage.objects
  for all to authenticated
  using (bucket_id = 'images' and public.is_editor((storage.foldername(name))[1]))
  with check (bucket_id = 'images' and public.is_editor((storage.foldername(name))[1]));


