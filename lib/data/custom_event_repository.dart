import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes user-created calendar events for the Schedule, scoped to the
/// current workspace. Deletes go through the Trash like other entities.
class CustomEventRepository {
  CustomEventRepository(this._db);

  final AppDatabase _db;

  Stream<List<CustomEvent>> watchAll() => _db
      .customSelect(
        'SELECT * FROM custom_events WHERE $workspaceScopeWhere ORDER BY date',
        readsFrom: {_db.customEvents, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.customEvents.map(r.data)).toList());

  Future<List<CustomEvent>> all() async {
    final ws = await currentWorkspaceId(_db);
    final rows = await _db.select(_db.customEvents).get();
    return ws == null ? rows : rows.where((e) => e.workspaceId == ws).toList();
  }

  Future<void> create(CustomEventsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.customEvents).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, CustomEventsCompanion values) =>
      (_db.update(_db.customEvents)..where((t) => t.id.equals(id)))
          .write(values);

  Future<void> delete(String id) =>
      TrashRepository(_db).trash('custom_events', id);
}
