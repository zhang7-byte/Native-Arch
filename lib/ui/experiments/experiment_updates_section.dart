import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_update_repository.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../images/images_section.dart';
import '../labels.dart';

/// The timestamped progress log on an experiment: add/edit/delete updates, each
/// with its own note and result images.
class ExperimentUpdatesSection extends StatelessWidget {
  const ExperimentUpdatesSection({super.key, required this.experimentId});

  final String experimentId;

  Future<void> _addOrEdit(
    BuildContext context,
    ExperimentUpdateRepository repo, {
    ExperimentUpdate? existing,
  }) async {
    final note = TextEditingController(text: existing?.note ?? '');
    var date = existing?.happenedAt.toLocal() ?? DateTime.now();
    final saved = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'New update' : 'Edit update'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Date: ${formatDate(date)}')),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setLocal(() => date = picked);
                      },
                      icon: const Icon(Icons.event),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
                TextField(
                  controller: note,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'What happened',
                      alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved == true) {
      if (existing == null) {
        await repo.add(
            experimentId: experimentId,
            happenedAt: date,
            note: note.text.trim());
      } else {
        await repo.edit(existing.id,
            happenedAt: date, note: note.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExperimentUpdateRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progress log',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _addOrEdit(context, repo),
              icon: const Icon(Icons.add),
              label: const Text('Add update'),
            ),
          ],
        ),
        StreamBuilder<List<ExperimentUpdate>>(
          stream: repo.watchForExperiment(experimentId),
          builder: (context, snap) {
            final updates = snap.data ?? const <ExperimentUpdate>[];
            if (updates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No updates yet.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              );
            }
            return Column(
              children: [
                for (final u in updates)
                  _UpdateCard(
                    update: u,
                    onEdit: () => _addOrEdit(context, repo, existing: u),
                    onDelete: () => repo.delete(u.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard(
      {required this.update, required this.onEdit, required this.onDelete});

  final ExperimentUpdate update;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete update?'),
        content: const Text(
            'This log entry and its images will be moved to the Trash. You can '
            'restore them from Settings → Recently deleted.'),
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
    if (ok == true) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(formatDate(update.happenedAt),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                GlassMoreButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Update actions',
                  actions: [
                    GlassAction(Icons.edit_outlined, 'Edit', onEdit),
                    GlassAction(Icons.delete_outline, 'Delete',
                        () => _confirmDelete(context),
                        destructive: true),
                  ],
                ),
              ],
            ),
            if (update.note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 4),
                child: Text(update.note),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 6, top: 4),
              child: ImagesSection(
                  updateId: update.id, title: 'Images', dense: true),
            ),
          ],
        ),
      ),
    );
  }
}
