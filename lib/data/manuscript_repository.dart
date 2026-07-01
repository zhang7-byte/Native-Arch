import 'package:drift/drift.dart';

import 'database.dart';

/// Reads [Manuscript] rows. (Manuscripts are seeded; no create/edit UI yet.)
class ManuscriptRepository {
  ManuscriptRepository(this._db);

  final AppDatabase _db;

  Stream<List<Manuscript>> watchForProject(String projectId) {
    final query = _db.select(_db.manuscripts)
      ..where((t) => t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.watch();
  }

  Stream<Manuscript?> watchById(String id) =>
      (_db.select(_db.manuscripts)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();
}
