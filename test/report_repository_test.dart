import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/report_repository.dart';

void main() {
  test('create, watchAll, delete + tombstone', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ReportRepository(db);

    await repo.create(
        ReportsCompanion(title: const Value('R1'), recipient: const Value('Dr. Su')));
    var list = await repo.watchAll().first;
    expect(list.length, 1);
    expect(list.first.title, 'R1');
    expect(list.first.recipient, 'Dr. Su');

    final id = list.first.id;
    await repo.update(id, const ReportsCompanion(summary: Value('Edited.')));
    expect((await repo.findById(id))!.summary, 'Edited.');

    await repo.delete(id);
    list = await repo.watchAll().first;
    expect(list, isEmpty);
    final tombs = await db.select(db.tombstones).get();
    expect(tombs.any((t) => t.id == id && t.entityTable == 'reports'), isTrue);
  });

  test('watchAll is scoped to the current workspace', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.reports).insert(ReportsCompanion.insert(
        title: const Value('A'), workspaceId: const Value('ws-a')));
    await db.into(db.reports).insert(ReportsCompanion.insert(
        title: const Value('B'), workspaceId: const Value('ws-b')));
    await db.into(db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: 'current_workspace', value: 'ws-a'));

    final list = await ReportRepository(db).watchAll().first;
    expect(list.map((r) => r.title).toList(), ['A']);
  });

  test('project / experiment selection round-trips', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ReportRepository(db);
    await repo.create(ReportsCompanion(
      title: const Value('Scoped'),
      projectIds: const Value(['p1', 'p2']),
      experimentIds: const Value(['e1']),
    ));
    final r = (await repo.watchAll().first).single;
    expect(r.projectIds, ['p1', 'p2']); // JSON list round-trips
    expect(r.experimentIds, ['e1']);
  });
}
