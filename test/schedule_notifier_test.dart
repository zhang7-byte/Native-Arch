import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/settings_repository.dart';
import 'package:labtrack/notifications/notification_service.dart';
import 'package:labtrack/notifications/schedule_notifier.dart';

/// Captures notifications instead of showing them.
class _FakeNotifications implements NotificationService {
  final List<(String, String)> shown = [];
  @override
  Future<void> init() async {}
  @override
  Future<void> show(String title, String body) async =>
      shown.add((title, body));
}

void main() {
  test('notifies today + tomorrow and honours the toggle', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakeNotifications();
    final notifier = ScheduleNotifier(db, fake);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    await db.into(db.tasks).insert(
        TasksCompanion.insert(title: 'Today task', dueDate: Value(today)));
    await db.into(db.customEvents).insert(CustomEventsCompanion.insert(
        title: 'Tomorrow event', date: tomorrow));

    await notifier.notifyToday();
    expect(fake.shown.length, 1);
    expect(fake.shown.first.$2, contains('Today task'));

    await notifier.notifyTomorrow();
    expect(fake.shown.length, 2);
    expect(fake.shown.last.$2, contains('Tomorrow event'));

    // Turning the preference off silences both.
    await SettingsRepository(db).save(scheduleNotify: false);
    await notifier.notifyToday();
    await notifier.notifyTomorrow();
    expect(fake.shown.length, 2); // unchanged
  });
}
