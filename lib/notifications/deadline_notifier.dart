import 'dart:async';

import '../data/database.dart';
import '../data/settings_repository.dart';
import '../ui/deadlines/deadline_item.dart';
import '../ui/labels.dart';
import 'notification_service.dart';

/// How often the app reminds about due/overdue deadlines while it is open.
/// Persisted as [key] in app_settings (device-local).
enum NotifyFrequency {
  off('off', 'Off'),
  daily('daily', 'Once a day'),
  twiceDaily('twice_daily', 'Twice a day'),
  every6h('every_6h', 'Every 6 hours'),
  hourly('hourly', 'Every hour');

  const NotifyFrequency(this.key, this.label);
  final String key;
  final String label;

  /// Minimum time between reminders; null means notifications are off.
  Duration? get interval => switch (this) {
        off => null,
        daily => const Duration(hours: 24),
        twiceDaily => const Duration(hours: 12),
        every6h => const Duration(hours: 6),
        hourly => const Duration(hours: 1),
      };

  static NotifyFrequency fromKey(String key) =>
      values.firstWhere((f) => f.key == key, orElse: () => daily);
}

/// Deadlines (tasks + experiments) that are overdue or due today and not done.
/// Pure, so the notification trigger is unit-testable.
List<DeadlineItem> deadlinesNeedingAttention(
    List<Task> tasks, List<Experiment> experiments, DateTime now) {
  return buildDeadlines(tasks, experiments)
      .where((d) => !d.done && (daysUntil(d.date, now) ?? 1) <= 0)
      .toList();
}

/// Whether enough time has elapsed since [last] to remind again at [freq].
bool shouldNotifyNow(NotifyFrequency freq, DateTime? last, DateTime now) {
  final interval = freq.interval;
  if (interval == null) return false;
  if (last == null) return true;
  return now.difference(last) >= interval;
}

/// The notification body for a set of due/overdue items.
String deadlineNotificationBody(List<DeadlineItem> items, DateTime now) {
  bool isOverdue(DeadlineItem d) => (daysUntil(d.date, now) ?? 0) < 0;
  if (items.length == 1) {
    final d = items.first;
    return '"${d.title}" (${d.kind.toLowerCase()}) is '
        '${isOverdue(d) ? 'overdue' : 'due today'}.';
  }
  final overdue = items.where(isOverdue).length;
  final today = items.length - overdue;
  final parts = <String>[
    if (overdue > 0) '$overdue overdue',
    if (today > 0) '$today due today',
  ];
  return '${items.length} deadlines need attention (${parts.join(', ')}).';
}

/// Periodically reminds about due/overdue deadlines while the app is open, at the
/// user's chosen [NotifyFrequency]. The last-reminded time is stored per device
/// (in `sync_meta`), so restarting the app does not re-notify within the
/// interval. Delivery is handled by [NotificationService] (desktop toasts /
/// browser notifications), so this works on every platform that supports them.
class DeadlineNotifier {
  DeadlineNotifier(this._db, this._notifications);

  final AppDatabase _db;
  final NotificationService _notifications;

  Timer? _timer;
  static const _lastKey = 'last_deadline_notification';
  // Re-check this often; each tick still respects the chosen interval.
  static const _tick = Duration(minutes: 5);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => checkNow());
  }

  void dispose() => _timer?.cancel();

  Future<DateTime?> _lastNotified() async {
    final row = await (_db.select(_db.syncMeta)
          ..where((t) => t.key.equals(_lastKey)))
        .getSingleOrNull();
    final v = row?.value;
    return (v == null || v.isEmpty) ? null : DateTime.tryParse(v);
  }

  Future<void> _setLastNotified(DateTime when) =>
      _db.into(_db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(
          key: _lastKey, value: when.toUtc().toIso8601String()));

  /// Checks once: if the cadence allows and there are due deadlines, notify.
  /// Safe to call on startup, on resume, and from the periodic timer.
  Future<void> checkNow() async {
    final settings = await SettingsRepository(_db).get();
    final freq = NotifyFrequency.fromKey(settings.notifyFrequency);
    if (freq.interval == null) return;

    final now = DateTime.now();
    if (!shouldNotifyNow(freq, await _lastNotified(), now)) return;

    final tasks = await _db.select(_db.tasks).get();
    final experiments = await _db.select(_db.experiments).get();
    final due = deadlinesNeedingAttention(tasks, experiments, now);
    if (due.isEmpty) return;

    await _notifications.show(
        'Deadlines need attention', deadlineNotificationBody(due, now));
    await _setLastNotified(now);
  }
}
