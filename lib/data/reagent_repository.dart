import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Reagent] rows as reactive streams.
class ReagentRepository {
  ReagentRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reagent>> watchAll() => _db
      .customSelect(
        'SELECT * FROM reagents WHERE $workspaceScopeWhere ORDER BY name',
        readsFrom: {_db.reagents, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.reagents.map(r.data)).toList());

  Future<void> create(ReagentsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.reagents).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, ReagentsCompanion values) =>
      (_db.update(_db.reagents)..where((t) => t.id.equals(id))).write(values);

  Future<void> delete(String id) => TrashRepository(_db).trash('reagents', id);
}
