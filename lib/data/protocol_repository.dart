import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Protocol] rows as reactive streams, scoped to the current
/// workspace. A protocol is a reusable step-by-step procedure (SOP) with
/// optional materials, notes and attached annotated images.
class ProtocolRepository {
  ProtocolRepository(this._db);

  final AppDatabase _db;

  /// All protocols in the current workspace, most-recently-updated first.
  Stream<List<Protocol>> watchAll() => _db
      .customSelect(
        'SELECT * FROM protocols WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.protocols, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.protocols.map(r.data)).toList());

  Future<Protocol?> findById(String id) =>
      (_db.select(_db.protocols)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> create(ProtocolsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.protocols).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, ProtocolsCompanion values) =>
      (_db.update(_db.protocols)..where((t) => t.id.equals(id))).write(values);

  Future<void> delete(String id) => TrashRepository(_db).trash('protocols', id);
}
