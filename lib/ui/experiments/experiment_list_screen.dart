import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../master_detail.dart';
import '../widgets.dart';
import 'experiment_detail_screen.dart';
import 'experiment_edit_screen.dart';

/// All experiments across projects, each labelled with its parent project.
class ExperimentListScreen extends StatelessWidget {
  const ExperimentListScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context, ExperimentRepository repo, Experiment exp) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete experiment?'),
        content: Text(
            '"${exp.title}" and its tasks, images and progress log will be '
            'moved to the Trash. You can restore them from '
            'Settings → Recently deleted.'),
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
    if (ok == true) await repo.delete(exp.id);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExperimentRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiments'),
        actions: const [AccountButton()],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-experiments',
        onPressed: () => openDetail(
            context, (_) => const ExperimentEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New experiment'),
      ),
      body: StreamBuilder<List<(Experiment, String)>>(
        stream: repo.watchAllWithProject(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load experiments:\n${snapshot.error}',
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(
              child: Text(
                  'No experiments yet.\nTap "New experiment" to add one.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final (exp, projectTitle) = rows[i];
              return ListTile(
                isThreeLine: true,
                onTap: () => openDetail(context, (_) =>
                    ExperimentDetailScreen(experimentId: exp.id)),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(exp.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('in $projectTitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      LabelChip(enumLabel(exp.status),
                          color: experimentStatusColor(exp.status, scheme)),
                      if (exp.strainIds.isNotEmpty)
                        OutlineChip('${exp.strainIds.length} strain(s)'),
                    ]),
                  ],
                ),
                trailing: GlassMoreButton(
                  tooltip: 'Experiment actions',
                  actions: [
                    GlassAction(
                        Icons.edit_outlined,
                        'Edit',
                        () => openDetail(context, (_) =>
                            ExperimentEditScreen(experiment: exp))),
                    GlassAction(Icons.delete_outline, 'Delete',
                        () => _confirmDelete(context, repo, exp),
                        destructive: true),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
