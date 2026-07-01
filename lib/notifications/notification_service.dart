import 'notification_service_stub.dart'
    if (dart.library.js_interop) 'notification_service_web.dart' as impl;

/// Cross-platform local notifications.
///
/// On web / PWA this uses the browser Notification API (real OS notifications on
/// a phone). On other platforms it is currently a no-op; a
/// `flutter_local_notifications`-backed implementation can drop in behind this
/// same interface for native builds.
abstract class NotificationService {
  Future<void> init();
  Future<void> show(String title, String body);

  factory NotificationService() => impl.create();
}
