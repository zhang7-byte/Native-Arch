import 'package:drift/drift.dart';

import 'database.dart';
import 'sync/tombstone_writer.dart';

/// SQL predicate that scopes a query to the currently-selected workspace. It is
/// a no-op when no workspace is selected (e.g. in tests), so the same repos work
/// scoped (in the app) and unscoped (in unit tests). Stays reactive: queries
/// using it should declare `readsFrom: {table, syncMeta}` so switching workspace
/// refreshes them.
const workspaceScopeWhere =
    "workspace_id = coalesce((SELECT value FROM sync_meta "
    "WHERE key = 'current_workspace' AND value <> ''), workspace_id)";

/// The currently-selected workspace id on this device, or null if none.
Future<String?> currentWorkspaceId(AppDatabase db) async {
  final row = await (db.select(db.syncMeta)
        ..where((t) => t.key.equals('current_workspace')))
      .getSingleOrNull();
  return (row == null || row.value.isEmpty) ? null : row.value;
}

/// Entity tables that carry a `workspace_id` (used by the one-time backfill).
const scopedTables = [
  'projects',
  'experiments',
  'tasks',
  'strains',
  'reagents',
  'primers',
  'cultures',
  'manuscripts',
  'images',
  'reports',
  'protocols',
  'clone_constructions',
  'experiment_updates',
  'custom_events',
  'culture_events',
];

/// Reads/writes workspaces and tracks which workspace is currently selected on
/// this device (stored locally in `sync_meta`).
class WorkspaceRepository {
  WorkspaceRepository(this._db);

  final AppDatabase _db;

  static const _currentKey = 'current_workspace';

  Stream<List<Workspace>> watchAll() => (_db.select(_db.workspaces)
        ..orderBy([(t) => OrderingTerm(expression: t.name)]))
      .watch();

  Future<List<Workspace>> all() => _db.select(_db.workspaces).get();

  Future<Workspace?> findById(String id) =>
      (_db.select(_db.workspaces)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Stream<Workspace?> watchById(String id) =>
      (_db.select(_db.workspaces)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<String?> currentId() async {
    final row = await (_db.select(_db.syncMeta)
          ..where((t) => t.key.equals(_currentKey)))
        .getSingleOrNull();
    return (row == null || row.value.isEmpty) ? null : row.value;
  }

  Stream<String?> watchCurrentId() => (_db.select(_db.syncMeta)
        ..where((t) => t.key.equals(_currentKey)))
      .watchSingleOrNull()
      .map((r) => (r == null || r.value.isEmpty) ? null : r.value);

  Future<void> setCurrent(String id) => _db
      .into(_db.syncMeta)
      .insertOnConflictUpdate(SyncMetaCompanion.insert(key: _currentKey, value: id));

  Future<String> create(String name) async {
    final id = uuid.v4();
    await _db
        .into(_db.workspaces)
        .insert(WorkspacesCompanion.insert(id: Value(id), name: Value(name)));
    return id;
  }

  Future<void> rename(String id, String name) =>
      (_db.update(_db.workspaces)..where((t) => t.id.equals(id)))
          .write(WorkspacesCompanion(name: Value(name)));

  /// Deletes a workspace and ALL of its data — every workspace-scoped table —
  /// writing a tombstone for each row so the removal propagates on sync. Refuses
  /// to delete the last remaining workspace. If the deleted workspace was the
  /// current one, switches to another. Returns the new current workspace id (or
  /// null if somehow none remain).
  Future<String?> delete(String id) async {
    final existing = await all();
    if (existing.length <= 1) {
      throw StateError('You must keep at least one workspace.');
    }
    final owned = scopedTables;
    await _db.transaction(() async {
      // Collect every owned row id up front (before deleting anything) so that
      // foreign-key cascades don't remove rows before we've tombstoned them.
      final tomb = <String, String>{};
      for (final table in owned) {
        final rows = await _db
            .customSelect('SELECT id FROM $table WHERE workspace_id = ?',
                variables: [Variable(id)])
            .get();
        for (final row in rows) {
          tomb[row.read<String>('id')] = table;
        }
      }
      for (final table in owned) {
        await _db
            .customStatement('DELETE FROM $table WHERE workspace_id = ?', [id]);
      }
      await (_db.delete(_db.workspaces)..where((t) => t.id.equals(id))).go();
      tomb[id] = 'workspaces';
      await writeTombstones(_db, tomb);
    });
    // If the current workspace was the one we removed, switch to another.
    final cur = await currentId();
    if (cur == null || cur == id) {
      final remaining = await all();
      final next = remaining.isEmpty ? null : remaining.first.id;
      if (next != null) await setCurrent(next);
      return next;
    }
    return cur;
  }

}

/// Ensures a default workspace exists, moves every pre-workspace row into it
/// (the one-time data migration), and selects a current workspace if none is.
/// Idempotent — safe to run on every startup. Returns the current workspace id.
Future<String> ensureDefaultWorkspace(AppDatabase db) async {
  final repo = WorkspaceRepository(db);
  final existing = await repo.all();
  final current = await repo.currentId();

  final String defaultId;
  if (existing.isEmpty) {
    defaultId = await repo.create('My Lab');
  } else if (current != null && existing.any((w) => w.id == current)) {
    defaultId = current;
  } else {
    defaultId = existing.first.id;
  }

  // Backfill any rows still untagged into the default workspace.
  for (final table in scopedTables) {
    await db.customStatement(
      "UPDATE $table SET workspace_id = ? "
      "WHERE workspace_id = '' OR workspace_id IS NULL",
      [defaultId],
    );
  }

  if (current == null || !existing.any((w) => w.id == current)) {
    await repo.setCurrent(defaultId);
  }
  return (await repo.currentId())!;
}
