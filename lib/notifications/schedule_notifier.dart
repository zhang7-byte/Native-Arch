import '../data/database.dart';
import '../data/schedule.dart';
import '../data/schedule_query.dart';
import '../data/settings_repository.dart';
import 'notification_service.dart';

/// Notifies the user of a day's planned schedule — today's on app launch, and
/// the next day's as the app is closing (a heads-up for the day ahead). Honours
/// the device-local `scheduleNotify` preference. Delivery is via
/// [NotificationService] (desktop toasts / browser notifications).
class ScheduleNotifier {
  ScheduleNotifier(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  /// All schedule events (lab dates + personal events + holidays) on [date],
  /// scoped to the current workspace.
  Future<List<ScheduleEvent>> eventsOn(DateTime date) =>
      loadScheduleForDay(_db, date);

  String _body(List<ScheduleEvent> events) {
    if (events.length == 1) return events.first.title;
    final titles = events.take(3).map((e) => e.title).join(', ');
    return events.length <= 3 ? titles : '$titles  +${events.length - 3} more';
  }

  Future<bool> _enabled() async =>
      (await SettingsRepository(_db).get()).scheduleNotify;

  /// Today's schedule — call on app launch.
  Future<void> notifyToday() async {
    if (!await _enabled()) return;
    final events = await eventsOn(DateTime.now());
    if (events.isEmpty) return;
    await _notifications.show(
        "Today's schedule (${events.length})", _body(events));
  }

  /// Today's schedule on demand (e.g. from the tray menu): always shown, even
  /// when empty or when the launch/close notifications are switched off.
  Future<void> announceToday() async {
    final events = await eventsOn(DateTime.now());
    await _notifications.show("Today's schedule",
        events.isEmpty ? 'Nothing scheduled for today.' : _body(events));
  }

  /// Tomorrow's schedule — call as the app is closing.
  Future<void> notifyTomorrow() async {
    if (!await _enabled()) return;
    final now = DateTime.now();
    final events = await eventsOn(DateTime(now.year, now.month, now.day + 1));
    if (events.isEmpty) return;
    await _notifications.show(
        "Tomorrow's schedule (${events.length})", _body(events));
  }
}
