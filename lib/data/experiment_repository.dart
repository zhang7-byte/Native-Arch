import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Experiment] rows as reactive streams.
class ExperimentRepository {
  ExperimentRepository(this._db);

  final AppDatabase _db;

  Stream<List<Experiment>> watchAll() => _db
      .customSelect(
        'SELECT * FROM experiments WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.experiments, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.experiments.map(r.data)).toList());

  /// Every experiment in the current workspace paired with its parent project's
  /// title (one query).
  Stream<List<(Experiment, String)>> watchAllWithProject() => _db
      .customSelect(
        'SELECT e.*, p.title AS __ptitle FROM experiments e '
        'JOIN projects p ON p.id = e.project_id '
        "WHERE e.workspace_id = coalesce((SELECT value FROM sync_meta "
        "WHERE key = 'current_workspace' AND value <> ''), e.workspace_id) "
        'ORDER BY e.updated_at DESC',
        readsFrom: {_db.experiments, _db.projects, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows
          .map((r) =>
              (_db.experiments.map(r.data), r.data['__ptitle'] as String))
          .toList());

  /// Experiments whose `strain_ids` include [strainId]. Filtered in Dart since
  /// `strain_ids` is stored as a JSON array, not a queryable column.
  Stream<List<Experiment>> watchUsingStrain(String strainId) =>
      watchAll().map(
          (list) => list.where((e) => e.strainIds.contains(strainId)).toList());

  /// A single experiment, kept live for a detail screen.
  Stream<Experiment?> watchById(String id) =>
      (_db.select(_db.experiments)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  /// Experiments belonging to [projectId].
  Stream<List<Experiment>> watchForProject(String projectId) {
    final query = _db.select(_db.experiments)
      ..where((t) => t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  Future<List<Experiment>> all() => _db.select(_db.experiments).get();

  Future<Experiment?> findById(String id) =>
      (_db.select(_db.experiments)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> create(ExperimentsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.experiments).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, ExperimentsCompanion values) =>
      (_db.update(_db.experiments)..where((t) => t.id.equals(id)))
          .write(values);

  /// Hard-deletes the experiment (FK cascade removes its tasks and image
  /// attachments) and records tombstones for the experiment and every cascaded
  /// task and image.
  Future<void> delete(String id) =>
      TrashRepository(_db).trash('experiments', id);
}
