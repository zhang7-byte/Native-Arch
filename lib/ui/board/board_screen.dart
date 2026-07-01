import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/project_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../labels.dart';
import '../projects/project_detail_screen.dart';
import '../widgets.dart';

/// A kanban board of projects grouped by status. Long-press a card and drag it
/// to another column to change the project's status.
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
        actions: const [
          _LiveClock(),
          SizedBox(width: 4),
          AccountButton(),
        ],
      ),
      body: StreamBuilder<List<Project>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            children: [
              for (final status in ProjectStatus.values)
                _BoardColumn(
                  status: status,
                  projects:
                      projects.where((p) => p.status == status).toList(),
                  repo: repo,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Today's date and the current time, ticking every second (compact, for the bar).
class _LiveClock extends StatelessWidget {
  const _LiveClock();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LiveClock(
      builder: (context, now) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('${clockDate(now)}   ${clockTime(now)}',
                  style: TextStyle(
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn(
      {required this.status, required this.projects, required this.repo});

  final ProjectStatus status;
  final List<Project> projects;
  final ProjectRepository repo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = projectStatusColor(status, scheme);
    return DragTarget<Project>(
      onWillAcceptWithDetails: (d) => d.data.status != status,
      onAcceptWithDetails: (d) => repo.update(
          d.data.id, ProjectsCompanion(status: Value(status))),
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return Container(
          width: 270,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: highlight
                ? color.withValues(alpha: 0.10)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: highlight ? Border.all(color: color, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(enumLabel(status),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600))),
                    Text('${projects.length}',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    if (projects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('—',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ),
                    for (final p in projects) _BoardCard(project: p),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              LabelChip('${enumLabel(project.priority)} priority',
                  color: priorityColor(project.priority, scheme)),
            ],
          ),
        ),
      ),
    );
    return LongPressDraggable<Project>(
      data: project,
      feedback: Material(
          color: Colors.transparent,
          child: SizedBox(width: 250, child: card)),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }
}
