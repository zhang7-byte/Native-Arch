import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [CloneConstruction] rows (Gibson cloning designs) as
/// reactive streams, scoped to the current workspace.
class CloneRepository {
  CloneRepository(this._db);

  final AppDatabase _db;

  Stream<List<CloneConstruction>> watchAll() => _db
      .customSelect(
        'SELECT * FROM clone_constructions WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.cloneConstructions, _db.syncMeta},
      )
      .watch()
      .map((rows) =>
          rows.map((r) => _db.cloneConstructions.map(r.data)).toList());

  Future<CloneConstruction?> findById(String id) =>
      (_db.select(_db.cloneConstructions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> create(CloneConstructionsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.cloneConstructions).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, CloneConstructionsCompanion values) =>
      (_db.update(_db.cloneConstructions)..where((t) => t.id.equals(id)))
          .write(values);

  Future<void> delete(String id) =>
      TrashRepository(_db).trash('clone_constructions', id);
}
