import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes [Project] rows. The list is exposed as a reactive stream so
/// the UI updates automatically after any create / edit / delete.
class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;

  /// All projects in the current workspace, most-recently-updated first. Emits
  /// again on every change (including switching workspace).
  Stream<List<Project>> watchAll() => _db
      .customSelect(
        'SELECT * FROM projects WHERE $workspaceScopeWhere '
        'ORDER BY updated_at DESC',
        readsFrom: {_db.projects, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.projects.map(r.data)).toList());

  /// A single project, kept live so a detail screen reflects edits/deletes.
  Stream<Project?> watchById(String id) =>
      (_db.select(_db.projects)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<List<Project>> all() => _db.select(_db.projects).get();

  Future<Project?> findById(String id) =>
      (_db.select(_db.projects)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> create(ProjectsCompanion values) async {
    final ws = await currentWorkspaceId(_db);
    await _db.into(_db.projects).insert(
        ws == null ? values : values.copyWith(workspaceId: Value(ws)));
  }

  /// Updates the editable columns of the project with [id]. `updated_at` is left
  /// out so the database trigger stamps a fresh timestamp.
  Future<void> update(String id, ProjectsCompanion values) =>
      (_db.update(_db.projects)..where((t) => t.id.equals(id))).write(values);

  /// Moves the project — and everything that cascades from it (experiments,
  /// tasks, manuscripts, progress logs, images) — to the Trash, reversibly.
  Future<void> delete(String id) => TrashRepository(_db).trash('projects', id);
}
