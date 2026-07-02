import 'package:flutter/material.dart';

import '../../data/clone_repository.dart';
import '../../data/database.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../glass.dart';
import '../master_detail.dart';
import 'clone_edit_screen.dart';

/// Saved Gibson clone constructions. Design fragments + backbone, see the
/// assembled-vector map, and export a build sheet as PDF.
class CloneListScreen extends StatelessWidget {
  const CloneListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CloneRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloning'),
        actions: const [AccountButton()],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-cloning',
        onPressed: () => openDetail(
            context, (_) => const CloneEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New construction'),
      ),
      body: StreamBuilder<List<CloneConstruction>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No constructions yet.\n\nTap "New construction" to design a '
                  'Gibson assembly: pick a backbone strain + enzymes, add '
                  'fragments (template strain + primers), preview the vector, '
                  'and export a PDF build sheet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) =>
                _CloneTile(construction: items[i], repo: repo),
          );
        },
      ),
    );
  }
}

class _CloneTile extends StatelessWidget {
  const _CloneTile({required this.construction, required this.repo});

  final CloneConstruction construction;
  final CloneRepository repo;

  void _export(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Construction PDF',
        fileName: 'labtrack-construction.pdf',
        builder: (fonts) => buildClonePdf(db, construction, fonts),
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete construction?'),
        content: Text(
            '"${construction.name.isEmpty ? 'Untitled' : construction.name}"'
            ' will be moved to the Trash. You can restore it from '
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
    if (ok == true) await repo.delete(construction.id);
  }

  @override
  Widget build(BuildContext context) {
    final n = construction.fragments.length;
    final subtitle = [
      if (construction.backboneName.isNotEmpty)
        'Backbone: ${construction.backboneName}',
      '$n fragment${n == 1 ? '' : 's'}',
    ].join('  ·  ');
    return ListTile(
      leading: const Icon(Icons.donut_large_outlined),
      title: Text(
          construction.name.isEmpty ? 'Untitled construction' : construction.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () => openDetail(
          context, (_) => CloneEditScreen(construction: construction)),
      trailing: GlassMoreButton(
        tooltip: 'Construction actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => openDetail(context,
                  (_) => CloneEditScreen(construction: construction))),
          GlassAction(Icons.picture_as_pdf_outlined, 'Export PDF',
              () => _export(context), mutates: false),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
