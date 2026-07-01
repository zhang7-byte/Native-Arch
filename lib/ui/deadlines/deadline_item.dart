import '../../data/database.dart';
import '../labels.dart';

/// A dated task or experiment, used by the Deadlines view and the Dashboard.
class DeadlineItem {
  DeadlineItem({
    required this.date,
    required this.title,
    required this.isTask,
    required this.id,
    required this.statusLabel,
    required this.done,
    this.task,
  });

  final DateTime date;
  final String title;
  final bool isTask;
  final String id;
  final String statusLabel;
  final bool done;

  /// The source task (set only when [isTask]); experiments navigate by [id].
  final Task? task;

  String get kind => isTask ? 'Task' : 'Experiment';
}

/// Builds a date-sorted list of deadlines from dated tasks and experiments.
List<DeadlineItem> buildDeadlines(
    List<Task> tasks, List<Experiment> experiments) {
  return <DeadlineItem>[
    for (final t in tasks)
      if (t.dueDate != null)
        DeadlineItem(
          date: t.dueDate!,
          title: t.title,
          isTask: true,
          id: t.id,
          statusLabel: enumLabel(t.status),
          done: t.status == TaskStatus.done,
          task: t,
        ),
    for (final e in experiments)
      if (e.date != null)
        DeadlineItem(
          date: e.date!,
          title: e.title,
          isTask: false,
          id: e.id,
          statusLabel: enumLabel(e.status),
          done: e.status == ExperimentStatus.done,
        ),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// Tasks (not done) due on [now]'s calendar day — drives the due-today
/// notification.
List<Task> tasksDueToday(List<Task> tasks, DateTime now) {
  return tasks.where((t) {
    if (t.dueDate == null || t.status == TaskStatus.done) return false;
    return daysUntil(t.dueDate, now) == 0;
  }).toList();
}
