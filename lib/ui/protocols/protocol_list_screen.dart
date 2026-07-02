import 'package:flutter/material.dart';

import '../../data/csv_import.dart';
import '../../data/database.dart';
import '../../data/protocol_repository.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/export_csv.dart';
import '../export/pdf_preview_screen.dart';
import '../export/select_export_screen.dart';
import '../glass.dart';
import '../import/import_screen.dart';
import '../master_detail.dart';
import 'protocol_edit_screen.dart';

/// Searchable library of reusable lab protocols (SOPs). Compose step-by-step,
/// attach annotated images, export to PDF and import from CSV.
class ProtocolListScreen extends StatefulWidget {
  const ProtocolListScreen({super.key});

  @override
  State<ProtocolListScreen> createState() => _ProtocolListScreenState();
}

class _ProtocolListScreenState extends State<ProtocolListScreen> {
  String _query = '';

  bool _matches(Protocol p, String q) {
    if (q.isEmpty) return true;
    final hay = [
      p.name,
      p.category,
      p.summary,
      p.materials,
      p.notes,
      p.steps.join(' '),
    ].join(' ').toLowerCase();
    return hay.contains(q.toLowerCase());
  }

  Future<void> _exportPdf(BuildContext context, ProtocolRepository repo) async {
    final db = AppDatabaseProvider.of(context);
    final protocols = await repo.watchAll().first;
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SelectExportScreen<Protocol>(
        title: 'Export protocols',
        fileName: 'protocols.pdf',
        items: protocols,
        idOf: (p) => p.id,
        titleOf: (p) => p.name,
        subtitleOf: (p) => [
          if (p.category.isNotEmpty) p.category,
          '${p.steps.length} step${p.steps.length == 1 ? '' : 's'}',
        ].join(' · '),
        buildSingle: (p, fonts) => buildProtocolPdf(db, p, fonts),
        buildTable: (list, fonts) => buildProtocolsTablePdf(db, list, fonts),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProtocolRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
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
                AppDatabaseProvider.of(context), ImportEntity.protocol,
                'protocols'),
          ),
          IconButton(
            tooltip: 'Import CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const ImportScreen(entity: ImportEntity.protocol))),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-protocols',
        onPressed: () =>
            openDetail(context, (_) => const ProtocolEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New protocol'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search protocols',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Protocol>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final protocols =
                    snapshot.data!.where((p) => _matches(p, _query)).toList();
                if (protocols.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _query.isEmpty
                            ? 'No protocols yet.\n\nTap "New protocol" to compose '
                                'a step-by-step procedure, attach images and '
                                'export it as a PDF.'
                            : 'No protocols match "$_query".',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: protocols.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _ProtocolTile(protocol: protocols[i], repo: repo),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolTile extends StatelessWidget {
  const _ProtocolTile({required this.protocol, required this.repo});

  final Protocol protocol;
  final ProtocolRepository repo;

  void _export(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Protocol PDF',
        fileName: 'protocol.pdf',
        builder: (fonts) => buildProtocolPdf(db, protocol, fonts),
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => GlassAlertDialog(
        title: const Text('Delete protocol?'),
        content: Text('"${protocol.name}" will be moved to the Trash. You can '
            'restore it from Settings → Recently deleted.'),
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
    if (ok == true) await repo.delete(protocol.id);
  }

  @override
  Widget build(BuildContext context) {
    final n = protocol.steps.length;
    final subtitle = [
      if (protocol.category.isNotEmpty) protocol.category,
      '$n step${n == 1 ? '' : 's'}',
    ].join('  ·  ');
    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: Text(protocol.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () => openDetail(
          context, (_) => ProtocolEditScreen(protocol: protocol)),
      trailing: GlassMoreButton(
        tooltip: 'Protocol actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => openDetail(context,
                  (_) => ProtocolEditScreen(protocol: protocol))),
          GlassAction(Icons.picture_as_pdf_outlined, 'Export PDF',
              () => _export(context),
              mutates: false),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
