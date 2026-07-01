import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/ui/deadlines/deadline_item.dart';

void main() {
  test('buildDeadlines merges dated tasks + experiments, sorted by date',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.projects).insert(ProjectsCompanion.insert(title: 'P'));
    final p = await db.select(db.projects).getSingle();
    await db.into(db.experiments).insert(ExperimentsCompanion.insert(
        projectId: p.id, title: 'Exp', date: Value(DateTime.utc(2026, 7, 1))));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'TaskA', dueDate: Value(DateTime.utc(2026, 6, 20))));
    await db.into(db.tasks).insert(TasksCompanion.insert(title: 'NoDate'));

    final items = buildDeadlines(
        await db.select(db.tasks).get(), await db.select(db.experiments).get());
    expect(items.map((d) => d.title), ['TaskA', 'Exp']); // ascending by date
    expect(items.any((d) => d.title == 'NoDate'), isFalse); // undated excluded
  });

  test('tasksDueToday returns not-done tasks due on the given day', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 6, 25, 10);
    await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'today', dueDate: Value(DateTime(2026, 6, 25))));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'done-today',
        dueDate: Value(DateTime(2026, 6, 25)),
        status: const Value(TaskStatus.done)));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        title: 'tomorrow', dueDate: Value(DateTime(2026, 6, 26))));

    final due = tasksDueToday(await db.select(db.tasks).get(), now);
    expect(due.map((t) => t.title), ['today']);
  });
}
