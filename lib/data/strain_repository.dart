import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Strain] rows as reactive streams.
class StrainRepository {
  StrainRepository(this._db);

  final AppDatabase _db;

  Stream<List<Strain>> watchAll() => _db
      .customSelect(
        'SELECT * FROM strains WHERE $workspaceScopeWhere ORDER BY name',
        readsFrom: {_db.strains, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.strains.map(r.data)).toList());

  Stream<Strain?> watchById(String id) =>
      (_db.select(_db.strains)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<Strain?> findById(String id) =>
      (_db.select(_db.strains)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<Strain>> all() => _db.select(_db.strains).get();

  Future<void> create(StrainsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.strains).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, StrainsCompanion values) =>
      (_db.update(_db.strains)..where((t) => t.id.equals(id))).write(values);

  /// Moves the strain (and its image attachments) to the Trash, reversibly.
  Future<void> delete(String id) => TrashRepository(_db).trash('strains', id);
}
