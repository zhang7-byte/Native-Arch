import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/project_repository.dart';
import '../../data/strain_repository.dart';
import '../../data/task_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../glass.dart';
import '../images/images_section.dart';
import '../labels.dart';
import '../strains/strain_detail_screen.dart';
import '../tasks/task_edit_screen.dart';
import '../widgets.dart';
import 'experiment_edit_screen.dart';
import 'experiment_updates_section.dart';

/// An experiment with its details and linked tasks.
class ExperimentDetailScreen extends StatelessWidget {
  const ExperimentDetailScreen({super.key, required this.experimentId});

  final String experimentId;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final experiments = ExperimentRepository(db);
    final projects = ProjectRepository(db);
    final strains = StrainRepository(db);
    final tasks = TaskRepository(db);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Experiment?>(
      stream: experiments.watchById(experimentId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final exp = snap.data;
        if (exp == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This experiment no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Experiment'),
            actions: [
              IconButton(
                tooltip: 'Export to PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(
                          title: 'Experiment PDF',
                          fileName: 'experiment.pdf',
                          builder: (fonts) =>
                              buildExperimentPdf(db, exp, fonts),
                        ))),
              ),
              IconButton(
                tooltip: 'Edit experiment',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ExperimentEditScreen(experiment: exp))),
              ),
              IconButton(
                tooltip: 'Delete experiment',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final ok = await showGlassDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete experiment?'),
                      content: Text(
                          '"${exp.title}" and its tasks, images and progress '
                          'log will be moved to the Trash. You can restore them '
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
                    await experiments.delete(exp.id);
                    navigator.pop();
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(exp.title, style: textTheme.headlineSmall),
              const SizedBox(height: 6),
              FutureBuilder<Project?>(
                future: projects.findById(exp.projectId),
                builder: (context, s) => Text('in ${s.data?.title ?? '…'}',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4, children: [
                LabelChip(enumLabel(exp.status),
                    color: experimentStatusColor(exp.status, scheme)),
                if (exp.date != null) OutlineChip(formatDate(exp.date)),
                if (exp.protocolRef.isNotEmpty) OutlineChip(exp.protocolRef),
              ]),
              if (exp.hypothesis.isNotEmpty)
                _Field('Hypothesis', exp.hypothesis),
              if (exp.methodologySteps.isNotEmpty)
                _StepsField('Methodology', exp.methodologySteps),
              if (exp.resultsNotes.isNotEmpty)
                _Field('Results notes', exp.resultsNotes),
              if (exp.conclusion.isNotEmpty)
                _Field('Conclusion', exp.conclusion),
              if (exp.furtherPlan.isNotEmpty)
                _Field('Further plan', exp.furtherPlan),
              _StrainIds(strainIds: exp.strainIds, strains: strains),
              if (exp.dataLinks.isNotEmpty)
                _Field('Data links', exp.dataLinks.join('\n')),
              const Divider(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasks', style: textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => TaskEditScreen(
                                defaultExperimentId: exp.id,
                                defaultProjectId: exp.projectId))),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              StreamBuilder<List<Task>>(
                stream: tasks.watchForExperiment(exp.id),
                builder: (context, s) {
                  final items = s.data ?? const <Task>[];
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No tasks yet.',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    );
                  }
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
              const Divider(height: 36),
              ImagesSection(
                  experimentId: exp.id, title: 'Result images'),
              const Divider(height: 36),
              ExperimentUpdatesSection(experimentId: exp.id),
            ],
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}

/// A labelled, numbered list (used for the step-by-step methodology).
class _StepsField extends StatelessWidget {
  const _StepsField(this.label, this.steps);

  final String label;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 4),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 24,
                      child: Text('${i + 1}.',
                          style: TextStyle(color: scheme.onSurfaceVariant))),
                  Expanded(child: Text(steps[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The experiment's strains, resolved from ids to names and linked to their
/// detail. An id with no matching strain (e.g. a stale reference) falls back to
/// showing the raw id rather than failing.
class _StrainIds extends StatelessWidget {
  const _StrainIds({required this.strainIds, required this.strains});

  final List<String> strainIds;
  final StrainRepository strains;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Strains',
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 4),
          if (strainIds.isEmpty)
            Text('None', style: TextStyle(color: scheme.onSurfaceVariant))
          else
            FutureBuilder<List<Strain>>(
              future: strains.all(),
              builder: (context, snap) {
                final nameById = {
                  for (final s in snap.data ?? const <Strain>[]) s.id: s.name,
                };
                return Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final id in strainIds)
                      _StrainChip(id: id, name: nameById[id]),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StrainChip extends StatelessWidget {
  const _StrainChip({required this.id, this.name});

  final String id;
  final String? name;

  @override
  Widget build(BuildContext context) {
    if (name == null) return OutlineChip(id); // unresolved reference
    return ActionChip(
      avatar: const Icon(Icons.coronavirus_outlined, size: 16),
      label: Text(name!),
      visualDensity: VisualDensity.compact,
      onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StrainDetailScreen(strainId: id))),
    );
  }
}
