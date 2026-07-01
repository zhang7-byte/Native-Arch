import '../data/database.dart';
import '../data/workspace_repository.dart';
import 'notification_service.dart';

/// Announces the lab's high-priority work — high-priority open tasks plus
/// in-progress (running) experiments — as a notification. Used from the tray
/// menu so it works while the window is hidden.
Future<void> announceHighPriority(
    AppDatabase db, NotificationService notifications) async {
  final ws = await currentWorkspaceId(db);
  List<T> scope<T>(List<T> rows, String Function(T) wsOf) =>
      ws == null ? rows : rows.where((x) => wsOf(x) == ws).toList();

  final tasks = scope(await db.select(db.tasks).get(), (t) => t.workspaceId)
      .where((t) =>
          t.priority == Priority.high && t.status != TaskStatus.done)
      .toList();
  final running =
      scope(await db.select(db.experiments).get(), (e) => e.workspaceId)
          .where((e) => e.status == ExperimentStatus.running)
          .toList();

  if (tasks.isEmpty && running.isEmpty) {
    await notifications.show(
        'High priority', 'No high-priority tasks or running experiments.');
    return;
  }

  String plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
  final head = [
    if (tasks.isNotEmpty) plural(tasks.length, 'high-priority task'),
    if (running.isNotEmpty) plural(running.length, 'running experiment'),
  ].join(', ');

  final titles = [
    ...tasks.map((t) => t.title),
    ...running.map((e) => e.title),
  ];
  final shown = titles.take(5).join(', ');
  final more = titles.length > 5 ? '  +${titles.length - 5} more' : '';
  await notifications.show('High priority — $head', '$shown$more');
}
