import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/schedule.dart';

void main() {
  test('buildSchedule aggregates every dated entity', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.projects).insert(ProjectsCompanion.insert(
        id: const Value('p1'),
        title: 'P',
        startDate: Value(DateTime(2026, 6, 1)),
        targetDate: Value(DateTime(2026, 6, 30))));
    await db.into(db.experiments).insert(ExperimentsCompanion.insert(
        id: const Value('e1'),
        projectId: 'p1',
        title: 'Exp',
        date: Value(DateTime(2026, 6, 15))));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        id: const Value('t1'),
        title: 'Task',
        dueDate: Value(DateTime(2026, 6, 15))));
    await db.into(db.tasks).insert(
        TasksCompanion.insert(id: const Value('t2'), title: 'No date'));
    await db.into(db.reagents).insert(ReagentsCompanion.insert(
        id: const Value('r1'),
        name: 'R',
        expiryDate: Value(DateTime(2026, 6, 20))));

    final events = buildSchedule(
      tasks: await db.select(db.tasks).get(),
      experiments: await db.select(db.experiments).get(),
      projects: await db.select(db.projects).get(),
      manuscripts: const [],
      cultures: const [],
      reagents: await db.select(db.reagents).get(),
    );
    // project start + target + experiment + dated task + reagent (no-date task
    // excluded).
    expect(events.length, 5);
    expect(events.first.date, DateTime(2026, 6, 1)); // date-sorted
    final byDay = groupByDay(events);
    expect(byDay[DateTime(2026, 6, 15)]!.length, 2); // experiment + task
  });

  test('customEventOccurrences: annual repeats per year, one-off once',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.customEvents).insert(CustomEventsCompanion.insert(
        title: 'Birthday',
        date: DateTime(2000, 3, 15),
        category: const Value('birthday'),
        repeatAnnually: const Value(true)));
    await db.into(db.customEvents).insert(CustomEventsCompanion.insert(
        title: 'Lab party', date: DateTime(2026, 5, 1)));

    final occ = customEventOccurrences(
        await db.select(db.customEvents).get(), [2025, 2026]);
    final birthdays = occ.where((e) => e.title == 'Birthday').toList();
    expect(birthdays.length, 2); // one per year in the window
    expect(birthdays.every((e) => e.kind == ScheduleKind.birthday), isTrue);
    expect(occ.any((e) => e.date == DateTime(2025, 3, 15)), isTrue);
    expect(occ.any((e) => e.date == DateTime(2026, 3, 15)), isTrue);
    final party = occ.where((e) => e.title == 'Lab party').toList();
    expect(party.length, 1); // not recurring
    expect(party.first.kind, ScheduleKind.personal);
  });

  test('holidayOccurrences are holiday-kind on the right dates', () {
    final occ = holidayOccurrences([2026], 'us');
    expect(occ.every((e) => e.kind == ScheduleKind.holiday), isTrue);
    expect(
        occ.any((e) =>
            e.title == 'Independence Day' && e.date == DateTime(2026, 7, 4)),
        isTrue);
    expect(holidayOccurrences([2026], 'none'), isEmpty);
  });

  test('monthCells: full weeks, Monday start, exact midnights', () {
    final cells = monthCells(DateTime(2026, 6, 1));
    expect(cells.length % 7, 0);
    expect(cells.first.weekday, DateTime.monday);
    expect(cells.contains(DateTime(2026, 6, 15)), isTrue);
    expect(cells.contains(DateTime(2026, 6, 30)), isTrue);
    for (final c in cells) {
      expect(c.hour, 0); // clean midnight
    }
  });
}
