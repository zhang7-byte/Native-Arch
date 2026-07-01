import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'experiment_edit_screen.dart';

/// Desktop three-pane experience for Experiments: a persistent list on the left
/// and an inline editor on the right. Selecting an item edits it in place and
/// "New experiment" opens a blank editor — no full-screen navigation. Both panes
/// share a single [ExperimentRepository.watchAllWithProject] stream.
class ExperimentMasterDetail extends StatefulWidget {
  const ExperimentMasterDetail({super.key});

  @override
  State<ExperimentMasterDetail> createState() => _ExperimentMasterDetailState();
}

class _ExperimentMasterDetailState extends State<ExperimentMasterDetail> {
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
      BuildContext context, ExperimentRepository repo, Experiment exp) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete experiment?'),
        content: Text(
            '"${exp.title}" and its tasks, images and progress log will be '
            'moved to the Trash. You can restore them from '
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
      await repo.delete(exp.id);
      if (mounted && _selectedId == exp.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExperimentRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<(Experiment, String)>>(
        stream: repo.watchAllWithProject(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <(Experiment, String)>[];

          // Just created a new experiment: select the newest row (ordered by
          // updated_at DESC, so the one we just wrote is first) once it arrives.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() {
                _selectedId = rows.first.$1.id;
                _selectNewestOnNextData = false;
              });
            });
          }

          // Resolve the selected experiment from the shared stream.
          Experiment? selected;
          for (final (e, _) in rows) {
            if (e.id == _selectedId) {
              selected = e;
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
    ExperimentRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<(Experiment, String)>> snapshot,
    List<(Experiment, String)> rows,
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
                child: Text('Experiments',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New experiment',
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
    ExperimentRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<(Experiment, String)>> snapshot,
    List<(Experiment, String)> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load experiments:\n${snapshot.error}',
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
          child: Text('No experiments yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final (exp, projectTitle) = rows[i];
        final isSelected = exp.id == _selectedId;
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          isThreeLine: true,
          onTap: () => _select(exp.id),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(exp.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('in $projectTitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 4, children: [
                LabelChip(enumLabel(exp.status),
                    color: experimentStatusColor(exp.status, scheme)),
                if (exp.strainIds.isNotEmpty)
                  OutlineChip('${exp.strainIds.length} strain(s)'),
              ]),
            ],
          ),
          trailing: GlassMoreButton(
            tooltip: 'Experiment actions',
            actions: [
              GlassAction(Icons.edit_outlined, 'Edit', () => _select(exp.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, exp),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Experiment? selected) {
    if (_creating) {
      return ExperimentEditScreen(
        // Fresh state for each new-experiment session.
        key: const ValueKey('experiment-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return ExperimentEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('experiment-${selected.id}'),
        embedded: true,
        experiment: selected,
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
            Icon(Icons.biotech_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select an experiment to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
