import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/workspace_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  test('upgrades a v3 database to v5 cleanly (existing-install path)', () async {
    final dir = Directory.systemTemp.createTempSync('lt_mig');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/v3.sqlite';

    // Hand-build a minimal v3 database: the entity tables exist, but there are
    // no images/workspaces tables and no workspace_id columns yet.
    final raw = sql.sqlite3.open(path);
    raw.execute('PRAGMA user_version = 3');
    raw.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'planning',
        priority TEXT NOT NULL DEFAULT 'medium',
        start_date TEXT, target_date TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL)''');
    raw.execute(
        "INSERT INTO projects (id, title, created_at, updated_at) VALUES "
        "('p1', 'Legacy project', '2026-01-01T00:00:00.000Z', "
        "'2026-01-01T00:00:00.000Z')");
    for (final t in ['experiments', 'tasks', 'strains', 'reagents', 'manuscripts']) {
      raw.execute('CREATE TABLE $t (id TEXT PRIMARY KEY, updated_at TEXT)');
    }
    raw.execute(
        'CREATE TABLE sync_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
    // app_settings exists from v3 (pre-background columns).
    raw.execute('''
      CREATE TABLE app_settings (
        id INTEGER NOT NULL DEFAULT 0,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        accent_color INTEGER NOT NULL DEFAULT 4278228616,
        density TEXT NOT NULL DEFAULT 'comfortable',
        updated_at TEXT NOT NULL DEFAULT '2026-01-01T00:00:00.000Z',
        PRIMARY KEY (id))''');
    raw.close();

    // Open with the app — this runs the v3 -> v5 migration. It used to throw
    // "no such table: workspaces" because the updated_at triggers ran before
    // the v5 step created those tables.
    final db = AppDatabase(NativeDatabase(File(path)));
    addTearDown(db.close);

    // Triggers the migration, then the startup bootstrap (default workspace).
    final wsId = await ensureDefaultWorkspace(db);

    // The legacy row survived and moved into the default workspace.
    final p = (await db.select(db.projects).get()).single;
    expect(p.id, 'p1');
    expect(p.title, 'Legacy project');
    expect(p.workspaceId, wsId);

    // The v5 tables exist and work.
    expect(await db.select(db.workspaces).get(), isNotEmpty);
    expect(await WorkspaceRepository(db).currentId(), wsId);
  });
}
