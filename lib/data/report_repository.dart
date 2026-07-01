import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Report] rows as reactive streams, scoped to the current
/// workspace. Reports hold the PI-report header + written summary; their data
/// sections are gathered live at export time (see buildReportPdf).
class ReportRepository {
  ReportRepository(this._db);

  final AppDatabase _db;

  /// All reports in the current workspace, most-recently-updated first.
  Stream<List<Report>> watchAll() => _db
      .customSelect(
        'SELECT * FROM reports WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.reports, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.reports.map(r.data)).toList());

  Future<Report?> findById(String id) =>
      (_db.select(_db.reports)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> create(ReportsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.reports).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  Future<void> update(String id, ReportsCompanion values) =>
      (_db.update(_db.reports)..where((t) => t.id.equals(id))).write(values);

  Future<void> delete(String id) => TrashRepository(_db).trash('reports', id);
}
