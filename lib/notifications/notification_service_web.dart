import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'notification_service.dart';

NotificationService create() => _WebNotificationService();

/// Browser Notification API implementation (works on a phone PWA after the user
/// grants permission).
class _WebNotificationService implements NotificationService {
  @override
  Future<void> init() async {
    try {
      if (web.Notification.permission == 'default') {
        await web.Notification.requestPermission().toDart;
      }
    } catch (_) {
      // Notifications unsupported in this browser — ignore.
    }
  }

  @override
  Future<void> show(String title, String body) async {
    try {
      if (web.Notification.permission == 'granted') {
        web.Notification(title, web.NotificationOptions(body: body));
      }
    } catch (_) {
      // Ignore — notifications are best-effort.
    }
  }
}
