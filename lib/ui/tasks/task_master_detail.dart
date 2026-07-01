import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/project_repository.dart';
import '../../data/task_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'task_edit_screen.dart';

/// Desktop three-pane experience for Tasks: a persistent list on the left and an
/// inline editor on the right. Selecting an item edits it in place and "New task"
/// opens a blank editor — no full-screen navigation. Both panes share a single
/// [TaskRepository.watchAll] stream (with lookups for the linked project /
/// experiment titles, mirroring the list screen).
class TaskMasterDetail extends StatefulWidget {
  const TaskMasterDetail({super.key});

  @override
  State<TaskMasterDetail> createState() => _TaskMasterDetailState();
}

class _TaskMasterDetailState extends State<TaskMasterDetail> {
  String? _selectedId;
  bool _creating = false;
  bool _selectNewestOnNextData = false;

  void _select(String id) => setState(() {
        _selectedId = id;
        _creating = false;
      });

  void _startNew() => setState(() {
        _creating = true;
        _selectedId = null;
      });

  Future<void> _confirmDelete(
      BuildContext context, TaskRepository repo, Task task) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
            '"${task.title}" will be moved to the Trash. You can restore it '
            'from Settings → Recently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await repo.delete(task.id);
      if (mounted && _selectedId == task.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final projects = ProjectRepository(db);
    final experiments = ExperimentRepository(db);
    final repo = TaskRepository(db);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<List<Project>>(
        stream: projects.watchAll(),
        builder: (context, ps) {
          final projTitle = {
            for (final p in ps.data ?? const <Project>[]) p.id: p.title
          };
          return StreamBuilder<List<Experiment>>(
            stream: experiments.watchAll(),
            builder: (context, es) {
              final expTitle = {
                for (final e in es.data ?? const <Experiment>[]) e.id: e.title
              };
              return StreamBuilder<List<Task>>(
                stream: repo.watchAll(),
                builder: (context, snapshot) {
                  final rows = snapshot.data ?? const <Task>[];

                  // Just created a new task: select the newest row (ordered by
                  // updated_at DESC, so the one we just wrote is first) once it
                  // arrives.
                  if (_selectNewestOnNextData && rows.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || !_selectNewestOnNextData) return;
                      setState(() {
                        _selectedId = rows.first.id;
                        _selectNewestOnNextData = false;
                      });
                    });
                  }

                  // Resolve the selected task from the shared stream.
                  Task? selected;
                  for (final t in rows) {
                    if (t.id == _selectedId) {
                      selected = t;
                      break;
                    }
                  }
                  // Selection deleted elsewhere — drop it after this frame.
                  if (_selectedId != null &&
                      selected == null &&
                      snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedId != null) {
                        setState(() => _selectedId = null);
                      }
                    });
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 340,
                        child: _listPane(context, repo, scheme, snapshot, rows,
                            projTitle, expTitle),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      Expanded(child: _detailPane(scheme, selected)),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _listPane(
    BuildContext context,
    TaskRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Task>> snapshot,
    List<Task> rows,
    Map<String, String> projTitle,
    Map<String, String> expTitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: title, New, account.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Tasks',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New task',
                onPressed: _startNew,
                icon: const Icon(Icons.add),
              ),
              const AccountButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
            child: _list(context, repo, scheme, snapshot, rows, projTitle,
                expTitle)),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    TaskRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Task>> snapshot,
    List<Task> rows,
    Map<String, String> projTitle,
    Map<String, String> expTitle,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load tasks:\n${snapshot.error}',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No tasks yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = rows[i];
        final isSelected = t.id == _selectedId;
        final String link;
        if (t.experimentId != null) {
          link = 'Experiment: ${expTitle[t.experimentId] ?? '—'}';
        } else if (t.projectId != null) {
          link = 'Project: ${projTitle[t.projectId] ?? '—'}';
        } else {
          link = 'Unlinked';
        }
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          isThreeLine: true,
          leading: Icon(t.status == TaskStatus.done
              ? Icons.check_circle_outline
              : Icons.radio_button_unchecked),
          onTap: () => _select(t.id),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(t.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
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
          trailing: GlassMoreButton(
            tooltip: 'Task actions',
            actions: [
              GlassAction(Icons.edit_outlined, 'Edit', () => _select(t.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, t),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Task? selected) {
    if (_creating) {
      return TaskEditScreen(
        // Fresh state for each new-task session.
        key: const ValueKey('task-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return TaskEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('task-${selected.id}'),
        embedded: true,
        task: selected,
        onSaved: () {},
      );
    }
    return _emptyDetail(scheme);
  }

  Widget _emptyDetail(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a task to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
