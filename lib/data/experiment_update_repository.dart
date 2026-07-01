import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [ExperimentUpdate] rows — the timestamped progress log on an
/// experiment. Newest first. Deleting an update cascades its image attachments.
class ExperimentUpdateRepository {
  ExperimentUpdateRepository(this._db);

  final AppDatabase _db;

  Stream<List<ExperimentUpdate>> watchForExperiment(String experimentId) =>
      (_db.select(_db.experimentUpdates)
            ..where((t) => t.experimentId.equals(experimentId))
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.happenedAt, mode: OrderingMode.desc)
            ]))
          .watch();

  Future<String> add({
    required String experimentId,
    required DateTime happenedAt,
    required String note,
  }) async {
    final ws = (await (_db.select(_db.experiments)
                  ..where((t) => t.id.equals(experimentId)))
                .getSingleOrNull())
            ?.workspaceId ??
        await currentWorkspaceId(_db) ??
        '';
    final id = uuid.v4();
    await _db.into(_db.experimentUpdates).insert(ExperimentUpdatesCompanion.insert(
          id: Value(id),
          experimentId: experimentId,
          happenedAt: Value(happenedAt),
          note: Value(note),
          workspaceId: Value(ws),
        ));
    return id;
  }

  Future<void> edit(String id,
          {required DateTime happenedAt, required String note}) =>
      (_db.update(_db.experimentUpdates)..where((t) => t.id.equals(id))).write(
          ExperimentUpdatesCompanion(
              happenedAt: Value(happenedAt), note: Value(note)));

  Future<void> delete(String id) =>
      TrashRepository(_db).trash('experiment_updates', id);
}
