import 'package:flutter/widgets.dart';

import '../../sync/sync_controller.dart';

/// Exposes the [SyncController] to the widget tree and rebuilds dependents when
/// it notifies (auth/sync state changes).
class SyncScope extends InheritedNotifier<SyncController> {
  const SyncScope({
    super.key,
    required SyncController controller,
    required super.child,
  }) : super(notifier: controller);

  static SyncController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SyncScope>();
    assert(scope != null, 'No SyncScope found in the widget tree');
    return scope!.notifier!;
  }
}
