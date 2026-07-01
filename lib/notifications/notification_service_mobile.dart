import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Android / iOS local notifications via `flutter_local_notifications`.
class MobileNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  int _nextId = 0;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'labtrack_reminders',
      'Reminders',
      channelDescription: 'Deadline and schedule reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);
      // Android 13+ and iOS require a runtime notification permission.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  @override
  Future<void> show(String title, String body) async {
    if (!_ready) return;
    try {
      // Distinct ids so reminders stack instead of replacing each other.
      await _plugin.show(
          id: _nextId++ & 0x7fffffff,
          title: title,
          body: body,
          notificationDetails: _details);
    } catch (_) {
      // Best-effort — never surface a failed toast to the user.
    }
  }
}
