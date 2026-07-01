import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'culture_edit_screen.dart';
import 'culture_labels.dart';

/// Desktop three-pane experience for Active Cultures: a persistent list on the
/// left and an inline editor on the right. Selecting a culture edits it in place
/// and "New culture" opens a blank editor — no full-screen navigation. Both panes
/// share a single [CultureRepository.watchActive] stream (ordered by
/// started_date DESC, so a just-created culture is first).
class CultureMasterDetail extends StatefulWidget {
  const CultureMasterDetail({super.key});

  @override
  State<CultureMasterDetail> createState() => _CultureMasterDetailState();
}

class _CultureMasterDetailState extends State<CultureMasterDetail> {
  String? _selectedId;
  bool _creating = false;
  bool _selectNewestOnNextData = false;

  void _select(String id) => setState(() {
        _selectedId = id;
        _creating = false;
      });

  void _startNew() => setState(() {
        _creating = true;
        _selectedId = null;
      });

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
      body: StreamBuilder<List<Culture>>(
        stream: repo.watchActive(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Culture>[];

          // Just created a new culture: select the newest row (ordered by
          // started_date DESC, and a new culture defaults its started_date to
          // now, so the one we just wrote is first) once it arrives.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() {
                _selectedId = rows.first.id;
                _selectNewestOnNextData = false;
              });
            });
          }

          // Resolve the selected culture from the shared stream.
          Culture? selected;
          for (final c in rows) {
            if (c.id == _selectedId) {
              selected = c;
              break;
            }
          }
          // Selection deleted / moved off the active list elsewhere — drop it
          // after this frame.
          if (_selectedId != null && selected == null && snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedId != null) {
                setState(() => _selectedId = null);
              }
            });
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 340,
                child: _listPane(context, db, scheme, snapshot, rows),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(child: _detailPane(scheme, selected)),
            ],
          );
        },
      ),
    );
  }

  Widget _listPane(
    BuildContext context,
    AppDatabase db,
    ColorScheme scheme,
    AsyncSnapshot<List<Culture>> snapshot,
    List<Culture> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: title, New, account.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Cultures',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New culture',
                onPressed: _startNew,
                icon: const Icon(Icons.add),
              ),
              const AccountButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _list(context, db, scheme, snapshot, rows)),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    AppDatabase db,
    ColorScheme scheme,
    AsyncSnapshot<List<Culture>> snapshot,
    List<Culture> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load cultures:\n${snapshot.error}',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No active cultures.\n'
            'Tap + to add one, or start one from a strain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = rows[i];
        final isSelected = c.id == _selectedId;
        final ended = c.endedDate != null;
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          leading: const Icon(Icons.bubble_chart_outlined),
          onTap: () => _select(c.id),
          title: Text(c.name.isEmpty ? 'Culture' : c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                LabelChip(cultureStatusLabel(c.status),
                    color: cultureStatusColor(c.status, scheme)),
                if (c.medium.isNotEmpty) OutlineChip(c.medium),
                Text(
                  ended
                      ? 'Ended ${formatDate(c.endedDate)}'
                      : 'Started ${formatDate(c.startedDate)}',
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          trailing: GlassMoreButton(
            tooltip: 'Culture actions',
            actions: [
              GlassAction(Icons.edit_outlined, 'Edit', () => _select(c.id)),
              GlassAction(Icons.label_outline, 'Print label (PDF)',
                  () => _exportLabel(db, c), mutates: false),
              GlassAction(Icons.picture_as_pdf_outlined, 'Export PDF',
                  () => _exportPdf(db, c), mutates: false),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Culture? selected) {
    if (_creating) {
      return CultureEditScreen(
        // Fresh state for each new-culture session.
        key: const ValueKey('culture-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return CultureEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('culture-${selected.id}'),
        embedded: true,
        culture: selected,
        onSaved: () {},
      );
    }
    return _emptyDetail(scheme);
  }

  Widget _emptyDetail(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bubble_chart_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a culture to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to start a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
