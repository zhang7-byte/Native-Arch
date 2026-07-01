import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Task] rows as reactive streams.
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  Stream<List<Task>> watchAll() => _db
      .customSelect(
        'SELECT * FROM tasks WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.tasks, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.tasks.map(r.data)).toList());

  /// Tasks directly attached to [projectId].
  Stream<List<Task>> watchForProject(String projectId) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  /// Tasks attached to [experimentId].
  Stream<List<Task>> watchForExperiment(String experimentId) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.experimentId.equals(experimentId))
      ..orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  Future<void> create(TasksCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.tasks).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, TasksCompanion values) =>
      (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(values);

  Future<void> delete(String id) => TrashRepository(_db).trash('tasks', id);
}
