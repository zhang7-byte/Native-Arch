import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/workspace_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../backup/backup_screen.dart';
import '../glass.dart';

/// Shows the current workspace, lets you rename it, and switch between or create
/// local workspaces (separate data sets on this device).
class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  Future<String?> _nameDialog(
      BuildContext context, String title, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showGlassDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Workspace name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save')),
        ],
      ),
    ).then((v) => v == null || v.trim().isEmpty ? null : v.trim());
  }

  Future<void> _confirmDelete(
      BuildContext context, WorkspaceRepository repo, Workspace w) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workspace?'),
        content: Text(
            '"${w.name}" and ALL of its projects, experiments, tasks, strains, '
            'reagents, primers, cultures, reports and images will be permanently '
            'deleted on this device (and from the cloud once synced). This cannot '
            'be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await repo.delete(w.id);
      messenger
          .showSnackBar(SnackBar(content: Text('Deleted "${w.name}".')));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not delete workspace: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = WorkspaceRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        actions: const [AccountButton()],
      ),
      body: StreamBuilder<String?>(
        stream: repo.watchCurrentId(),
        builder: (context, curSnap) {
          final currentId = curSnap.data;
          return StreamBuilder<List<Workspace>>(
            stream: repo.watchAll(),
            builder: (context, wsSnap) {
              final workspaces = wsSnap.data ?? const <Workspace>[];
              Workspace? current;
              for (final w in workspaces) {
                if (w.id == currentId) current = w;
              }
              final cur = current;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (cur != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CURRENT WORKSPACE',
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            Text(cur.name, style: textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final name = await _nameDialog(
                                      context, 'Rename workspace', cur.name);
                                  if (name != null) {
                                    await repo.rename(cur.id, name);
                                  }
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Rename'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const BackupScreen())),
                    icon: const Icon(Icons.backup_outlined),
                    label: const Text('Backup & restore'),
                  ),
                  const SizedBox(height: 20),
                  Text('Switch workspace', style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  for (final w in workspaces)
                    ListTile(
                      leading: Icon(
                          w.id == currentId
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: w.id == currentId
                              ? scheme.primary
                              : scheme.onSurfaceVariant),
                      title: Text(w.name),
                      onTap: () => repo.setCurrent(w.id),
                      // The last workspace can't be deleted — the app always
                      // needs one selected.
                      trailing: workspaces.length > 1
                          ? GlassMoreButton(
                              tooltip: 'Workspace actions',
                              actions: [
                                GlassAction(
                                    Icons.delete_outline,
                                    'Delete workspace',
                                    () => _confirmDelete(context, repo, w),
                                    destructive: true),
                              ],
                            )
                          : null,
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final name =
                          await _nameDialog(context, 'New workspace', '');
                      if (name != null) {
                        final id = await repo.create(name);
                        await repo.setCurrent(id);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New workspace'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Each workspace is a separate set of projects, experiments, '
                    'tasks, strains, reagents, cultures, primers, protocols and '
                    'reports on this device. Switch between them to keep different '
                    'work apart.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
