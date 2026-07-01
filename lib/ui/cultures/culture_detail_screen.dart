import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../../data/strain_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../images/images_section.dart';
import '../labels.dart';
import '../strains/strain_detail_screen.dart';
import '../widgets.dart';
import 'culture_edit_screen.dart';
import 'culture_labels.dart';
import 'culture_operations_section.dart';

/// A culture's details, its strain, its images, and its lifecycle actions
/// (terminate / archive when active; restore when not).
class CultureDetailScreen extends StatelessWidget {
  const CultureDetailScreen({super.key, required this.cultureId});

  final String cultureId;

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final cultures = CultureRepository(db);
    final strains = StrainRepository(db);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Culture?>(
      stream: cultures.watchById(cultureId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final c = snap.data;
        if (c == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This culture no longer exists.')),
          );
        }
        final active = c.status == 'active';
        return Scaffold(
          appBar: AppBar(
            title: const Text('Culture'),
            actions: [
              IconButton(
                tooltip: 'Export to PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PdfPreviewScreen(
                          title: 'Culture PDF',
                          fileName: 'culture.pdf',
                          builder: (fonts) => buildCulturePdf(db, c, fonts),
                        ))),
              ),
              IconButton(
                tooltip: 'Edit culture',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CultureEditScreen(culture: c))),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(c.name.isEmpty ? 'Culture' : c.name,
                  style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: LabelChip(cultureStatusLabel(c.status),
                    color: cultureStatusColor(c.status, scheme)),
              ),
              if (c.strainId != null)
                FutureBuilder<Strain?>(
                  future: strains.findById(c.strainId!),
                  builder: (context, s) {
                    final strain = s.data;
                    if (strain == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STRAIN',
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          ActionChip(
                            avatar: const Icon(Icons.coronavirus_outlined,
                                size: 16),
                            label: Text(strain.name),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => StrainDetailScreen(
                                        strainId: strain.id))),
                          ),
                          // Fall back to the strain's markers only when this
                          // culture has none of its own.
                          if (strain.selectionMarkers.isNotEmpty &&
                              c.selectionMarkers.isEmpty) ...[
                            const SizedBox(height: 8),
                            _SelectionChips(
                                label: 'SELECTION (from strain)',
                                markers: strain.selectionMarkers),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              if (c.selectionMarkers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _SelectionChips(
                      label: 'SELECTION', markers: c.selectionMarkers),
                ),
              if (c.medium.isNotEmpty) _Field('Medium', c.medium),
              if (c.vessel.isNotEmpty) _Field('Vessel', c.vessel),
              if (c.inoculumAmount.isNotEmpty)
                _Field('Amount', c.inoculumAmount),
              _Field(c.parentCultureId != null ? 'Inoculated (split)' : 'Started',
                  formatDateTime(c.startedDate)),
              if (c.endedDate != null)
                _Field('Ended', formatDateTime(c.endedDate)),
              if (c.parentCultureId != null)
                _SplitLineage(culture: c, cultures: cultures),
              if (c.notes.isNotEmpty) _Field('Notes', c.notes),
              const Divider(height: 36),
              if (active)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => cultures.terminate(c.id),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Terminate'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => cultures.archive(c.id),
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('Archive'),
                      ),
                    ),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: () => cultures.restore(c.id),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restore to active'),
                ),
              const Divider(height: 36),
              CultureOperationsSection(culture: c),
              const Divider(height: 36),
              ImagesSection(cultureId: c.id),
            ],
          ),
        );
      },
    );
  }
}

/// A labelled wrap of selection-marker chips.
class _SelectionChips extends StatelessWidget {
  const _SelectionChips({required this.label, required this.markers});

  final String label;
  final List<String> markers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [for (final m in markers) OutlineChip(m)],
        ),
      ],
    );
  }
}

/// Shows the mother culture this one was split from + the inoculation/split
/// times, with a link to the mother.
class _SplitLineage extends StatelessWidget {
  const _SplitLineage({required this.culture, required this.cultures});

  final Culture culture;
  final CultureRepository cultures;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SPLIT FROM',
              style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
          const SizedBox(height: 4),
          FutureBuilder<Culture?>(
            future: cultures.findById(culture.parentCultureId!),
            builder: (context, s) {
              final mother = s.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mother != null)
                    ActionChip(
                      avatar: const Icon(Icons.bubble_chart_outlined, size: 16),
                      label: Text(mother.name.isEmpty ? 'Culture' : mother.name),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  CultureDetailScreen(cultureId: mother.id))),
                    )
                  else
                    Text('Mother culture no longer available',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  if (culture.parentInoculatedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          'Mother inoculated ${formatDateTime(culture.parentInoculatedAt)}  ·  '
                          'split ${formatDateTime(culture.startedDate)}',
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 12)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
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
          Text(label.toUpperCase(),
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
