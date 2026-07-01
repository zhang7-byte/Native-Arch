import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

import 'notification_service.dart';
import 'notification_service_mobile.dart';

/// Picks the native implementation at runtime: flutter_local_notifications on
/// Android/iOS, local_notifier on desktop (both are non-web "io" platforms, so a
/// single conditional-import entry covers them).
NotificationService create() {
  final p = defaultTargetPlatform;
  if (p == TargetPlatform.android || p == TargetPlatform.iOS) {
    return MobileNotificationService();
  }
  return _DesktopNotificationService();
}

/// Desktop (Windows / macOS / Linux) OS notifications via `local_notifier`.
///
/// This is the non-web implementation. On a desktop target it shows real system
/// toasts; on mobile, where the plugin isn't available, every call fails
/// gracefully so the app behaves as if notifications are simply unsupported.
class _DesktopNotificationService implements NotificationService {
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    try {
      await localNotifier.setup(appName: 'LabTrack');
      _ready = true;
    } catch (_) {
      // Not a supported desktop platform (e.g. mobile) — notifications no-op.
    }
  }

  @override
  Future<void> show(String title, String body) async {
    if (!_ready) return;
    try {
      await LocalNotification(title: title, body: body).show();
    } catch (_) {
      // Best-effort — never let a failed toast surface to the user.
    }
  }
}
