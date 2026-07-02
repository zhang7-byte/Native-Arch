import 'package:flutter/material.dart';

import '../../data/csv_import.dart';
import '../../data/database.dart';
import '../../data/primer_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/export_csv.dart';
import '../glass.dart';
import '../import/import_screen.dart';
import '../master_detail.dart';
import '../widgets.dart';
import 'primer_edit_screen.dart';

/// Searchable list of primers, with CSV import and sequence-length display.
class PrimerListScreen extends StatefulWidget {
  const PrimerListScreen({super.key});

  @override
  State<PrimerListScreen> createState() => _PrimerListScreenState();
}

class _PrimerListScreenState extends State<PrimerListScreen> {
  String _query = '';

  bool _matches(Primer p, String q) {
    if (q.isEmpty) return true;
    final hay = [
      p.name,
      p.serialNumber,
      p.sequence,
      p.targetGene,
      p.direction,
      p.supplier,
      p.notes
    ].join(' ').toLowerCase();
    return hay.contains(q.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final repo = PrimerRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Primers'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => exportEntityCsv(context,
                AppDatabaseProvider.of(context), ImportEntity.primer,
                'primers'),
          ),
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ImportScreen(entity: ImportEntity.primer))),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-primers',
        onPressed: () => openDetail(
            context, (_) => const PrimerEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New primer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search primers',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Primer>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final primers =
                    snapshot.data!.where((p) => _matches(p, _query)).toList();
                if (primers.isEmpty) {
                  return Center(
                    child: Text(_query.isEmpty
                        ? 'No primers yet.\nTap "New primer" or import a CSV.'
                        : 'No primers match "$_query".'),
                  );
                }
                return ListView.separated(
                  itemCount: primers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _PrimerTile(primer: primers[i], repo: repo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimerTile extends StatelessWidget {
  const _PrimerTile({required this.primer, required this.repo});

  final Primer primer;
  final PrimerRepository repo;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete primer?'),
        content: Text('Primer "${primer.name}" will be moved to the Trash. You '
            'can restore it from Settings → Recently deleted.'),
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
    if (ok == true) await repo.delete(primer.id);
  }

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (primer.serialNumber.isNotEmpty) '#${primer.serialNumber}',
      if (primer.targetGene.isNotEmpty) primer.targetGene,
      if (primer.direction.isNotEmpty) primer.direction,
      if (primer.tm.isNotEmpty) 'Tm ${primer.tm}',
    ].join(' · ');
    final len = sequenceLength(primer.sequence);
    return ListTile(
      isThreeLine: meta.isNotEmpty && len > 0,
      title: Text(primer.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.isNotEmpty) Text(meta),
          if (len > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                  alignment: Alignment.centerLeft, child: OutlineChip('$len nt')),
            ),
        ],
      ),
      onTap: () => openDetail(
          context, (_) => PrimerEditScreen(primer: primer)),
      trailing: GlassMoreButton(
        tooltip: 'Primer actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => openDetail(context,
                  (_) => PrimerEditScreen(primer: primer))),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
