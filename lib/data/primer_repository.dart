import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Primer] rows as reactive streams, scoped to the current
/// workspace.
class PrimerRepository {
  PrimerRepository(this._db);

  final AppDatabase _db;

  Stream<List<Primer>> watchAll() => _db
      .customSelect(
        'SELECT * FROM primers WHERE $workspaceScopeWhere ORDER BY name',
        readsFrom: {_db.primers, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.primers.map(r.data)).toList());

  Future<void> create(PrimersCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.primers).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, PrimersCompanion values) =>
      (_db.update(_db.primers)..where((t) => t.id.equals(id))).write(values);

  Future<void> delete(String id) => TrashRepository(_db).trash('primers', id);
}
