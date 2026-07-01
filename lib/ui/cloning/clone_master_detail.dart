import 'package:flutter/material.dart';

import '../../data/clone_repository.dart';
import '../../data/database.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import 'clone_edit_screen.dart';

/// Desktop three-pane experience for Cloning: a persistent list on the left and
/// an inline editor on the right. Selecting an item edits it in place and "New
/// construction" opens a blank editor — no full-screen navigation. Both panes
/// share a single [CloneRepository.watchAll] stream.
class CloneMasterDetail extends StatefulWidget {
  const CloneMasterDetail({super.key});

  @override
  State<CloneMasterDetail> createState() => _CloneMasterDetailState();
}

class _CloneMasterDetailState extends State<CloneMasterDetail> {
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
      BuildContext context, CloneRepository repo, CloneConstruction c) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete construction?'),
        content: Text(
            '"${c.name.isEmpty ? 'Untitled' : c.name}"'
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
    if (ok == true) {
      await repo.delete(c.id);
      if (mounted && _selectedId == c.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = CloneRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<CloneConstruction>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <CloneConstruction>[];

          // Just created a new construction: select the newest row (ordered by
          // updated_at DESC, so the one we just wrote is first) once it arrives.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() {
                _selectedId = rows.first.id;
                _selectNewestOnNextData = false;
              });
            });
          }

          // Resolve the selected construction from the shared stream.
          CloneConstruction? selected;
          for (final c in rows) {
            if (c.id == _selectedId) {
              selected = c;
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
    CloneRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<CloneConstruction>> snapshot,
    List<CloneConstruction> rows,
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
                child: Text('Cloning',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New construction',
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
    CloneRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<CloneConstruction>> snapshot,
    List<CloneConstruction> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load constructions:\n${snapshot.error}',
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
          child: Text('No constructions yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = rows[i];
        final isSelected = c.id == _selectedId;
        final n = c.fragments.length;
        final subtitle = [
          if (c.backboneName.isNotEmpty) 'Backbone: ${c.backboneName}',
          '$n fragment${n == 1 ? '' : 's'}',
        ].join('  ·  ');
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          leading: const Icon(Icons.donut_large_outlined),
          onTap: () => _select(c.id),
          title: Text(
              c.name.isEmpty ? 'Untitled construction' : c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: GlassMoreButton(
            tooltip: 'Construction actions',
            actions: [
              GlassAction(Icons.edit_outlined, 'Edit', () => _select(c.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, c),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, CloneConstruction? selected) {
    if (_creating) {
      return CloneEditScreen(
        // Fresh state for each new-construction session.
        key: const ValueKey('clone-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return CloneEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('clone-${selected.id}'),
        embedded: true,
        construction: selected,
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
            Icon(Icons.donut_large_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a construction to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
