import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/report_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import 'report_edit_screen.dart';

/// Desktop three-pane experience for Reports: a persistent list on the left and
/// an inline editor on the right. Selecting an item edits it in place and "New
/// report" opens a blank editor — no full-screen navigation. Both panes share a
/// single [ReportRepository.watchAll] stream.
class ReportMasterDetail extends StatefulWidget {
  const ReportMasterDetail({super.key});

  @override
  State<ReportMasterDetail> createState() => _ReportMasterDetailState();
}

class _ReportMasterDetailState extends State<ReportMasterDetail> {
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
      BuildContext context, ReportRepository repo, Report report) async {
    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: Text('"${report.title}" will be moved to the Trash. You can '
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
      await repo.delete(report.id);
      if (mounted && _selectedId == report.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ReportRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<Report>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Report>[];

          // Just created a new report: select the newest row (ordered by
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

          // Resolve the selected report from the shared stream.
          Report? selected;
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
    ReportRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Report>> snapshot,
    List<Report> rows,
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
                child: Text('Reports',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New report',
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
    ReportRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Report>> snapshot,
    List<Report> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load reports:\n${snapshot.error}',
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
          child: Text('No reports yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final report = rows[i];
        final isSelected = report.id == _selectedId;
        final period = _periodLabel(report);
        final subtitle = [
          if (report.recipient.isNotEmpty) 'To: ${report.recipient}',
          period,
        ].join('  ·  ');
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          leading: const Icon(Icons.assessment_outlined),
          onTap: () => _select(report.id),
          title: Text(report.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: GlassMoreButton(
            tooltip: 'Report actions',
            actions: [
              GlassAction(
                  Icons.edit_outlined, 'Edit', () => _select(report.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, report),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  String _periodLabel(Report report) {
    final s = report.periodStart, e = report.periodEnd;
    if (s == null && e == null) return 'All activity';
    return '${formatDate(s)} – ${formatDate(e)}';
  }

  Widget _detailPane(ColorScheme scheme, Report? selected) {
    if (_creating) {
      return ReportEditScreen(
        // Fresh state for each new-report session.
        key: const ValueKey('report-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return ReportEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('report-${selected.id}'),
        embedded: true,
        report: selected,
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
            Icon(Icons.assessment_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a report to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
