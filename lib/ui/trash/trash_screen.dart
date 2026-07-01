import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/trash_repository.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';

/// The Trash: items deleted recently, with restore / permanent-delete. Entries
/// auto-expire after the retention window (see main.dart).
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  IconData _icon(String kind) => switch (kind) {
        'Project' => Icons.science_outlined,
        'Experiment' => Icons.biotech_outlined,
        'Task' => Icons.checklist_outlined,
        'Strain' => Icons.coronavirus_outlined,
        'Reagent' => Icons.inventory_2_outlined,
        'Culture' => Icons.bubble_chart_outlined,
        'Primer' => Icons.biotech_outlined,
        'Manuscript' => Icons.article_outlined,
        'Report' => Icons.assessment_outlined,
        'Construction' => Icons.donut_large_outlined,
        'Update' => Icons.history,
        'Image' => Icons.image_outlined,
        _ => Icons.delete_outline,
      };

  Future<void> _emptyAll(BuildContext context, TrashRepository repo) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty trash?'),
        content: const Text(
            'Everything in the trash will be permanently deleted. This cannot '
            'be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Empty trash')),
        ],
      ),
    );
    if (ok == true) {
      await repo.emptyAll();
      messenger.showSnackBar(const SnackBar(content: Text('Trash emptied.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = TrashRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently deleted'),
        actions: [
          IconButton(
            tooltip: 'Empty trash',
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () => _emptyAll(context, repo),
          ),
        ],
      ),
      body: StreamBuilder<List<TrashEntry>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? const <TrashEntry>[];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Trash is empty.\n\nDeleted items are kept here for 30 days '
                  'so you can restore them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final messenger = ScaffoldMessenger.of(context);
              return ListTile(
                leading: Icon(_icon(e.kind)),
                title: Text(
                    e.label.isEmpty ? '(${e.kind.toLowerCase()})' : e.label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${e.kind} · deleted ${formatDate(e.deletedAt)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Restore'),
                      onPressed: () async {
                        await repo.restore(e.id);
                        messenger.showSnackBar(SnackBar(
                            content: Text('Restored '
                                '${e.label.isEmpty ? e.kind.toLowerCase() : e.label}.')));
                      },
                    ),
                    IconButton(
                      tooltip: 'Delete permanently',
                      icon: const Icon(Icons.delete_forever_outlined),
                      onPressed: () async {
                        final ok = await showGlassDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete permanently?'),
                            content: Text(
                                '"${e.label.isEmpty ? e.kind : e.label}" will be '
                                'gone for good.'),
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
                        if (ok == true) await repo.purge(e.id);
                      },
                    ),
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
