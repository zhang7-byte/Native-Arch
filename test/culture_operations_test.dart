import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/culture_event_repository.dart';
import 'package:labtrack/data/culture_repository.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/trash_repository.dart';

void main() {
  test('logs operations and split creates a child with lineage', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cultures = CultureRepository(db);
    final events = CultureEventRepository(db);

    final parentId = await cultures.create(CulturesCompanion(
        name: const Value('Mother'),
        startedDate: Value(DateTime(2026, 6, 1, 9))));

    await events.add(
        cultureId: parentId,
        happenedAt: DateTime(2026, 6, 2, 10),
        type: 'measurement',
        agent: 'OD600',
        amount: '0.82');
    var log = await events.watchForCulture(parentId).first;
    expect(log.length, 1);
    expect(log.first.agent, 'OD600');
    expect(log.first.amount, '0.82');

    final parent = await cultures.findById(parentId);
    final childId = (await cultures.split(
      parent: parent!,
      splitTime: DateTime(2026, 6, 3, 14),
      children: const [
        CultureSplitChild(
            name: 'Daughter', medium: 'LB', vessel: 'flask', amount: '5 mL')
      ],
    ))
        .first;
    final child = await cultures.findById(childId);
    expect(child!.parentCultureId, parentId);
    expect(child.parentInoculatedAt, DateTime(2026, 6, 1, 9)); // mother's start
    expect(child.startedDate, DateTime(2026, 6, 3, 14)); // split time
    expect(child.status, 'active');
    expect(child.strainId, parent.strainId);
    expect(child.medium, 'LB'); // per-child medium
    expect(child.inoculumAmount, '5 mL'); // amount stored on the child

    // The split is logged on the mother, with the amount taken.
    log = await events.watchForCulture(parentId).first;
    expect(log.length, 2);
    final splitEvent = log.firstWhere((e) => e.type == 'split');
    expect(splitEvent.amount, '5 mL');
  });

  test('split into multiple sub-cultures creates each + logs each', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cultures = CultureRepository(db);
    final events = CultureEventRepository(db);

    final parentId = await cultures.create(CulturesCompanion(
        name: const Value('Mother'),
        startedDate: Value(DateTime(2026, 6, 1))));
    final parent = await cultures.findById(parentId);

    final ids = await cultures.split(
      parent: parent!,
      splitTime: DateTime(2026, 6, 2),
      children: const [
        CultureSplitChild(
            name: 'A', medium: 'LB', vessel: 'tube', amount: '5 mL',
            annotation: 'high'),
        CultureSplitChild(
            name: 'B', medium: 'TB', vessel: 'flask', amount: '2 mL',
            annotation: 'low'),
      ],
    );
    expect(ids.length, 2);
    final a = await cultures.findById(ids[0]);
    expect(a!.notes, 'high'); // annotation stored as the child's notes
    expect(a.medium, 'LB'); // each sub-culture keeps its own medium
    expect(a.inoculumAmount, '5 mL');
    final b = await cultures.findById(ids[1]);
    expect(b!.medium, 'TB');
    expect(a.parentCultureId, parentId);
    // one split log entry per sub-culture
    final log = await events.watchForCulture(parentId).first;
    expect(log.where((e) => e.type == 'split').length, 2);
  });

  test('culture stores selection markers + inoculum; split inherits markers',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cultures = CultureRepository(db);

    final id = await cultures.create(CulturesCompanion(
        name: const Value('M'),
        inoculumAmount: const Value('1:100'),
        selectionMarkers: const Value(['Kan', 'Amp']),
        startedDate: Value(DateTime(2026, 6, 1))));
    final c = await cultures.findById(id);
    expect(c!.inoculumAmount, '1:100');
    expect(c.selectionMarkers, ['Kan', 'Amp']);

    final childId = (await cultures.split(
      parent: c,
      splitTime: DateTime(2026, 6, 2),
      children: const [CultureSplitChild(name: 'D')],
    ))
        .first;
    final child = await cultures.findById(childId);
    expect(child!.selectionMarkers, ['Kan', 'Amp']); // inherited from mother
  });

  test('deleting a culture trashes its operations log (restorable)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cultures = CultureRepository(db);
    final events = CultureEventRepository(db);

    final id = await cultures.create(const CulturesCompanion(name: Value('C')));
    await events.add(
        cultureId: id,
        happenedAt: DateTime(2026, 6, 1),
        type: 'sampling',
        amount: '1 mL');
    expect((await events.watchForCulture(id).first).length, 1);

    final trash = TrashRepository(db);
    await trash.trash('cultures', id);
    expect(await events.watchForCulture(id).first, isEmpty);

    final entry = (await trash.watchAll().first).first;
    await trash.restore(entry.id);
    expect((await events.watchForCulture(id).first).length, 1);
  });
}
