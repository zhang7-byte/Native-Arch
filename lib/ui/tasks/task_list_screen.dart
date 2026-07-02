import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/project_repository.dart';
import '../../data/task_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../master_detail.dart';
import '../widgets.dart';
import 'task_edit_screen.dart';

/// All tasks, each labelled with what it is attached to.
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final projects = ProjectRepository(db);
    final experiments = ExperimentRepository(db);
    final tasks = TaskRepository(db);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: const [AccountButton()],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-tasks',
        onPressed: () => openDetail(
            context, (_) => const TaskEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: StreamBuilder<List<Project>>(
        stream: projects.watchAll(),
        builder: (context, ps) {
          final projTitle = {for (final p in ps.data ?? const []) p.id: p.title};
          return StreamBuilder<List<Experiment>>(
            stream: experiments.watchAll(),
            builder: (context, es) {
              final expTitle = {
                for (final e in es.data ?? const []) e.id: e.title
              };
              return StreamBuilder<List<Task>>(
                stream: tasks.watchAll(),
                builder: (context, ts) {
                  if (ts.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Failed to load tasks:\n${ts.error}',
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  if (!ts.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = ts.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet.\nTap "New task" to add one.',
                          textAlign: TextAlign.center),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final t = items[i];
                      final String link;
                      if (t.experimentId != null) {
                        link = 'Experiment: ${expTitle[t.experimentId] ?? '—'}';
                      } else if (t.projectId != null) {
                        link = 'Project: ${projTitle[t.projectId] ?? '—'}';
                      } else {
                        link = 'Unlinked';
                      }
                      return ListTile(
                        isThreeLine: true,
                        leading: Icon(t.status == TaskStatus.done
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked),
                        onTap: () => openDetail(
                            context, (_) => TaskEditScreen(task: t)),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(t.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(link,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 4, children: [
                              LabelChip(enumLabel(t.status),
                                  color: taskStatusColor(t.status, scheme)),
                              LabelChip('${enumLabel(t.priority)} priority',
                                  color: priorityColor(t.priority, scheme)),
                              if (t.dueDate != null)
                                OutlineChip('due ${formatDate(t.dueDate)}'),
                            ]),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
