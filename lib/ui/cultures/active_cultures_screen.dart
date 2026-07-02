import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../../data/strain_repository.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../export/select_export_screen.dart';
import '../glass.dart';
import '../master_detail.dart';
import 'archived_cultures_screen.dart';
import 'culture_edit_screen.dart';
import 'culture_tile.dart';

/// How the active-culture list is ordered.
enum CultureSort {
  started('Started date'),
  created('Date created'),
  modified('Last modified'),
  strain('Strain');

  const CultureSort(this.label);
  final String label;
}

/// Main Active Cultures page: cultures with status = active, sortable, each
/// exportable to PDF. The overflow leads to the Archived & Terminated sub-page;
/// the FAB starts a new culture.
class ActiveCulturesScreen extends StatefulWidget {
  const ActiveCulturesScreen({super.key});

  @override
  State<ActiveCulturesScreen> createState() => _ActiveCulturesScreenState();
}

class _ActiveCulturesScreenState extends State<ActiveCulturesScreen> {
  CultureSort _sort = CultureSort.started;

  int _compare(Culture a, Culture b, Map<String, String> nameById) {
    switch (_sort) {
      case CultureSort.started:
        return b.startedDate.compareTo(a.startedDate);
      case CultureSort.created:
        return b.createdAt.compareTo(a.createdAt);
      case CultureSort.modified:
        return b.updatedAt.compareTo(a.updatedAt);
      case CultureSort.strain:
        final an = (nameById[a.strainId] ?? '~').toLowerCase();
        final bn = (nameById[b.strainId] ?? '~').toLowerCase();
        final c = an.compareTo(bn);
        return c != 0
            ? c
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }

  void _exportPdf(AppDatabase db, Culture c) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Culture PDF',
        fileName: 'culture.pdf',
        builder: (fonts) => buildCulturePdf(db, c, fonts),
      ),
    ));
  }

  void _exportLabel(AppDatabase db, Culture c) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Culture label',
        fileName: 'culture-label.pdf',
        builder: (fonts) => buildCultureLabelPdf(db, c, fonts),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final repo = CultureRepository(db);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Cultures'),
        actions: [
          PopupMenuButton<CultureSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (ctx) => [
              for (final s in CultureSort.values)
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
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              final cultures = await repo.watchActive().first;
              final strains = await StrainRepository(db).watchAll().first;
              final nameById = {for (final s in strains) s.id: s.name};
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SelectExportScreen<Culture>(
                  title: 'Export cultures',
                  fileName: 'cultures.pdf',
                  items: cultures,
                  idOf: (c) => c.id,
                  titleOf: (c) => c.name.isEmpty ? '(unnamed)' : c.name,
                  subtitleOf: (c) => [
                    if (c.strainId != null && nameById[c.strainId] != null)
                      nameById[c.strainId]!,
                    if (c.medium.isNotEmpty) c.medium,
                  ].join(' · '),
                  buildSingle: (c, fonts) => buildCulturePdf(db, c, fonts),
                  buildTable: (list, fonts) =>
                      buildCulturesTablePdf(db, list, fonts),
                ),
              ));
            },
          ),
          IconButton(
            tooltip: 'Archived & terminated',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ArchivedCulturesScreen())),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-cultures',
        onPressed: () => openDetail(
            context, (_) => const CultureEditScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New culture'),
      ),
      body: StreamBuilder<List<Strain>>(
        stream: StrainRepository(db).watchAll(),
        builder: (context, strainSnap) {
          final nameById = {
            for (final s in strainSnap.data ?? const <Strain>[]) s.id: s.name
          };
          return StreamBuilder<List<Culture>>(
            stream: repo.watchActive(),
            builder: (context, snap) {
              final items = [...(snap.data ?? const <Culture>[])];
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No active cultures.\n'
                      'Tap "New culture", or start one from a strain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                );
              }
              items.sort((a, b) => _compare(a, b, nameById));
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return CultureTile(
                    culture: c,
                    trailing: GlassMoreButton(
                      tooltip: 'Culture actions',
                      actions: [
                        GlassAction(Icons.label_outline, 'Print label (PDF)',
                            () => _exportLabel(db, c), mutates: false),
                        GlassAction(Icons.picture_as_pdf_outlined, 'Export PDF',
                            () => _exportPdf(db, c), mutates: false),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
