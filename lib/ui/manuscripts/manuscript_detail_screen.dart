import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/manuscript_repository.dart';
import '../../data/project_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../labels.dart';
import '../widgets.dart';

/// A manuscript's details and current status, with PDF export.
class ManuscriptDetailScreen extends StatelessWidget {
  const ManuscriptDetailScreen({super.key, required this.manuscriptId});

  final String manuscriptId;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final manuscripts = ManuscriptRepository(db);
    final projects = ProjectRepository(db);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Manuscript?>(
      stream: manuscripts.watchById(manuscriptId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final m = snap.data;
        if (m == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This manuscript no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manuscript'),
            actions: [
              IconButton(
                tooltip: 'Export to PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(
                    title: 'Manuscript PDF',
                    fileName: 'manuscript.pdf',
                    builder: (fonts) => buildManuscriptPdf(db, m, fonts),
                  ),
                )),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(m.title, style: textTheme.headlineSmall),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: LabelChip('Status: ${enumLabel(m.status)}',
                    color: manuscriptStatusColor(m.status, scheme)),
              ),
              FutureBuilder<Project?>(
                future: projects.findById(m.projectId),
                builder: (context, s) => s.data == null
                    ? const SizedBox()
                    : _Field('Project', s.data!.title),
              ),
              if (m.targetJournal.isNotEmpty)
                _Field('Target journal', m.targetJournal),
              if (m.submissionId.isNotEmpty)
                _Field('Submission ID', m.submissionId),
              if (m.submittedDate != null)
                _Field('Submitted', formatDate(m.submittedDate)),
              if (m.notes.isNotEmpty) _Field('Notes', m.notes),
            ],
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }
}
