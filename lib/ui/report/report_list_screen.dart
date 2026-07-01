import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/report_repository.dart';
import '../../export/pdf_export.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../glass.dart';
import '../labels.dart';
import 'report_edit_screen.dart';

/// Saved PI progress reports. Compose, edit, and export each as a self-contained
/// PDF that gathers the whole workspace.
class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ReportRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: const [AccountButton()],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-reports',
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportEditScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New report'),
      ),
      body: StreamBuilder<List<Report>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No reports yet.\n\nTap "New report" to compose a progress '
                  'report for your PI, then export it as a PDF with your '
                  'projects, experiments, tasks, cultures and inventory '
                  'included.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) =>
                _ReportTile(report: reports[i], repo: repo),
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.repo});

  final Report report;
  final ReportRepository repo;

  String get _period {
    final s = report.periodStart, e = report.periodEnd;
    if (s == null && e == null) return 'All activity';
    return '${formatDate(s)} – ${formatDate(e)}';
  }

  void _export(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Report PDF',
        fileName: 'labtrack-report.pdf',
        builder: (fonts) => buildReportPdf(db, report, fonts),
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
    if (ok == true) await repo.delete(report.id);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (report.recipient.isNotEmpty) 'To: ${report.recipient}',
      _period,
    ].join('  ·  ');
    return ListTile(
      leading: const Icon(Icons.assessment_outlined),
      title: Text(report.title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportEditScreen(report: report))),
      trailing: GlassMoreButton(
        tooltip: 'Report actions',
        actions: [
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportEditScreen(report: report)))),
          GlassAction(Icons.picture_as_pdf_outlined, 'Export PDF',
              () => _export(context), mutates: false),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
