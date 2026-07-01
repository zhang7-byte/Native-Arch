import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'converters.dart';
import 'enums.dart';

/// Shared UUID generator. Public (not `_uuid`) because drift copies the
/// `clientDefault` expression below verbatim into the generated database
/// library, where it must be able to resolve this symbol.
const uuid = Uuid();

/// Columns shared by every table.
///
/// * `id` — a client-generated UUID v4 string primary key. UUIDs (instead of
///   autoincrement integers) let rows be created offline on multiple devices
///   without primary-key collisions, which is a prerequisite for Supabase sync.
/// * `createdAt` / `updatedAt` — bookkeeping timestamps stored as UTC. `updatedAt`
///   is the basis for last-writer-wins conflict resolution during sync and is
///   refreshed on every UPDATE by a database trigger (see database.dart).
mixin _Base on Table {
  TextColumn get id => text().clientDefault(() => uuid.v4())();
  // Stored in UTC so timestamps from devices in different timezones are
  // directly comparable (required for last-writer-wins) and map unambiguously
  // onto Postgres `timestamptz`.
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Adds `workspace_id` to entity tables so every row lives under a workspace
/// (shared-workspace model). Empty only until the one-time backfill moves
/// pre-workspace rows into the default workspace.
mixin _Scoped on Table {
  TextColumn get workspaceId => text().withDefault(const Constant(''))();
}

/// A research project — the top-level unit of work.
@DataClassName('Project')
class Projects extends Table with _Base, _Scoped {
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<ProjectStatus>()
      .withDefault(Constant(ProjectStatus.planning.name))();
  TextColumn get priority =>
      textEnum<Priority>().withDefault(Constant(Priority.medium.name))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get tags => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

/// An experiment belonging to a project.
@TableIndex(name: 'idx_experiments_project', columns: {#projectId})
@DataClassName('Experiment')
class Experiments extends Table with _Base, _Scoped {
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get hypothesis => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<ExperimentStatus>()
      .withDefault(Constant(ExperimentStatus.planned.name))();
  DateTimeColumn get date => dateTime().nullable()();

  /// Logical foreign keys to `strains.id` (which strains a run used). Stored as
  /// a JSON array per SPEC.md (the array is enough for v1, no join table); these
  /// are resolved to Strain rows in the app layer, so missing IDs degrade
  /// gracefully rather than failing a DB constraint.
  TextColumn get strainIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get protocolRef => text().withDefault(const Constant(''))();

  /// The methodology written out as ordered steps (JSON array of strings).
  TextColumn get methodologySteps => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get resultsNotes => text().withDefault(const Constant(''))();

  /// What the run concluded, and what to do next.
  TextColumn get conclusion => text().withDefault(const Constant(''))();
  TextColumn get furtherPlan => text().withDefault(const Constant(''))();
  TextColumn get dataLinks => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

/// A to-do item, optionally linked to a project and/or an experiment.
@TableIndex(name: 'idx_tasks_project', columns: {#projectId})
@TableIndex(name: 'idx_tasks_experiment', columns: {#experimentId})
@DataClassName('Task')
class Tasks extends Table with _Base, _Scoped {
  TextColumn get projectId => text()
      .nullable()
      .references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get experimentId => text()
      .nullable()
      .references(Experiments, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get status =>
      textEnum<TaskStatus>().withDefault(Constant(TaskStatus.todo.name))();
  TextColumn get priority =>
      textEnum<Priority>().withDefault(Constant(Priority.medium.name))();
}

/// A biological strain in the lab's collection (project-independent inventory).
@DataClassName('Strain')
class Strains extends Table with _Base, _Scoped {
  TextColumn get name => text()();
  /// User-assigned lab serial / catalog number (editable).
  TextColumn get serialNumber => text().withDefault(const Constant(''))();
  TextColumn get hostOrganism => text().withDefault(const Constant(''))();
  TextColumn get genotype => text().withDefault(const Constant(''))();
  TextColumn get plasmid => text().withDefault(const Constant(''))();
  TextColumn get constructNotes => text().withDefault(const Constant(''))();

  /// Selection markers carried by the strain (antibiotic resistances /
  /// auxotrophies, e.g. ['Kanamycin','Ampicillin']) — what to select on. JSON.
  TextColumn get selectionMarkers => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get freezerLocation => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// A reagent in the lab's inventory (project-independent inventory). A reagent
/// may instead be a buffer (`kind == 'buffer'`), which typically carries a
/// preparation [recipe] rather than supplier/catalog details.
@DataClassName('Reagent')
class Reagents extends Table with _Base, _Scoped {
  TextColumn get name => text()();
  /// 'reagent' (default) or 'buffer'.
  TextColumn get kind => text().withDefault(const Constant('reagent'))();
  TextColumn get supplier => text().withDefault(const Constant(''))();
  TextColumn get catalogNo => text().withDefault(const Constant(''))();
  TextColumn get lot => text().withDefault(const Constant(''))();
  TextColumn get location => text().withDefault(const Constant(''))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get quantity => text().withDefault(const Constant(''))();
  /// Preparation / composition recipe — used mainly for buffers.
  TextColumn get recipe => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// Records a deleted row so the deletion can propagate during sync. Entity
/// tables keep hard deletes (with FK cascade); a tombstone is written for the
/// deleted row and for every row the cascade removed.
@DataClassName('Tombstone')
class Tombstones extends Table {
  TextColumn get id => text()(); // the deleted row's UUID (unique across tables)
  // `tableName` is reserved by drift's Table base class, so the getter is named
  // `entityTable` while the SQL column stays `table_name`.
  TextColumn get entityTable => text().named('table_name')();
  DateTimeColumn get deletedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Key/value store for sync bookkeeping (e.g. the last-sync cursor).
@DataClassName('SyncMetaRow')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// User preferences (a single row, id = 0). Persisted locally and synced
/// per-user via Supabase so the theme follows the account across devices.
@DataClassName('AppSetting')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  // 'light' | 'dark' | 'system'
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  // ARGB accent (seed) colour; default teal.
  IntColumn get accentColor =>
      integer().withDefault(const Constant(0xFF009688))();
  // 'comfortable' | 'compact'
  TextColumn get density => text().withDefault(const Constant('comfortable'))();
  // App background: 'none' | 'color' | 'gradient' | 'image'.
  TextColumn get bgMode => text().withDefault(const Constant('none'))();
  // ARGB colours for the solid colour / gradient endpoints.
  IntColumn get bgColorA =>
      integer().withDefault(const Constant(0xFF0F2027))();
  IntColumn get bgColorB =>
      integer().withDefault(const Constant(0xFF2C5364))();
  // Base64 image bytes for the 'image' mode (synced with the other prefs).
  TextColumn get bgImage => text().withDefault(const Constant(''))();
  // 0..1 scrim that dims the background image itself.
  RealColumn get bgDim => real().withDefault(const Constant(0.35))();
  // The frosted content surface laid over a custom background: fill opacity
  // (with a legibility floor applied at render) and blur strength.
  RealColumn get surfaceOpacity => real().withDefault(const Constant(0.78))();
  RealColumn get surfaceBlur => real().withDefault(const Constant(18.0))();
  // How often the app reminds about due/overdue deadlines while it's open:
  // 'off' | 'daily' | 'twice_daily' | 'every_6h' | 'hourly'. Device-local
  // (deliberately NOT synced — notification cadence is per-device).
  TextColumn get notifyFrequency =>
      text().withDefault(const Constant('daily'))();
  // Holiday calendar to overlay on the Schedule ('none' | 'us' | 'us-hi' | …).
  // Device-local.
  TextColumn get holidayRegion =>
      text().withDefault(const Constant('none'))();
  // Notify today's schedule on launch + tomorrow's on close. Device-local.
  BoolColumn get scheduleNotify => boolean().withDefault(const Constant(true))();
  // Whether a second launch opens a new window (true) or focuses the running
  // one (false, single-instance). Device-local; takes effect next launch.
  BoolColumn get allowMultipleInstances =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column> get primaryKey => {id};
}

/// A manuscript associated with a project.
@TableIndex(name: 'idx_manuscripts_project', columns: {#projectId})
@DataClassName('Manuscript')
class Manuscripts extends Table with _Base, _Scoped {
  TextColumn get projectId =>
      text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get targetJournal => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<ManuscriptStatus>()
      .withDefault(Constant(ManuscriptStatus.drafting.name))();
  TextColumn get submissionId => text().withDefault(const Constant(''))();
  DateTimeColumn get submittedDate => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// A reusable lab protocol / SOP: a named, step-by-step procedure
/// (project-independent), optionally with materials and attached annotated
/// images.
@DataClassName('Protocol')
class Protocols extends Table with _Base, _Scoped {
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  /// The procedure written as ordered steps (JSON array of strings).
  TextColumn get steps => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  /// Stable per-step ids, parallel to [steps], so attached images can reference a
  /// step even when steps are reordered. Empty for protocols created before this
  /// was added — the editor backfills ids on first edit.
  TextColumn get stepIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get materials => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// An image attached to an experiment or a strain (gel photo, plate image,
/// micrograph). This is *metadata only* and syncs like any other entity — the
/// image bytes never live in this row, so they never reach Postgres.
/// `storagePath` is the Supabase Storage object path, set once the file has
/// been uploaded.
@TableIndex(name: 'idx_images_experiment', columns: {#experimentId})
@TableIndex(name: 'idx_images_strain', columns: {#strainId})
@TableIndex(name: 'idx_images_protocol', columns: {#protocolId})
@DataClassName('AttachedImage')
class Images extends Table with _Base, _Scoped {
  TextColumn get experimentId => text()
      .nullable()
      .references(Experiments, #id, onDelete: KeyAction.cascade)();
  TextColumn get strainId =>
      text().nullable().references(Strains, #id, onDelete: KeyAction.cascade)();
  TextColumn get cultureId =>
      text().nullable().references(Cultures, #id, onDelete: KeyAction.cascade)();
  // Attached to a progress-log entry (so updates can carry result images).
  TextColumn get updateId => text()
      .nullable()
      .references(ExperimentUpdates, #id, onDelete: KeyAction.cascade)();
  // Inserted directly into a report (figures).
  TextColumn get reportId =>
      text().nullable().references(Reports, #id, onDelete: KeyAction.cascade)();
  // Inserted directly into a protocol.
  TextColumn get protocolId => text()
      .nullable()
      .references(Protocols, #id, onDelete: KeyAction.cascade)();
  // For a protocol image: the stable id of the step it illustrates (a value from
  // protocols.step_ids), or null for a general (non-step) protocol image.
  TextColumn get stepId => text().nullable()();
  TextColumn get caption => text().withDefault(const Constant(''))();
  // Free-text annotation note + drawn markup overlay (arrows/boxes/labels).
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get annotations => text()
      .map(const ImageAnnotationListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get contentType =>
      text().withDefault(const Constant('image/jpeg'))();
  TextColumn get storagePath => text().withDefault(const Constant(''))();
}

/// A timestamped progress-log entry on an experiment (lab-notebook style). Can
/// carry its own image attachments (via `images.update_id`).
@TableIndex(name: 'idx_updates_experiment', columns: {#experimentId})
@DataClassName('ExperimentUpdate')
class ExperimentUpdates extends Table with _Base, _Scoped {
  TextColumn get experimentId =>
      text().references(Experiments, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get happenedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// A culture started from a [Strain]. Lifecycle is status-only — never hard
/// deleted: active -> terminated/archived (with an ended_date), and restorable
/// back to active.
@TableIndex(name: 'idx_cultures_strain', columns: {#strainId})
@TableIndex(name: 'idx_cultures_status', columns: {#status})
@DataClassName('Culture')
class Cultures extends Table with _Base, _Scoped {
  TextColumn get name => text().withDefault(const Constant(''))();
  // The strain this culture was started from. Nullable + set-null so deleting a
  // strain doesn't destroy the culture's record.
  TextColumn get strainId =>
      text().nullable().references(Strains, #id, onDelete: KeyAction.setNull)();
  // 'active' | 'terminated' | 'archived'
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get medium => text().withDefault(const Constant(''))();
  TextColumn get vessel => text().withDefault(const Constant(''))();
  DateTimeColumn get startedDate =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get endedDate => dateTime().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Why this culture was started (free text) — shown on the printable culture
  /// label.
  TextColumn get purpose => text().withDefault(const Constant(''))();

  // How much was used to start this culture (e.g. the volume split from a mother
  // into this sub-culture).
  TextColumn get inoculumAmount => text().withDefault(const Constant(''))();

  /// Selection markers this culture is grown under (defaults from the strain but
  /// editable per culture). JSON array.
  TextColumn get selectionMarkers => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  // Lineage when this culture was split off another: the mother culture and its
  // original inoculation time (started_date here is this culture's split time).
  // A LOGICAL reference (no DB FK) resolved in the app layer, so a missing mother
  // degrades gracefully and self-references don't constrain restore order.
  TextColumn get parentCultureId => text().nullable()();
  DateTimeColumn get parentInoculatedAt => dateTime().nullable()();
}

/// A logged operation performed on a culture — sampling, reagent addition,
/// induction, split, a measurement, or a free note. [agent] is what was
/// added/measured and [amount] is how much / the measured value.
@TableIndex(name: 'idx_culture_events_culture', columns: {#cultureId})
@DataClassName('CultureEvent')
class CultureEvents extends Table with _Base, _Scoped {
  TextColumn get cultureId =>
      text().references(Cultures, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get happenedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  // sampling | reagent | induction | split | measurement | note
  TextColumn get type => text().withDefault(const Constant('note'))();
  TextColumn get agent => text().withDefault(const Constant(''))();
  TextColumn get amount => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// An oligonucleotide primer in the lab's inventory. Sequence length is derived
/// for display, not stored.
@DataClassName('Primer')
class Primers extends Table with _Base, _Scoped {
  TextColumn get name => text()();
  /// User-assigned lab serial / catalog number (editable).
  TextColumn get serialNumber => text().withDefault(const Constant(''))();
  TextColumn get sequence => text().withDefault(const Constant(''))();
  TextColumn get targetGene => text().withDefault(const Constant(''))();
  TextColumn get direction => text().withDefault(const Constant(''))();
  TextColumn get tm => text().withDefault(const Constant(''))();
  TextColumn get supplier => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// A Gibson-assembly clone construction (cloning design). The backbone and each
/// fragment reference inventory strains (templates/stock) and primers; the
/// assembled vector is rendered from this data.
@DataClassName('CloneConstruction')
class CloneConstructions extends Table with _Base, _Scoped {
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  // Backbone: a vector name, the strain stock it comes from (logical ref), and
  // the restriction enzymes used to linearise it.
  TextColumn get backboneName => text().withDefault(const Constant(''))();
  TextColumn get backboneStrainId => text().withDefault(const Constant(''))();
  TextColumn get enzymes => text().withDefault(const Constant(''))();
  // The fragments to assemble into the backbone (Gibson), stored as JSON.
  TextColumn get fragments => text()
      .map(const CloneFragmentListConverter())
      .withDefault(const Constant('[]'))();
}

/// A progress report addressed to the PI. Stores only the header (recipient,
/// author, reporting period) and the author's written summary; the rest of the
/// content (projects, experiments, tasks, …) is gathered live from the current
/// workspace when the report is exported to PDF.
@DataClassName('Report')
class Reports extends Table with _Base, _Scoped {
  TextColumn get title =>
      text().withDefault(const Constant('Progress report'))();
  TextColumn get recipient => text().withDefault(const Constant(''))(); // PI
  TextColumn get author => text().withDefault(const Constant(''))();
  DateTimeColumn get periodStart => dateTime().nullable()();
  DateTimeColumn get periodEnd => dateTime().nullable()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  // Which projects / experiments to include. Empty = include everything.
  TextColumn get projectIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get experimentIds => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
}

/// A user-created calendar event (personal/birthday/meeting/…), shown on the
/// Schedule alongside the auto-gathered lab dates. [repeatAnnually] makes it
/// recur every year on the same month/day (e.g. birthdays).
@TableIndex(name: 'idx_custom_events_date', columns: {#date})
@DataClassName('CustomEvent')
class CustomEvents extends Table with _Base, _Scoped {
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  // personal | birthday | meeting | reminder | other
  TextColumn get category => text().withDefault(const Constant('personal'))();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get repeatAnnually =>
      boolean().withDefault(const Constant(false))();
}

/// A deleted item parked in the Trash so the deletion can be undone. Stores the
/// full captured subtree (the row plus everything that cascaded from it, and any
/// image bytes) as JSON in [payload]. **Device-local only** (not synced): the
/// real deletion already propagates via tombstones; Trash is a local undo
/// buffer, auto-purged after a retention window.
@DataClassName('TrashEntry')
class TrashEntries extends Table with _Base, _Scoped {
  TextColumn get entityTable => text()(); // the top-level row's table
  TextColumn get entityId => text()(); // the top-level row's id
  TextColumn get kind => text().withDefault(const Constant(''))(); // 'Project'…
  TextColumn get label => text().withDefault(const Constant(''))();
  DateTimeColumn get deletedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  TextColumn get payload => text()(); // captured subtree {tables, blobs}
}

/// Local cache of image bytes — the local-first store that lets attachments
/// render offline. **Never synced**: the bytes go to Supabase Storage on sync
/// (not Postgres). Each row is tied to an `images` row and is removed by cascade
/// when that row (or its owning experiment/strain) is hard-deleted.
@DataClassName('ImageBlob')
class ImageBlobs extends Table {
  TextColumn get id =>
      text().references(Images, #id, onDelete: KeyAction.cascade)();
  BlobColumn get bytes => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A shared lab workspace. Members (see [Memberships]) see the same projects,
/// experiments, tasks, strains, reagents, manuscripts and images.
@DataClassName('Workspace')
class Workspaces extends Table with _Base {
  TextColumn get name => text().withDefault(const Constant('My Lab'))();
}

/// Ties a user to a workspace with a role: `owner` (read/write + manage
/// members), `editor` (read/write) or `viewer` (read-only).
@TableIndex(name: 'idx_memberships_workspace', columns: {#workspaceId})
@TableIndex(name: 'idx_memberships_user', columns: {#userId})
@DataClassName('Membership')
class Memberships extends Table with _Base {
  TextColumn get workspaceId => text()();
  TextColumn get userId => text()(); // Supabase auth uid
  // Denormalised for display in the members list (auth.users isn't readable).
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant('viewer'))();
}

/// A pending invitation to join a workspace, addressed by email. The invited
/// user turns it into a [Membership] when they sign in (claimed server-side).
@TableIndex(name: 'idx_invites_workspace', columns: {#workspaceId})
@DataClassName('WorkspaceInvite')
class WorkspaceInvites extends Table with _Base {
  TextColumn get workspaceId => text()();
  TextColumn get email => text()();
  TextColumn get role => text().withDefault(const Constant('editor'))();
  TextColumn get invitedBy => text().withDefault(const Constant(''))();
}
