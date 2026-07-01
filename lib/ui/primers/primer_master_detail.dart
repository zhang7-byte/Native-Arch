import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/primer_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../widgets.dart';
import 'primer_edit_screen.dart';

/// Desktop three-pane experience for Primers: a persistent list on the left
/// and an inline editor on the right. Selecting an item edits it in place and
/// "New primer" opens a blank editor — no full-screen navigation. Both panes
/// share a single [PrimerRepository.watchAll] stream.
class PrimerMasterDetail extends StatefulWidget {
  const PrimerMasterDetail({super.key});

  @override
  State<PrimerMasterDetail> createState() => _PrimerMasterDetailState();
}

class _PrimerMasterDetailState extends State<PrimerMasterDetail> {
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

  Future<void> _confirmDelete(
      BuildContext context, PrimerRepository repo, Primer primer) async {
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
    if (ok == true) {
      await repo.delete(primer.id);
      if (mounted && _selectedId == primer.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PrimerRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<Primer>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Primer>[];

          // Primers are ordered by name (see PrimerRepository.watchAll), not
          // newest-first, so we cannot reliably pick out a just-created row by
          // position. Skip auto-selecting the new primer after creation.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() => _selectNewestOnNextData = false);
            });
          }

          // Resolve the selected primer from the shared stream.
          Primer? selected;
          for (final p in rows) {
            if (p.id == _selectedId) {
              selected = p;
              break;
            }
          }
          // Selection deleted elsewhere — drop it after this frame.
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
                child: _listPane(context, repo, scheme, snapshot, rows),
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
    PrimerRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Primer>> snapshot,
    List<Primer> rows,
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
                child: Text('Primers',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New primer',
                onPressed: _startNew,
                icon: const Icon(Icons.add),
              ),
              const AccountButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _list(context, repo, scheme, snapshot, rows)),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    PrimerRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Primer>> snapshot,
    List<Primer> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load primers:\n${snapshot.error}',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No primers yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final primer = rows[i];
        final isSelected = primer.id == _selectedId;
        final meta = [
          if (primer.serialNumber.isNotEmpty) '#${primer.serialNumber}',
          if (primer.targetGene.isNotEmpty) primer.targetGene,
          if (primer.direction.isNotEmpty) primer.direction,
          if (primer.tm.isNotEmpty) 'Tm ${primer.tm}',
        ].join(' · ');
        final len = sequenceLength(primer.sequence);
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          isThreeLine: meta.isNotEmpty && len > 0,
          onTap: () => _select(primer.id),
          title: Text(primer.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meta.isNotEmpty)
                Text(meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              if (len > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: OutlineChip('$len nt')),
                ),
            ],
          ),
          trailing: GlassMoreButton(
            tooltip: 'Primer actions',
            actions: [
              GlassAction(
                  Icons.edit_outlined, 'Edit', () => _select(primer.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, primer),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Primer? selected) {
    if (_creating) {
      return PrimerEditScreen(
        // Fresh state for each new-primer session.
        key: const ValueKey('primer-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return PrimerEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('primer-${selected.id}'),
        embedded: true,
        primer: selected,
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
            Icon(Icons.science_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a primer to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
