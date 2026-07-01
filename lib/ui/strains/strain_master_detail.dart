import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/strain_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import 'strain_edit_screen.dart';

/// Desktop three-pane experience for Strains: a persistent list on the left and
/// an inline editor on the right. Selecting an item edits it in place and
/// "New strain" opens a blank editor — no full-screen navigation. Both panes
/// share a single [StrainRepository.watchAll] stream.
class StrainMasterDetail extends StatefulWidget {
  const StrainMasterDetail({super.key});

  @override
  State<StrainMasterDetail> createState() => _StrainMasterDetailState();
}

class _StrainMasterDetailState extends State<StrainMasterDetail> {
  String? _selectedId;
  bool _creating = false;

  void _select(String id) => setState(() {
        _selectedId = id;
        _creating = false;
      });

  void _startNew() => setState(() {
        _creating = true;
        _selectedId = null;
      });

  Future<void> _confirmDelete(
      BuildContext context, StrainRepository repo, Strain strain) async {
    final ok = await showGlassDialog<bool>(
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
    if (ok == true) {
      await repo.delete(strain.id);
      if (mounted && _selectedId == strain.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = StrainRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<Strain>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Strain>[];

          // NOTE: watchAll() is ordered by name (ORDER BY name), not
          // newest-first, so a freshly created strain is not reliably at
          // rows.first. We therefore do not auto-select the newest row after
          // creating one; the editor simply returns to the empty placeholder.

          // Resolve the selected strain from the shared stream.
          Strain? selected;
          for (final s in rows) {
            if (s.id == _selectedId) {
              selected = s;
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
    StrainRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Strain>> snapshot,
    List<Strain> rows,
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
                child: Text('Strains',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New strain',
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
    StrainRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Strain>> snapshot,
    List<Strain> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load strains:\n${snapshot.error}',
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
          child: Text('No strains yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final strain = rows[i];
        final isSelected = strain.id == _selectedId;
        final subtitle = [
          if (strain.serialNumber.isNotEmpty) '#${strain.serialNumber}',
          if (strain.hostOrganism.isNotEmpty) strain.hostOrganism,
          if (strain.plasmid.isNotEmpty) 'plasmid ${strain.plasmid}',
          if (strain.constructNotes.isNotEmpty) strain.constructNotes,
        ].join(' · ');
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          onTap: () => _select(strain.id),
          title: Text(strain.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitle.isEmpty
              ? null
              : Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
          trailing: GlassMoreButton(
            tooltip: 'Strain actions',
            actions: [
              GlassAction(
                  Icons.edit_outlined, 'Edit', () => _select(strain.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, strain),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Strain? selected) {
    if (_creating) {
      return StrainEditScreen(
        // Fresh state for each new-strain session.
        key: const ValueKey('strain-new'),
        embedded: true,
        onSaved: () => setState(() => _creating = false),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return StrainEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('strain-${selected.id}'),
        embedded: true,
        strain: selected,
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
            Text('Select a strain to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
