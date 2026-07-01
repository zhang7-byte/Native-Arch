import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/strain_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../cultures/culture_edit_screen.dart';
import '../experiments/experiment_detail_screen.dart';
import '../export/pdf_preview_screen.dart';
import '../images/images_section.dart';
import '../labels.dart';
import '../widgets.dart';
import 'strain_edit_screen.dart';

/// A strain's details and the experiments that used it.
class StrainDetailScreen extends StatelessWidget {
  const StrainDetailScreen({super.key, required this.strainId});

  final String strainId;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final strains = StrainRepository(db);
    final experiments = ExperimentRepository(db);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Strain?>(
      stream: strains.watchById(strainId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final s = snap.data;
        if (s == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This strain no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Strain'),
            actions: [
              IconButton(
                tooltip: 'Start culture',
                icon: const Icon(Icons.bubble_chart_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CultureEditScreen(defaultStrainId: s.id))),
              ),
              IconButton(
                tooltip: 'Export to PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(
                          title: 'Strain PDF',
                          fileName: 'strain.pdf',
                          builder: (fonts) => buildStrainPdf(db, s, fonts),
                        ))),
              ),
              IconButton(
                tooltip: 'Edit strain',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => StrainEditScreen(strain: s))),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.name, style: textTheme.headlineSmall),
              if (s.serialNumber.isNotEmpty)
                _Field('Serial number', s.serialNumber),
              if (s.hostOrganism.isNotEmpty)
                _Field('Host organism', s.hostOrganism),
              if (s.genotype.isNotEmpty) _Field('Genotype', s.genotype),
              if (s.plasmid.isNotEmpty) _Field('Plasmid', s.plasmid),
              if (s.constructNotes.isNotEmpty)
                _Field('Construct notes', s.constructNotes),
              if (s.selectionMarkers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selection markers',
                          style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final m in s.selectionMarkers) OutlineChip(m),
                        ],
                      ),
                    ],
                  ),
                ),
              if (s.freezerLocation.isNotEmpty)
                _Field('Freezer location', s.freezerLocation),
              if (s.notes.isNotEmpty) _Field('Notes', s.notes),
              const Divider(height: 36),
              Text('Used in experiments', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              StreamBuilder<List<Experiment>>(
                stream: experiments.watchUsingStrain(strainId),
                builder: (context, s2) {
                  final items = s2.data ?? const <Experiment>[];
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Not used in any experiment yet.',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    );
                  }
                  return Column(
                    children: [
                      for (final e in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.biotech_outlined),
                          title: Text(e.title),
                          subtitle: Align(
                            alignment: Alignment.centerLeft,
                            child: LabelChip(enumLabel(e.status),
                                color:
                                    experimentStatusColor(e.status, scheme)),
                          ),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ExperimentDetailScreen(
                                      experimentId: e.id))),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 36),
              ImagesSection(strainId: strainId),
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
