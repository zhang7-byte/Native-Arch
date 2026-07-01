import 'database.dart';
import 'schedule.dart';
import 'settings_repository.dart';
import 'workspace_repository.dart';

/// All schedule events on [date] — lab dates (tasks, experiments, projects,
/// manuscripts, cultures, reagents) plus personal events and holidays — scoped
/// to the current workspace. Shared by the dashboard and the schedule notifier.
Future<List<ScheduleEvent>> loadScheduleForDay(
    AppDatabase db, DateTime date) async {
  final day = DateTime(date.year, date.month, date.day);
  final ws = await currentWorkspaceId(db);
  List<T> scope<T>(List<T> rows, String Function(T) wsOf) =>
      ws == null ? rows : rows.where((x) => wsOf(x) == ws).toList();

  final tasks = scope(await db.select(db.tasks).get(), (t) => t.workspaceId);
  final experiments =
      scope(await db.select(db.experiments).get(), (e) => e.workspaceId);
  final projects =
      scope(await db.select(db.projects).get(), (p) => p.workspaceId);
  final manuscripts =
      scope(await db.select(db.manuscripts).get(), (m) => m.workspaceId);
  final cultures =
      scope(await db.select(db.cultures).get(), (c) => c.workspaceId);
  final reagents =
      scope(await db.select(db.reagents).get(), (r) => r.workspaceId);
  final customEvents =
      scope(await db.select(db.customEvents).get(), (c) => c.workspaceId);
  final region = (await SettingsRepository(db).get()).holidayRegion;

  final events = [
    ...buildSchedule(
      tasks: tasks,
      experiments: experiments,
      projects: projects,
      manuscripts: manuscripts,
      cultures: cultures,
      reagents: reagents,
    ),
    ...customEventOccurrences(customEvents, [day.year]),
    ...holidayOccurrences([day.year], region),
  ];
  return events.where((e) => e.date == day).toList();
}
