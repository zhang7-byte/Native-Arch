import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/protocol_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import 'protocol_edit_screen.dart';

/// Desktop three-pane experience for Protocols: a persistent list on the left
/// and an inline editor on the right. Selecting an item edits it in place and
/// "New protocol" opens a blank editor — no full-screen navigation. Both panes
/// share a single [ProtocolRepository.watchAll] stream.
class ProtocolMasterDetail extends StatefulWidget {
  const ProtocolMasterDetail({super.key});

  @override
  State<ProtocolMasterDetail> createState() => _ProtocolMasterDetailState();
}

class _ProtocolMasterDetailState extends State<ProtocolMasterDetail> {
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
      BuildContext context, ProtocolRepository repo, Protocol protocol) async {
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
    if (ok == true) {
      await repo.delete(protocol.id);
      if (mounted && _selectedId == protocol.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProtocolRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<Protocol>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Protocol>[];

          // Just created a new protocol: select the newest row (watchAll is
          // ordered by updated_at DESC, so the one we just wrote is first) once
          // it arrives.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() {
                _selectedId = rows.first.id;
                _selectNewestOnNextData = false;
              });
            });
          }

          // Resolve the selected protocol from the shared stream.
          Protocol? selected;
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
    ProtocolRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Protocol>> snapshot,
    List<Protocol> rows,
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
                child: Text('Protocols',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New protocol',
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
    ProtocolRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Protocol>> snapshot,
    List<Protocol> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load protocols:\n${snapshot.error}',
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
          child: Text('No protocols yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final protocol = rows[i];
        final isSelected = protocol.id == _selectedId;
        final n = protocol.steps.length;
        final subtitle = [
          if (protocol.category.isNotEmpty) protocol.category,
          '$n step${n == 1 ? '' : 's'}',
        ].join('  ·  ');
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          leading: const Icon(Icons.menu_book_outlined),
          onTap: () => _select(protocol.id),
          title: Text(protocol.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: GlassMoreButton(
            tooltip: 'Protocol actions',
            actions: [
              GlassAction(
                  Icons.edit_outlined, 'Edit', () => _select(protocol.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, protocol),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Protocol? selected) {
    if (_creating) {
      return ProtocolEditScreen(
        // Fresh state for each new-protocol session.
        key: const ValueKey('protocol-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return ProtocolEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('protocol-${selected.id}'),
        embedded: true,
        protocol: selected,
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
            Icon(Icons.menu_book_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a protocol to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
