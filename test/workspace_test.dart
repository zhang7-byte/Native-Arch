import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/project_repository.dart';
import 'package:labtrack/data/workspace_repository.dart';

void main() {
  test('ensureDefaultWorkspace creates a default and backfills untagged rows',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A pre-workspace project (workspace_id defaults to '').
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'Legacy'));

    final wsId = await ensureDefaultWorkspace(db);

    final workspaces = await db.select(db.workspaces).get();
    expect(workspaces.length, 1);
    expect(wsId, workspaces.first.id);
    expect(await WorkspaceRepository(db).currentId(), wsId);
    // The legacy project moved into the default workspace.
    final p = (await db.select(db.projects).get()).single;
    expect(p.workspaceId, wsId);

    // Idempotent: running again keeps one workspace and the same current id.
    final again = await ensureDefaultWorkspace(db);
    expect(again, wsId);
    expect((await db.select(db.workspaces).get()).length, 1);
  });

  test('repositories scope reads to the current workspace', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = WorkspaceRepository(db);
    final w1 = await repo.create('Lab A');
    final w2 = await repo.create('Lab B');
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(title: 'A1', workspaceId: Value(w1)));
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(title: 'B1', workspaceId: Value(w2)));

    final projects = ProjectRepository(db);
    await repo.setCurrent(w1);
    expect((await projects.watchAll().first).map((p) => p.title).toList(),
        ['A1']);
    await repo.setCurrent(w2);
    expect((await projects.watchAll().first).map((p) => p.title).toList(),
        ['B1']);
  });

  test('create tags new rows with the current workspace', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = WorkspaceRepository(db);
    final w1 = await repo.create('Lab A');
    await repo.setCurrent(w1);

    await ProjectRepository(db).create(ProjectsCompanion.insert(title: 'New'));

    final p = (await db.select(db.projects).get()).single;
    expect(p.workspaceId, w1);
  });
}
