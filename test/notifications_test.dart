import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/csv_import.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/notifications/deadline_notifier.dart';
import 'package:labtrack/ui/deadlines/deadline_item.dart';

void main() {
  group('NotifyFrequency', () {
    test('intervals and key lookup', () {
      expect(NotifyFrequency.off.interval, isNull);
      expect(NotifyFrequency.daily.interval, const Duration(hours: 24));
      expect(NotifyFrequency.twiceDaily.interval, const Duration(hours: 12));
      expect(NotifyFrequency.hourly.interval, const Duration(hours: 1));
      expect(NotifyFrequency.fromKey('every_6h'), NotifyFrequency.every6h);
      expect(NotifyFrequency.fromKey('nonsense'), NotifyFrequency.daily);
    });
  });

  group('shouldNotifyNow', () {
    final now = DateTime(2026, 6, 26, 12);
    test('off never fires', () {
      expect(shouldNotifyNow(NotifyFrequency.off, null, now), isFalse);
    });
    test('fires when never notified before', () {
      expect(shouldNotifyNow(NotifyFrequency.daily, null, now), isTrue);
    });
    test('respects the interval', () {
      expect(
          shouldNotifyNow(NotifyFrequency.daily,
              now.subtract(const Duration(hours: 1)), now),
          isFalse);
      expect(
          shouldNotifyNow(NotifyFrequency.daily,
              now.subtract(const Duration(hours: 25)), now),
          isTrue);
      expect(
          shouldNotifyNow(NotifyFrequency.hourly,
              now.subtract(const Duration(minutes: 61)), now),
          isTrue);
    });
  });

  test('deadlinesNeedingAttention = overdue/today and not done', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.now();

    Future<void> task(String title, DateTime? due, TaskStatus status) =>
        db.into(db.tasks).insert(TasksCompanion.insert(
            title: title,
            dueDate: Value(due),
            status: Value(status)));

    await task('Overdue', now.subtract(const Duration(days: 2)), TaskStatus.todo);
    await task('Today', now, TaskStatus.todo);
    await task('Today done', now, TaskStatus.done);
    await task('Future', now.add(const Duration(days: 5)), TaskStatus.todo);
    await task('No date', null, TaskStatus.todo);

    final tasks = await db.select(db.tasks).get();
    final due = deadlinesNeedingAttention(tasks, const [], now);
    expect(due.map((d) => d.title).toSet(), {'Overdue', 'Today'});
  });

  test('deadlineNotificationBody phrasing', () {
    final now = DateTime(2026, 6, 26, 9);
    final overdue = DeadlineItem(
        date: now.subtract(const Duration(days: 1)),
        title: 'Western blot',
        isTask: true,
        id: '1',
        statusLabel: 'To do',
        done: false);
    final today = DeadlineItem(
        date: now,
        title: 'Kinetics run',
        isTask: false,
        id: '2',
        statusLabel: 'Planned',
        done: false);

    expect(deadlineNotificationBody([overdue], now),
        '"Western blot" (task) is overdue.');
    expect(deadlineNotificationBody([today], now),
        '"Kinetics run" (experiment) is due today.');
    final both = deadlineNotificationBody([overdue, today], now);
    expect(both, contains('2 deadlines need attention'));
    expect(both, contains('1 overdue'));
    expect(both, contains('1 due today'));
  });

  test('sample CSV templates match the importer and validate cleanly', () {
    for (final e in ImportEntity.values) {
      final parsed = parseCsv(sampleCsv(e));
      // Header is exactly the importer's field keys.
      expect(parsed.headers, fieldsFor(e).map((f) => f.key).toList());
      expect(parsed.rows.length, 2);

      final mapping = autoMapping(parsed.headers, e);
      for (final f in fieldsFor(e)) {
        expect(mapping.containsKey(f.key), isTrue,
            reason: '${f.key} not auto-mapped for $e');
      }
      for (final row in parsed.rows) {
        expect(rowProblems(e, row, mapping), isEmpty,
            reason: 'row $row invalid for $e');
      }
    }
  });
}
