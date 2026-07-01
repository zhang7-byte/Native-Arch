import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// These are imported (not just re-exported) so the symbols they declare —
// the status enums, the StringListConverter and the `uuid` helper — resolve
// inside the generated `database.g.dart`, which is part of this library.
import 'converters.dart';
import 'enums.dart';
import 'seed.dart';
import 'tables.dart';

export 'converters.dart' show CloneFragment, ImageAnnotation;
export 'enums.dart';
export 'tables.dart';

part 'database.g.dart';

/// The application's local-first SQLite database.
///
/// Backed by a real on-device SQLite file on desktop/mobile (via
/// `sqlite3_flutter_libs`) and by SQLite compiled to WebAssembly in the browser
/// (persisted to OPFS/IndexedDB). The same schema and queries run on every
/// platform.
@DriftDatabase(
  tables: [
    Projects,
    Experiments,
    Tasks,
    Strains,
    Reagents,
    Manuscripts,
    Tombstones,
    SyncMeta,
    AppSettings,
    Images,
    ImageBlobs,
    Workspaces,
    Memberships,
    WorkspaceInvites,
    Cultures,
    Primers,
    Reports,
    Protocols,
    CloneConstructions,
    ExperimentUpdates,
    TrashEntries,
    CustomEvents,
    CultureEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// When true, the SPEC.md Section 4 seed data is ensured present on open
  /// ([seedDatabase] is idempotent and table-by-table). Tests leave this `false`
  /// so they start from an empty database.
  final bool seedData;

  AppDatabase([QueryExecutor? executor, this.seedData = false])
      : super(executor ?? _openConnection());

  /// Bumped whenever the schema changes; drives drift's migrations.
  /// v2 adds the sync bookkeeping tables (tombstones, sync_meta); v3 adds
  /// app_settings (user preferences); v4 adds images (synced metadata) and
  /// image_blobs (local-only image bytes); v5 adds shared workspaces
  /// (workspaces, memberships, workspace_invites) and a workspace_id on every
  /// entity table; v6 adds the customisable app background to app_settings;
  /// v7 adds cultures and a culture_id on images; v8 adds primers; v9 adds the
  /// frosted content-surface prefs (surface_opacity, surface_blur); v10 adds the
  /// deadline-notification cadence (notify_frequency); v11 adds reports
  /// (PI progress reports); v12 adds clone_constructions (Gibson cloning designs);
  /// v13 adds experiment_updates (progress log) + image notes/annotations/update_id;
  /// v14 adds report project/experiment selection + image report_id (report figures);
  /// v15 adds trash_entries (local undo buffer for deletions); v16 adds
  /// custom_events (Schedule) + app_settings holiday_region/schedule_notify;
  /// v17 adds experiments methodology_steps/conclusion/further_plan; v18 adds
  /// culture_events (operations log) + strains.selection_markers +
  /// cultures parent_culture_id/parent_inoculated_at (split lineage); v19 adds
  /// cultures.inoculum_amount; v20 adds cultures.selection_markers; v21 adds
  /// app_settings.allow_multiple_instances; v22 adds strains.serial_number +
  /// primers.serial_number; v23 adds reagents.kind (reagent|buffer) +
  /// reagents.recipe (buffer recipes); v24 adds protocols (step-by-step SOPs) +
  /// images.protocol_id (protocol figures); v25 adds protocols.step_ids +
  /// images.step_id (link a protocol image to a specific step).
  @override
  int get schemaVersion => 26;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createUpdatedAtTriggers();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(tombstones);
            await m.createTable(syncMeta);
          }
          if (from < 3) {
            await m.createTable(appSettings);
          }
          if (from < 4) {
            await m.createTable(images);
            await m.createTable(imageBlobs);
            // Add the images updated_at trigger (idempotent, IF NOT EXISTS).
            await _createUpdatedAtTriggers();
          }
          if (from < 5) {
            await m.createTable(workspaces);
            await m.createTable(memberships);
            await m.createTable(workspaceInvites);
            // Add workspace_id to every entity table (defaults to '' until the
            // bootstrap backfills pre-workspace rows into the default workspace).
            // Idempotent: `images` is created in the v4 step already carrying
            // workspace_id, so only add it where it is genuinely missing — this
            // keeps both the v3->v5 and v4->v5 paths working.
            final scoped = <(TableInfo, GeneratedColumn)>[
              (projects, projects.workspaceId),
              (experiments, experiments.workspaceId),
              (tasks, tasks.workspaceId),
              (strains, strains.workspaceId),
              (reagents, reagents.workspaceId),
              (manuscripts, manuscripts.workspaceId),
              (images, images.workspaceId),
            ];
            for (final (table, column) in scoped) {
              final info = await customSelect(
                      'PRAGMA table_info(${table.actualTableName})')
                  .get();
              final present =
                  info.any((r) => r.data['name'] == column.name);
              if (!present) await m.addColumn(table, column);
            }
            await _createUpdatedAtTriggers();
          }
          if (from < 6) {
            // Add the background-preference columns to app_settings (guarded so
            // it is safe regardless of the starting version).
            final cols = <(TableInfo, GeneratedColumn)>[
              (appSettings, appSettings.bgMode),
              (appSettings, appSettings.bgColorA),
              (appSettings, appSettings.bgColorB),
              (appSettings, appSettings.bgImage),
              (appSettings, appSettings.bgDim),
            ];
            final info = await customSelect(
                    'PRAGMA table_info(${appSettings.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            for (final (table, column) in cols) {
              if (!existing.contains(column.name)) {
                await m.addColumn(table, column);
              }
            }
          }
          if (from < 7) {
            await m.createTable(cultures);
            final info = await customSelect(
                    'PRAGMA table_info(${images.actualTableName})')
                .get();
            if (!info.any((r) => r.data['name'] == 'culture_id')) {
              await m.addColumn(images, images.cultureId);
            }
            await _createUpdatedAtTriggers();
          }
          if (from < 8) {
            await m.createTable(primers);
            await _createUpdatedAtTriggers();
          }
          if (from < 9) {
            final cols = <(TableInfo, GeneratedColumn)>[
              (appSettings, appSettings.surfaceOpacity),
              (appSettings, appSettings.surfaceBlur),
            ];
            final info = await customSelect(
                    'PRAGMA table_info(${appSettings.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            for (final (table, column) in cols) {
              if (!existing.contains(column.name)) {
                await m.addColumn(table, column);
              }
            }
          }
          if (from < 10) {
            // Deadline-notification cadence (guarded so it is safe from any
            // starting version).
            final info = await customSelect(
                    'PRAGMA table_info(${appSettings.actualTableName})')
                .get();
            final present =
                info.any((r) => r.data['name'] == appSettings.notifyFrequency.name);
            if (!present) {
              await m.addColumn(appSettings, appSettings.notifyFrequency);
            }
          }
          if (from < 11) {
            await m.createTable(reports);
            await _createUpdatedAtTriggers();
          }
          if (from < 12) {
            await m.createTable(cloneConstructions);
            await _createUpdatedAtTriggers();
          }
          if (from < 13) {
            // Progress-log table first, then the new image columns (one of which
            // references it). Guarded so any starting version is safe.
            await m.createTable(experimentUpdates);
            final info = await customSelect(
                    'PRAGMA table_info(${images.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            final cols = <(TableInfo, GeneratedColumn)>[
              (images, images.updateId),
              (images, images.notes),
              (images, images.annotations),
            ];
            for (final (table, column) in cols) {
              if (!existing.contains(column.name)) {
                await m.addColumn(table, column);
              }
            }
            await _createUpdatedAtTriggers();
          }
          if (from < 14) {
            // Report selection columns + image report_id (all guarded).
            final rInfo = await customSelect(
                    'PRAGMA table_info(${reports.actualTableName})')
                .get();
            final rCols = rInfo.map((r) => r.data['name'] as String).toSet();
            for (final (table, column) in <(TableInfo, GeneratedColumn)>[
              (reports, reports.projectIds),
              (reports, reports.experimentIds),
            ]) {
              if (!rCols.contains(column.name)) await m.addColumn(table, column);
            }
            final iInfo = await customSelect(
                    'PRAGMA table_info(${images.actualTableName})')
                .get();
            if (!iInfo.any((r) => r.data['name'] == images.reportId.name)) {
              await m.addColumn(images, images.reportId);
            }
          }
          if (from < 15) {
            await m.createTable(trashEntries);
            await _createUpdatedAtTriggers();
          }
          if (from < 16) {
            await m.createTable(customEvents);
            await _createUpdatedAtTriggers();
            final info = await customSelect(
                    'PRAGMA table_info(${appSettings.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            for (final (table, column) in <(TableInfo, GeneratedColumn)>[
              (appSettings, appSettings.holidayRegion),
              (appSettings, appSettings.scheduleNotify),
            ]) {
              if (!existing.contains(column.name)) {
                await m.addColumn(table, column);
              }
            }
          }
          if (from < 17) {
            final info = await customSelect(
                    'PRAGMA table_info(${experiments.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            for (final column in <GeneratedColumn>[
              experiments.methodologySteps,
              experiments.conclusion,
              experiments.furtherPlan,
            ]) {
              if (!existing.contains(column.name)) {
                await m.addColumn(experiments, column);
              }
            }
          }
          if (from < 18) {
            await m.createTable(cultureEvents);
            await _createUpdatedAtTriggers();
            Future<Set<String>> cols(TableInfo t) async => (await customSelect(
                    'PRAGMA table_info(${t.actualTableName})')
                .get())
                .map((r) => r.data['name'] as String)
                .toSet();
            final sCols = await cols(strains);
            if (!sCols.contains(strains.selectionMarkers.name)) {
              await m.addColumn(strains, strains.selectionMarkers);
            }
            final cCols = await cols(cultures);
            for (final column in <GeneratedColumn>[
              cultures.parentCultureId,
              cultures.parentInoculatedAt,
            ]) {
              if (!cCols.contains(column.name)) {
                await m.addColumn(cultures, column);
              }
            }
          }
          if (from < 19) {
            final info = await customSelect(
                    'PRAGMA table_info(${cultures.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            if (!existing.contains(cultures.inoculumAmount.name)) {
              await m.addColumn(cultures, cultures.inoculumAmount);
            }
          }
          if (from < 20) {
            final info = await customSelect(
                    'PRAGMA table_info(${cultures.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            if (!existing.contains(cultures.selectionMarkers.name)) {
              await m.addColumn(cultures, cultures.selectionMarkers);
            }
          }
          if (from < 21) {
            final info = await customSelect(
                    'PRAGMA table_info(${appSettings.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            if (!existing.contains(appSettings.allowMultipleInstances.name)) {
              await m.addColumn(
                  appSettings, appSettings.allowMultipleInstances);
            }
          }
          if (from < 22) {
            Future<Set<String>> cols(TableInfo t) async => (await customSelect(
                    'PRAGMA table_info(${t.actualTableName})')
                .get())
                .map((r) => r.data['name'] as String)
                .toSet();
            final sCols = await cols(strains);
            if (!sCols.contains(strains.serialNumber.name)) {
              await m.addColumn(strains, strains.serialNumber);
            }
            final pCols = await cols(primers);
            if (!pCols.contains(primers.serialNumber.name)) {
              await m.addColumn(primers, primers.serialNumber);
            }
          }
          if (from < 23) {
            final info = await customSelect(
                    'PRAGMA table_info(${reagents.actualTableName})')
                .get();
            final existing =
                info.map((r) => r.data['name'] as String).toSet();
            for (final column in <GeneratedColumn>[
              reagents.kind,
              reagents.recipe,
            ]) {
              if (!existing.contains(column.name)) {
                await m.addColumn(reagents, column);
              }
            }
          }
          if (from < 24) {
            await m.createTable(protocols);
            await _createUpdatedAtTriggers();
            final iInfo = await customSelect(
                    'PRAGMA table_info(${images.actualTableName})')
                .get();
            if (!iInfo.any((r) => r.data['name'] == images.protocolId.name)) {
              await m.addColumn(images, images.protocolId);
            }
          }
          if (from < 25) {
            final pInfo = await customSelect(
                    'PRAGMA table_info(${protocols.actualTableName})')
                .get();
            if (!pInfo.any((r) => r.data['name'] == protocols.stepIds.name)) {
              await m.addColumn(protocols, protocols.stepIds);
            }
            final iInfo = await customSelect(
                    'PRAGMA table_info(${images.actualTableName})')
                .get();
            if (!iInfo.any((r) => r.data['name'] == images.stepId.name)) {
              await m.addColumn(images, images.stepId);
            }
          }
          if (from < 26) {
            final cInfo = await customSelect(
                    'PRAGMA table_info(${cultures.actualTableName})')
                .get();
            if (!cInfo.any((r) => r.data['name'] == cultures.purpose.name)) {
              await m.addColumn(cultures, cultures.purpose);
            }
          }
        },
        beforeOpen: (details) async {
          // SQLite does not enforce foreign keys unless explicitly enabled.
          await customStatement('PRAGMA foreign_keys = ON');
          // Ensure seed data is present (idempotent — see seedDatabase). Runs on
          // every open so a later stage's seed batch lands in a database created
          // by an earlier stage.
          if (seedData) {
            await seedDatabase(this);
          }
        },
      );

  /// Installs an `AFTER UPDATE` trigger on every table that refreshes
  /// `updated_at` whenever a row changes, unless the writer set it explicitly.
  ///
  /// A Dart `clientDefault` only runs on INSERT, never on UPDATE, so without
  /// this trigger `updated_at` would stay frozen at creation time and the
  /// documented last-writer-wins sync basis would be wrong. A DB-level trigger
  /// cannot be bypassed by any write path. The timestamp is written as ISO-8601
  /// UTC text to match drift's `store_date_time_values_as_text` format.
  Future<void> _createUpdatedAtTriggers() async {
    for (final table in const [
      'projects',
      'experiments',
      'tasks',
      'strains',
      'reagents',
      'manuscripts',
      'images',
      'workspaces',
      'memberships',
      'workspace_invites',
      'cultures',
      'primers',
      'reports',
      'protocols',
      'clone_constructions',
      'experiment_updates',
      'trash_entries',
      'custom_events',
      'culture_events',
    ]) {
      // Only create the trigger if the table already exists. During an
      // incremental upgrade this method runs more than once, before later steps
      // have created every table (e.g. workspaces is added in the v5 step).
      final exists = await customSelect(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
        variables: [Variable<String>(table)],
      ).getSingleOrNull();
      if (exists == null) continue;
      await customStatement(
        'CREATE TRIGGER IF NOT EXISTS trg_${table}_updated_at '
        'AFTER UPDATE ON $table FOR EACH ROW '
        'WHEN NEW.updated_at = OLD.updated_at '
        "BEGIN UPDATE $table SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now') "
        'WHERE id = NEW.id; END;',
      );
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'labtrack',
    // On the web, drift loads these two files from the web/ folder at runtime.
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
