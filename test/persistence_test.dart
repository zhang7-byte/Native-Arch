import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/project_repository.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('labtrack_persist');
    file = File('${dir.path}/labtrack.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  // Opens the on-disk database, runs [body], then closes it — i.e. simulates an
  // app restart against the same SQLite file.
  Future<T> session<T>(
    Future<T> Function(AppDatabase db) body, {
    bool seed = false,
  }) async {
    final db = AppDatabase(NativeDatabase(file), seed);
    try {
      return await body(db);
    } finally {
      await db.close();
    }
  }

  test('seed + create/edit/delete all persist across restarts', () async {
    // Session 1 — first run seeds the six projects.
    await session((db) async {
      expect(await db.select(db.projects).get(), hasLength(6));
    }, seed: true);

    // Session 2 (restart) — seed persisted; CREATE a new project.
    final newId = await session((db) async {
      expect(await db.select(db.projects).get(), hasLength(6));
      await ProjectRepository(db)
          .create(ProjectsCompanion.insert(title: 'Restart probe'));
      final probe = await (db.select(db.projects)
            ..where((t) => t.title.equals('Restart probe')))
          .getSingle();
      return probe.id;
    });

    // Session 3 (restart) — the create persisted; EDIT the title.
    await session((db) async {
      expect(await db.select(db.projects).get(), hasLength(7));
      await ProjectRepository(db).update(
        newId,
        const ProjectsCompanion(title: Value('Restart probe (edited)')),
      );
    });

    // Session 4 (restart) — the edit persisted; DELETE it.
    await session((db) async {
      final probe = await (db.select(db.projects)
            ..where((t) => t.id.equals(newId)))
          .getSingle();
      expect(probe.title, 'Restart probe (edited)');
      await ProjectRepository(db).delete(newId);
    });

    // Session 5 (restart) — the delete persisted; back to six projects.
    await session((db) async {
      final projects = await db.select(db.projects).get();
      expect(projects, hasLength(6));
      expect(projects.where((p) => p.id == newId), isEmpty);
    });
  });
}
