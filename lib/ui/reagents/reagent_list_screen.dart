import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/csv_import.dart';
import '../../data/reagent_repository.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/export_csv.dart';
import '../export/select_export_screen.dart';
import '../glass.dart';
import '../import/import_screen.dart';
import '../labels.dart';
import '../master_detail.dart';
import '../widgets.dart';
import 'reagent_edit_screen.dart';

/// Which kind of inventory the list is showing.
enum _ReagentFilter {
  all('All'),
  reagents('Reagents'),
  buffers('Buffers');

  const _ReagentFilter(this.label);
  final String label;
}

/// Searchable list of reagents and buffers, flagging any expiring within 30 days.
class ReagentListScreen extends StatefulWidget {
  const ReagentListScreen({super.key});

  @override
  State<ReagentListScreen> createState() => _ReagentListScreenState();
}

class _ReagentListScreenState extends State<ReagentListScreen> {
  String _query = '';
  _ReagentFilter _filter = _ReagentFilter.all;

  bool _kindMatches(Reagent r) => switch (_filter) {
        _ReagentFilter.all => true,
        _ReagentFilter.reagents => r.kind != 'buffer',
        _ReagentFilter.buffers => r.kind == 'buffer',
      };

  bool _matches(Reagent r, String q) {
    if (q.isEmpty) return true;
    final hay = [
      r.name,
      r.supplier,
      r.catalogNo,
      r.lot,
      r.location,
      r.recipe,
      r.notes,
      r.kind,
    ].join(' ').toLowerCase();
    return hay.contains(q.toLowerCase());
  }

  Future<void> _exportPdf(BuildContext context, ReagentRepository repo) async {
    final db = AppDatabaseProvider.of(context);
    final all = await repo.watchAll().first;
    final items = all.where(_kindMatches).toList();
    if (!context.mounted) return;
    final buffersOnly = _filter == _ReagentFilter.buffers;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SelectExportScreen<Reagent>(
        title: buffersOnly ? 'Export buffers' : 'Export reagents',
        fileName: buffersOnly ? 'buffers.pdf' : 'reagents.pdf',
        items: items,
        idOf: (r) => r.id,
        titleOf: (r) => r.name,
        subtitleOf: (r) => [
          r.kind == 'buffer' ? 'Buffer' : 'Reagent',
          if (r.supplier.isNotEmpty) r.supplier,
          if (r.catalogNo.isNotEmpty) r.catalogNo,
        ].join(' · '),
        buildSingle: (r, fonts) => buildReagentPdf(db, r, fonts),
        buildTable: (list, fonts) => buildReagentsTablePdf(db, list, fonts),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ReagentRepository(AppDatabaseProvider.of(context));
    // A single "today" for every row's expiry comparison this build.
    final now = DateTime.now();
    final buffersFilter = _filter == _ReagentFilter.buffers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reagents & buffers'),
        actions: [
          IconButton(
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportPdf(context, repo),
          ),
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => exportEntityCsv(context,
                AppDatabaseProvider.of(context), ImportEntity.reagent,
                'reagents'),
          ),
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ImportScreen(entity: ImportEntity.reagent))),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-reagents',
        onPressed: () => openDetail(
            context, (_) => ReagentEditScreen(
                initialKind: buffersFilter ? 'buffer' : 'reagent')),
        icon: const Icon(Icons.add),
        label: Text(buffersFilter ? 'New buffer' : 'New reagent'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search reagents & buffers',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final f in _ReagentFilter.values)
                    ChoiceChip(
                      label: Text(f.label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Reagent>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reagents = snapshot.data!
                    .where((r) => _kindMatches(r) && _matches(r, _query))
                    .toList();
                if (reagents.isEmpty) {
                  return Center(
                    child: Text(_query.isEmpty
                        ? (buffersFilter
                            ? 'No buffers yet.\nTap "New buffer" to add one.'
                            : 'No reagents yet.\nTap "New reagent" to add one.')
                        : 'Nothing matches "$_query".'),
                  );
                }
                return ListView.separated(
                  itemCount: reagents.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _ReagentTile(reagent: reagents[i], now: now, repo: repo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReagentTile extends StatelessWidget {
  const _ReagentTile(
      {required this.reagent, required this.now, required this.repo});

  final Reagent reagent;
  final DateTime now;
  final ReagentRepository repo;

  bool get _isBuffer => reagent.kind == 'buffer';

  Future<void> _confirmDelete(BuildContext context) async {
    final noun = _isBuffer ? 'buffer' : 'reagent';
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: Text('Delete $noun?'),
        content: Text('"${reagent.name}" will be moved to the Trash. '
            'You can restore it from Settings → Recently deleted.'),
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
    if (confirmed == true) await repo.delete(reagent.id);
  }

  Widget? _expiryChip() {
    final date = formatDate(reagent.expiryDate);
    return switch (expiryState(reagent.expiryDate, now)) {
      ExpiryState.none => null,
      ExpiryState.expired => LabelChip('Expired $date', color: Colors.red),
      ExpiryState.soon =>
        LabelChip('Expires soon · $date', color: Colors.orange),
      ExpiryState.ok => OutlineChip('Expires $date'),
    };
  }

  @override
  Widget build(BuildContext context) {
    // Buffers lead with their recipe; reagents with supplier/catalog/location.
    final meta = _isBuffer
        ? reagent.recipe.replaceAll('\n', ' ').trim()
        : [
            if (reagent.supplier.isNotEmpty) reagent.supplier,
            if (reagent.catalogNo.isNotEmpty) reagent.catalogNo,
            if (reagent.location.isNotEmpty) reagent.location,
          ].join(' · ');
    final chip = _expiryChip();
    return ListTile(
      isThreeLine: chip != null,
      leading: Icon(
          _isBuffer ? Icons.opacity_outlined : Icons.science_outlined),
      onTap: () => openDetail(
          context, (_) => ReagentEditScreen(reagent: reagent)),
      title: Text(reagent.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.isNotEmpty)
            Text(meta, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (chip != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(alignment: Alignment.centerLeft, child: chip),
            ),
        ],
      ),
      trailing: GlassMoreButton(
        tooltip: 'Actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => openDetail(
                  context, (_) => ReagentEditScreen(reagent: reagent))),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
