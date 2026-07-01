import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/reagent_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'reagent_edit_screen.dart';

/// Desktop three-pane experience for Reagents: a persistent list on the left
/// and an inline editor on the right. Selecting an item edits it in place and
/// "New reagent" opens a blank editor — no full-screen navigation. Both panes
/// share a single [ReagentRepository.watchAll] stream.
class ReagentMasterDetail extends StatefulWidget {
  const ReagentMasterDetail({super.key});

  @override
  State<ReagentMasterDetail> createState() => _ReagentMasterDetailState();
}

class _ReagentMasterDetailState extends State<ReagentMasterDetail> {
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
      BuildContext context, ReagentRepository repo, Reagent reagent) async {
    final noun = reagent.kind == 'buffer' ? 'buffer' : 'reagent';
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
    if (confirmed == true) {
      await repo.delete(reagent.id);
      if (mounted && _selectedId == reagent.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ReagentRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Scaffold(
      body: StreamBuilder<List<Reagent>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Reagent>[];

          // NOTE: watchAll() is ordered by name (alphabetical), NOT newest
          // first, so we cannot auto-select the newest row after a create —
          // there is no reliable "newest" position in the list. New reagents
          // simply appear in the list and the creator can tap to select one.

          // Resolve the selected reagent from the shared stream.
          Reagent? selected;
          for (final r in rows) {
            if (r.id == _selectedId) {
              selected = r;
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
                child: _listPane(context, repo, scheme, now, snapshot, rows),
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
    ReagentRepository repo,
    ColorScheme scheme,
    DateTime now,
    AsyncSnapshot<List<Reagent>> snapshot,
    List<Reagent> rows,
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
                child: Text('Reagents',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New reagent',
                onPressed: _startNew,
                icon: const Icon(Icons.add),
              ),
              const AccountButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _list(context, repo, scheme, now, snapshot, rows)),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    ReagentRepository repo,
    ColorScheme scheme,
    DateTime now,
    AsyncSnapshot<List<Reagent>> snapshot,
    List<Reagent> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load reagents:\n${snapshot.error}',
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
          child: Text('No reagents yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final reagent = rows[i];
        final isBuffer = reagent.kind == 'buffer';
        final isSelected = reagent.id == _selectedId;
        final meta = isBuffer
            ? reagent.recipe.replaceAll('\n', ' ').trim()
            : [
                if (reagent.supplier.isNotEmpty) reagent.supplier,
                if (reagent.catalogNo.isNotEmpty) reagent.catalogNo,
                if (reagent.location.isNotEmpty) reagent.location,
              ].join(' · ');
        final chip = _expiryChip(reagent, now);
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          isThreeLine: chip != null,
          leading: Icon(
              isBuffer ? Icons.opacity_outlined : Icons.science_outlined),
          onTap: () => _select(reagent.id),
          title: Text(reagent.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              GlassAction(Icons.edit_outlined, 'Edit',
                  () => _select(reagent.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, reagent),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget? _expiryChip(Reagent reagent, DateTime now) {
    final date = formatDate(reagent.expiryDate);
    return switch (expiryState(reagent.expiryDate, now)) {
      ExpiryState.none => null,
      ExpiryState.expired => LabelChip('Expired $date', color: Colors.red),
      ExpiryState.soon =>
        LabelChip('Expires soon · $date', color: Colors.orange),
      ExpiryState.ok => OutlineChip('Expires $date'),
    };
  }

  Widget _detailPane(ColorScheme scheme, Reagent? selected) {
    if (_creating) {
      return ReagentEditScreen(
        // Fresh state for each new-reagent session.
        key: const ValueKey('reagent-new'),
        embedded: true,
        onSaved: () => setState(() => _creating = false),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return ReagentEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('reagent-${selected.id}'),
        embedded: true,
        reagent: selected,
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
            Text('Select a reagent to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
