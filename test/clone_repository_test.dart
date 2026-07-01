import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/clone_repository.dart';
import 'package:labtrack/data/database.dart';

void main() {
  test('create with fragments round-trips, watchAll, delete + tombstone',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = CloneRepository(db);

    await repo.create(CloneConstructionsCompanion(
      name: const Value('pLT-GFP'),
      backboneName: const Value('pUC19'),
      backboneStrainId: const Value('s-bb'),
      enzymes: const Value('EcoRI'),
      fragments: Value(const [
        CloneFragment(
            name: 'GFP',
            templateStrainId: 's1',
            fwdPrimerId: 'p1',
            revPrimerId: 'p2',
            sizeBp: '0.7 kb'),
        CloneFragment(name: 'hLFABP', templateStrainId: 's2'),
      ]),
    ));

    final list = await repo.watchAll().first;
    expect(list.length, 1);
    final c = list.first;
    expect(c.name, 'pLT-GFP');
    expect(c.backboneStrainId, 's-bb');
    expect(c.enzymes, 'EcoRI');
    expect(c.fragments.length, 2); // JSON converter round-trips
    expect(c.fragments.first.name, 'GFP');
    expect(c.fragments.first.fwdPrimerId, 'p1');
    expect(c.fragments[1].templateStrainId, 's2');

    await repo.delete(c.id);
    expect(await repo.watchAll().first, isEmpty);
    final tombs = await db.select(db.tombstones).get();
    expect(
        tombs.any(
            (t) => t.id == c.id && t.entityTable == 'clone_constructions'),
        isTrue);
  });

  test('watchAll is scoped to the current workspace', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.cloneConstructions).insert(CloneConstructionsCompanion(
        name: const Value('A'), workspaceId: const Value('ws-a')));
    await db.into(db.cloneConstructions).insert(CloneConstructionsCompanion(
        name: const Value('B'), workspaceId: const Value('ws-b')));
    await db.into(db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: 'current_workspace', value: 'ws-a'));

    final list = await CloneRepository(db).watchAll().first;
    expect(list.map((c) => c.name).toList(), ['A']);
  });
}
