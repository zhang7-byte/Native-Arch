import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/csv_import.dart';
import '../../data/strain_repository.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../cultures/start_cultures_screen.dart';
import '../export/export_csv.dart';
import '../export/select_export_screen.dart';
import '../glass.dart';
import '../import/import_screen.dart';
import '../search_picker.dart';
import 'strain_detail_screen.dart';
import 'strain_edit_screen.dart';

/// How the strain list is ordered.
enum StrainSort {
  name('Name A–Z'),
  serial('Serial number'),
  host('Host organism'),
  created('Date created'),
  modified('Last modified');

  const StrainSort(this.label);
  final String label;
}

/// Searchable list of strains.
class StrainListScreen extends StatefulWidget {
  const StrainListScreen({super.key});

  @override
  State<StrainListScreen> createState() => _StrainListScreenState();
}

class _StrainListScreenState extends State<StrainListScreen> {
  String _query = '';
  StrainSort _sort = StrainSort.name;

  int _compare(Strain a, Strain b) {
    switch (_sort) {
      case StrainSort.name:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case StrainSort.serial:
        // Empty serials sort last; otherwise lexicographic.
        final ae = a.serialNumber.trim(), be = b.serialNumber.trim();
        if (ae.isEmpty != be.isEmpty) return ae.isEmpty ? 1 : -1;
        return ae.toLowerCase().compareTo(be.toLowerCase());
      case StrainSort.host:
        final c = a.hostOrganism
            .toLowerCase()
            .compareTo(b.hostOrganism.toLowerCase());
        return c != 0 ? c : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case StrainSort.created:
        return b.createdAt.compareTo(a.createdAt); // newest first
      case StrainSort.modified:
        return b.updatedAt.compareTo(a.updatedAt); // newest first
    }
  }

  bool _matches(Strain s, String q) {
    if (q.isEmpty) return true;
    final hay = [
      s.name,
      s.serialNumber,
      s.hostOrganism,
      s.genotype,
      s.plasmid,
      s.constructNotes,
      s.notes,
    ].join(' ').toLowerCase();
    return hay.contains(q.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final repo = StrainRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strains'),
        actions: [
          PopupMenuButton<StrainSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (ctx) => [
              for (final s in StrainSort.values)
                PopupMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      SizedBox(
                          width: 24,
                          child: s == _sort
                              ? const Icon(Icons.check, size: 18)
                              : null),
                      const SizedBox(width: 8),
                      Text(s.label),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: 'Start cultures from strains',
            icon: const Icon(Icons.biotech_outlined),
            onPressed: () async {
              final strains = await repo.watchAll().first;
              if (!context.mounted) return;
              final ids = await showMultiSearchPicker<Strain>(
                context,
                title: 'Select strains to culture',
                items: strains,
                idOf: (s) => s.id,
                labelOf: (s) => s.name,
                subtitleOf: (s) => [
                  if (s.serialNumber.isNotEmpty) '#${s.serialNumber}',
                  if (s.hostOrganism.isNotEmpty) s.hostOrganism,
                ].join(' · '),
                selected: const {},
              );
              if (ids == null || ids.isEmpty || !context.mounted) return;
              final selected =
                  strains.where((s) => ids.contains(s.id)).toList();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StartCulturesScreen(strains: selected)));
            },
          ),
          IconButton(
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              final db = AppDatabaseProvider.of(context);
              final strains = await repo.watchAll().first;
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SelectExportScreen<Strain>(
                  title: 'Export strains',
                  fileName: 'strains.pdf',
                  items: strains,
                  idOf: (s) => s.id,
                  titleOf: (s) => s.name,
                  subtitleOf: (s) => [
                    if (s.serialNumber.isNotEmpty) '#${s.serialNumber}',
                    if (s.hostOrganism.isNotEmpty) s.hostOrganism,
                  ].join(' · '),
                  buildSingle: (s, fonts) => buildStrainPdf(db, s, fonts),
                  buildTable: (list, fonts) =>
                      buildStrainsTablePdf(db, list, fonts),
                ),
              ));
            },
          ),
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => exportEntityCsv(context,
                AppDatabaseProvider.of(context), ImportEntity.strain, 'strains'),
          ),
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ImportScreen(entity: ImportEntity.strain))),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-strains',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const StrainEditScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New strain'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search strains',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Strain>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final strains = snapshot.data!
                    .where((s) => _matches(s, _query))
                    .toList()
                  ..sort(_compare);
                if (strains.isEmpty) {
                  return Center(
                    child: Text(_query.isEmpty
                        ? 'No strains yet.\nTap "New strain" to add one.'
                        : 'No strains match "$_query".'),
                  );
                }
                return ListView.separated(
                  itemCount: strains.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _StrainTile(strain: strains[i], repo: repo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StrainTile extends StatelessWidget {
  const _StrainTile({required this.strain, required this.repo});

  final Strain strain;
  final StrainRepository repo;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete strain?'),
        content: Text('Strain "${strain.name}" and its images will be moved to '
            'the Trash. You can restore them from Settings → Recently deleted.'),
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
    if (confirmed == true) await repo.delete(strain.id);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (strain.serialNumber.isNotEmpty) '#${strain.serialNumber}',
      if (strain.hostOrganism.isNotEmpty) strain.hostOrganism,
      if (strain.plasmid.isNotEmpty) 'plasmid ${strain.plasmid}',
      if (strain.constructNotes.isNotEmpty) strain.constructNotes,
    ].join(' · ');
    return ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StrainDetailScreen(strainId: strain.id))),
      title: Text(strain.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: GlassMoreButton(
        tooltip: 'Strain actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => StrainEditScreen(strain: strain)))),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
