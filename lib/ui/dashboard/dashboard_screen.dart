import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/project_repository.dart';
import '../../data/reagent_repository.dart';
import '../../data/schedule.dart';
import '../../data/schedule_query.dart';
import '../../data/task_repository.dart';
import '../../platform/window_title_bar.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../deadlines/deadline_item.dart';
import '../experiments/experiment_detail_screen.dart';
import '../labels.dart';
import '../schedule/schedule_screen.dart' show kScheduleColors;
import '../search/global_search.dart';
import '../tasks/task_edit_screen.dart';
import '../widgets.dart';

/// At-a-glance counts and upcoming deadlines.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [AccountButton()],
      ),
      body: StreamBuilder<List<Project>>(
        stream: ProjectRepository(db).watchAll(),
        builder: (context, ps) => StreamBuilder<List<Experiment>>(
          stream: ExperimentRepository(db).watchAll(),
          builder: (context, es) => StreamBuilder<List<Reagent>>(
            stream: ReagentRepository(db).watchAll(),
            builder: (context, rs) => StreamBuilder<List<Task>>(
              stream: TaskRepository(db).watchAll(),
              builder: (context, tsq) => StreamBuilder<List<Culture>>(
                stream: CultureRepository(db).watchActive(),
                builder: (context, cs) {
                  if (!ps.hasData ||
                      !es.hasData ||
                      !rs.hasData ||
                      !tsq.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final projects = ps.data!;
                  final experiments = es.data!;
                  final reagents = rs.data!;
                  final tasks = tsq.data!;
                  final cultures = cs.data ?? const <Culture>[];

                  final expiring = reagents.where((r) {
                    final s = expiryState(r.expiryDate, now);
                    return s == ExpiryState.soon || s == ExpiryState.expired;
                  }).toList()
                    ..sort((a, b) =>
                        (a.expiryDate ?? now).compareTo(b.expiryDate ?? now));

                  final allDeadlines = buildDeadlines(tasks, experiments);
                  final overdue = allDeadlines
                      .where((d) =>
                          !d.done && (daysUntil(d.date, now) ?? 1) < 0)
                      .length;
                  final upcoming = allDeadlines
                      .where((d) =>
                          !d.done && (daysUntil(d.date, now) ?? -1) >= 0)
                      .take(8)
                      .toList();
                  final openTasks =
                      tasks.where((t) => t.status != TaskStatus.done).length;
                  final runningExp = experiments
                      .where((e) => e.status == ExperimentStatus.running)
                      .length;

                  final kpis = <Widget>[
                    _StatCard(
                        icon: Icons.science_outlined,
                        value: projects.length,
                        label: 'Projects',
                        color: scheme.primary),
                    _StatCard(
                        icon: Icons.biotech_outlined,
                        value: runningExp,
                        label: 'Running exp.',
                        color: const Color(0xFF00897B)),
                    _StatCard(
                        icon: Icons.checklist_outlined,
                        value: openTasks,
                        label: 'Open tasks',
                        color: const Color(0xFF1E88E5)),
                    _StatCard(
                        icon: Icons.error_outline,
                        value: overdue,
                        label: 'Overdue',
                        color: const Color(0xFFE53935)),
                    _StatCard(
                        icon: Icons.bubble_chart_outlined,
                        value: cultures.length,
                        label: 'Active cultures',
                        color: const Color(0xFF8E24AA)),
                    _StatCard(
                        icon: Icons.warning_amber_rounded,
                        value: expiring.length,
                        label: 'Expiring reagents',
                        color: const Color(0xFFFB8C00)),
                  ];

                  final left = <Widget>[
                    const _SectionTitle("Today's schedule"),
                    _TodaySchedule(db: db),
                    const SizedBox(height: 24),
                    _SectionTitle('Upcoming deadlines (${upcoming.length})'),
                    if (upcoming.isEmpty)
                      _muted(context, 'No upcoming deadlines.')
                    else
                      for (final d in upcoming)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(d.isTask
                              ? Icons.checklist
                              : Icons.biotech_outlined),
                          title: Text(d.title),
                          subtitle: Text('${d.kind} · ${formatDate(d.date)}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => d.isTask
                                  ? TaskEditScreen(task: d.task)
                                  : ExperimentDetailScreen(experimentId: d.id),
                            ),
                          ),
                        ),
                  ];

                  final right = <Widget>[
                    const _SectionTitle('Projects by status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in ProjectStatus.values)
                          _CountCard(
                            label: enumLabel(s),
                            count:
                                projects.where((p) => p.status == s).length,
                            color: projectStatusColor(s, scheme),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Experiments by status'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in ExperimentStatus.values)
                          _CountCard(
                            label: enumLabel(s),
                            count: experiments
                                .where((e) => e.status == s)
                                .length,
                            color: experimentStatusColor(s, scheme),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle('Reagents expiring within 30 days '
                        '(${expiring.length})'),
                    if (expiring.isEmpty)
                      _muted(context, 'None.')
                    else
                      for (final r in expiring)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.warning_amber_rounded),
                          title: Text(r.name),
                          trailing: LabelChip(
                            'Expires ${formatDate(r.expiryDate)}',
                            color: expiryState(r.expiryDate, now) ==
                                    ExpiryState.expired
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ),
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 880;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // On mobile/web (no title bar) the global search lives
                          // here, above the date and time.
                          if (!isDesktopWindow) _searchBar(context),
                          LiveClock(
                            builder: (context, now) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Icon(Icons.today_outlined,
                                      color: scheme.primary, size: 30),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(clockDate(now),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      Text(clockTime(now),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures()
                                                  ])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Wrap(spacing: 12, runSpacing: 12, children: kpis),
                          const SizedBox(height: 28),
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: left),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: right),
                                ),
                              ],
                            )
                          else ...[
                            ...left,
                            const SizedBox(height: 24),
                            ...right,
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _muted(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(text,
            style:
                TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );

  /// A tappable search bar that opens the global-search palette. Shown on the
  /// Dashboard where there's no title-bar search (mobile/web).
  Widget _searchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openGlobalSearchOn(context),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: scheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text('Search your lab…',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// A compact KPI card: a number, a label, and an accent icon.
class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$value',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything scheduled for today (lab dates + personal events + holidays),
/// loaded once when the dashboard opens.
class _TodaySchedule extends StatefulWidget {
  const _TodaySchedule({required this.db});

  final AppDatabase db;

  @override
  State<_TodaySchedule> createState() => _TodayScheduleState();
}

class _TodayScheduleState extends State<_TodaySchedule> {
  late final Future<List<ScheduleEvent>> _future =
      loadScheduleForDay(widget.db, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<ScheduleEvent>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        final events = snap.data!;
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('Nothing scheduled for today.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          );
        }
        return Column(
          children: [
            for (final e in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.circle,
                    size: 14, color: kScheduleColors[e.kind]),
                title: Text(e.title),
                subtitle: Text(e.kind.label),
              ),
          ],
        );
      },
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard(
      {required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
