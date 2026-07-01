import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/manuscript_repository.dart';
import '../../data/project_repository.dart';
import '../../data/task_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../experiments/experiment_detail_screen.dart';
import '../experiments/experiment_edit_screen.dart';
import '../export/pdf_preview_screen.dart';
import '../labels.dart';
import '../manuscripts/manuscript_detail_screen.dart';
import '../tasks/task_edit_screen.dart';
import '../widgets.dart';
import 'project_edit_screen.dart';

/// A project with its experiments and tasks.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final projects = ProjectRepository(db);
    final experiments = ExperimentRepository(db);
    final tasks = TaskRepository(db);
    final manuscripts = ManuscriptRepository(db);
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<Project?>(
      stream: projects.watchById(projectId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final project = snap.data;
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This project no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Project'),
            actions: [
              IconButton(
                tooltip: 'Export to PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(
                          title: 'Project PDF',
                          fileName: 'project.pdf',
                          builder: (fonts) =>
                              buildProjectPdf(db, project, fonts),
                        ))),
              ),
              IconButton(
                tooltip: 'Edit project',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProjectEditScreen(project: project))),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(project.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4, children: [
                LabelChip(enumLabel(project.status),
                    color: projectStatusColor(project.status, scheme)),
                LabelChip('${enumLabel(project.priority)} priority',
                    color: priorityColor(project.priority, scheme)),
                for (final t in project.tags) OutlineChip('#$t'),
              ]),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(project.description),
              ],
              if (project.startDate != null || project.targetDate != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Start: ${formatDate(project.startDate)}      '
                  'Target: ${formatDate(project.targetDate)}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
              const Divider(height: 36),
              _SectionHeader(
                title: 'Experiments',
                onAdd: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ExperimentEditScreen(defaultProjectId: project.id))),
              ),
              StreamBuilder<List<Experiment>>(
                stream: experiments.watchForProject(project.id),
                builder: (context, s) {
                  final items = s.data ?? const <Experiment>[];
                  if (items.isEmpty) return const _EmptyHint('No experiments yet.');
                  return Column(
                    children: [
                      for (final e in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.biotech_outlined),
                          title: Text(e.title),
                          subtitle: Wrap(spacing: 6, runSpacing: 4, children: [
                            LabelChip(enumLabel(e.status),
                                color:
                                    experimentStatusColor(e.status, scheme)),
                            if (e.strainIds.isNotEmpty)
                              OutlineChip('${e.strainIds.length} strain(s)'),
                          ]),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ExperimentDetailScreen(
                                      experimentId: e.id))),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Tasks',
                onAdd: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        TaskEditScreen(defaultProjectId: project.id))),
              ),
              StreamBuilder<List<Task>>(
                stream: tasks.watchForProject(project.id),
                builder: (context, s) {
                  final items = s.data ?? const <Task>[];
                  if (items.isEmpty) return const _EmptyHint('No tasks yet.');
                  return Column(
                    children: [
                      for (final t in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(t.status == TaskStatus.done
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked),
                          title: Text(t.title),
                          subtitle: Wrap(spacing: 6, runSpacing: 4, children: [
                            LabelChip(enumLabel(t.status),
                                color: taskStatusColor(t.status, scheme)),
                            LabelChip('${enumLabel(t.priority)} priority',
                                color: priorityColor(t.priority, scheme)),
                          ]),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => TaskEditScreen(task: t))),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Manuscripts',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              StreamBuilder<List<Manuscript>>(
                stream: manuscripts.watchForProject(project.id),
                builder: (context, s) {
                  final items = s.data ?? const <Manuscript>[];
                  if (items.isEmpty) return const _EmptyHint('No manuscripts.');
                  return Column(
                    children: [
                      for (final m in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.article_outlined),
                          title: Text(m.title),
                          subtitle: Align(
                            alignment: Alignment.centerLeft,
                            child: LabelChip(enumLabel(m.status),
                                color:
                                    manuscriptStatusColor(m.status, scheme)),
                          ),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ManuscriptDetailScreen(
                                      manuscriptId: m.id))),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add')),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
