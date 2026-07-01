import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/task_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../experiments/experiment_detail_screen.dart';
import '../labels.dart';
import '../tasks/task_edit_screen.dart';
import '../widgets.dart';
import 'deadline_item.dart';

/// Every dated task and experiment, sorted by date, with overdue items flagged.
class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final tasks = TaskRepository(db);
    final experiments = ExperimentRepository(db);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deadlines'),
        actions: const [AccountButton()],
      ),
      body: StreamBuilder<List<Task>>(
        stream: tasks.watchAll(),
        builder: (context, ts) {
          return StreamBuilder<List<Experiment>>(
            stream: experiments.watchAll(),
            builder: (context, es) {
              if (!ts.hasData || !es.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = buildDeadlines(ts.data!, es.data!);
              if (items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'No dated tasks or experiments yet.\nAdd a due date or experiment date to see it here.',
                        textAlign: TextAlign.center),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) =>
                    _DeadlineTile(item: items[i], now: now),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({required this.item, required this.now});

  final DeadlineItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = daysUntil(item.date, now)!;
    final overdue = days < 0 && !item.done;
    final dueToday = days == 0 && !item.done;

    Widget? flag;
    if (overdue) {
      flag = LabelChip('Overdue', color: Colors.red);
    } else if (dueToday) {
      flag = LabelChip('Due today', color: Colors.orange);
    }

    return ListTile(
      leading: Icon(item.isTask ? Icons.checklist : Icons.biotech_outlined),
      title: Text(item.title,
          style: TextStyle(
            decoration: item.done ? TextDecoration.lineThrough : null,
          )),
      subtitle: Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        OutlineChip('${item.kind} · ${item.statusLabel}'),
        Text(formatDate(item.date),
            style: TextStyle(
                color: overdue ? Colors.red : scheme.onSurfaceVariant)),
        ?flag,
      ]),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => item.isTask
            ? TaskEditScreen(task: item.task)
            : ExperimentDetailScreen(experimentId: item.id),
      )),
    );
  }
}
