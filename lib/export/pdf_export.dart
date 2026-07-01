import 'dart:typed_data';

import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/database.dart';
import '../data/schedule.dart';
import '../data/settings_repository.dart';
import '../data/workspace_repository.dart';
import '../ui/cultures/culture_labels.dart'
    show cultureOpLabel, cultureOpSummary;
import '../ui/cloning/clone_vector.dart';
import '../ui/images/annotation.dart';

/// Fonts used by the generated PDFs. Bundled Roboto so Greek letters and
/// macrons in lab data (e.g. "Cα") render instead of boxing.
class PdfFonts {
  PdfFonts(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;
}

String _today() {
  final n = DateTime.now();
  String two(int x) => x.toString().padLeft(2, '0');
  return '${n.year}-${two(n.month)}-${two(n.day)}';
}

String _date(DateTime? d) {
  if (d == null) return '—';
  final l = d.toLocal();
  String two(int x) => x.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

String _pretty(String name) => name
    .split('_')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

pw.Widget _title(String t) => pw.Text(t,
    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold));

pw.Widget _subtle(String t) =>
    pw.Text(t, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700));

pw.Widget _label(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(t.toUpperCase(),
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 0.5)),
    );

pw.Widget _sectionTitle(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
      child: pw.Text(t,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _field(String label, String value) {
  if (value.trim().isEmpty) return pw.SizedBox();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      _label(label),
      pw.Text(value, style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
    ]),
  );
}

pw.Widget _chips(List<String> items) => pw.Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final i in items)
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text(i, style: const pw.TextStyle(fontSize: 10)),
          ),
      ],
    );

pw.Widget _bullet(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('•  ', style: const pw.TextStyle(fontSize: 11)),
        pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 11))),
      ]),
    );

pw.Widget _itemTitle(String t) =>
    pw.Text(t, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold));

/// Builds an inline image gallery for an entity's attachments: each image sized
/// to fit the page with its caption underneath. Bytes are pulled from the local
/// `image_blobs` cache, so export works offline; images not cached locally are
/// skipped, and formats the PDF engine can't decode are ignored.
Future<List<pw.Widget>> _imageWidgets(
  AppDatabase db, {
  String? experimentId,
  String? strainId,
  String? cultureId,
  String? updateId,
  String? reportId,
  String? protocolId,
}) async {
  final query = db.select(db.images)
    ..where((t) => experimentId != null
        ? t.experimentId.equals(experimentId)
        : strainId != null
            ? t.strainId.equals(strainId)
            : cultureId != null
                ? t.cultureId.equals(cultureId)
                : updateId != null
                    ? t.updateId.equals(updateId)
                    : reportId != null
                        ? t.reportId.equals(reportId)
                        : t.protocolId.equals(protocolId!))
    ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
  final imgs = await query.get();
  return await _imageWidgetsFromList(db, imgs);
}

/// Renders a list of already-fetched attached images into PDF widgets (blobs
/// pulled from the local cache, annotations flattened). [width]/[height] cap the
/// rendered box — smaller for inline (per-step) images.
Future<List<pw.Widget>> _imageWidgetsFromList(
  AppDatabase db,
  List<AttachedImage> imgs, {
  double width = 460,
  double height = 300,
}) async {
  final widgets = <pw.Widget>[];
  for (final img in imgs) {
    final blob = await (db.select(db.imageBlobs)
          ..where((t) => t.id.equals(img.id)))
        .getSingleOrNull();
    if (blob == null) continue; // not cached locally
    // Flatten any drawn markup onto the image; fall back to the raw bytes.
    final flattened = await renderAnnotatedImagePng(blob.bytes, img.annotations);
    pw.MemoryImage memory;
    try {
      memory = pw.MemoryImage(flattened ?? blob.bytes);
    } catch (_) {
      continue; // unsupported encoding
    }
    widgets.add(pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Image(memory,
              fit: pw.BoxFit.contain, width: width, height: height),
          if (img.caption.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(img.caption,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey800,
                      fontWeight: pw.FontWeight.bold)),
            ),
          if (img.notes.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(img.notes,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
            ),
        ],
      ),
    ));
  }
  return widgets;
}

Future<Uint8List> _build(
  PdfFonts fonts,
  List<pw.Widget> Function(pw.Context) content, {
  PdfPageFormat? pageFormat,
}) {
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
  );
  final exported = _today();
  doc.addPage(pw.MultiPage(
    pageFormat: pageFormat ?? PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(42, 44, 42, 44),
    header: (ctx) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Su Lab',
                style:
                    pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
            pw.Text("MBBE · University of Hawai'i at Mānoa",
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 0.8, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
      ],
    ),
    footer: (ctx) => pw.Column(children: [
      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Exported $exported',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    ]),
    build: content,
  ));
  return doc.save();
}

/// Orders tasks into time order: by due date ascending, undated tasks last.
int _byDue(Task a, Task b) {
  if (a.dueDate == null && b.dueDate == null) return 0;
  if (a.dueDate == null) return 1;
  if (b.dueDate == null) return -1;
  return a.dueDate!.compareTo(b.dueDate!);
}

/// One task rendered with its detail — a bold title, a meta line
/// (status · priority · due date · overdue) and its description — shared by the
/// project and report PDFs.
List<pw.Widget> _taskDetail(Task t, DateTime today) {
  final overdue = t.dueDate != null &&
      t.status != TaskStatus.done &&
      t.dueDate!.toLocal().isBefore(today);
  final meta = [
    _pretty(t.status.name),
    '${_pretty(t.priority.name)} priority',
    t.dueDate != null ? 'due ${_date(t.dueDate)}' : 'no due date',
    if (overdue) 'OVERDUE',
  ].join('  ·  ');
  return [
    pw.SizedBox(height: 7),
    _itemTitle(t.title),
    _subtle(meta),
    if (t.description.isNotEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2),
        child: pw.Text(t.description,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
      ),
  ];
}

/// Project PDF: fields + its experiments + its related tasks (time-ordered,
/// with detail).
Future<Uint8List> buildProjectPdf(
    AppDatabase db, Project p, PdfFonts fonts) async {
  final experiments = await (db.select(db.experiments)
        ..where((t) => t.projectId.equals(p.id)))
      .get();
  final tasks =
      await (db.select(db.tasks)..where((t) => t.projectId.equals(p.id))).get();
  tasks.sort(_byDue);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return _build(fonts, (ctx) => [
        _title(p.title),
        pw.SizedBox(height: 4),
        _subtle(
            'Project  ·  ${_pretty(p.status.name)}  ·  ${_pretty(p.priority.name)} priority'),
        if (p.description.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text(p.description,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
        ],
        pw.SizedBox(height: 14),
        if (p.startDate != null || p.targetDate != null)
          _field('Dates',
              'Start: ${_date(p.startDate)}      Target: ${_date(p.targetDate)}'),
        if (p.tags.isNotEmpty) ...[
          _label('Tags'),
          _chips(p.tags),
        ],
        _sectionTitle('Experiments (${experiments.length})'),
        if (experiments.isEmpty)
          _subtle('None.')
        else
          for (final e in experiments)
            _bullet('${e.title}   —   ${_pretty(e.status.name)}'),
        _sectionTitle('Tasks (${tasks.length})'),
        if (tasks.isEmpty)
          _subtle('None.')
        else
          for (final t in tasks) ..._taskDetail(t, today),
      ]);
}

/// Experiment PDF: fields, linked strains by name, hypothesis, results, links.
/// A labelled, numbered list of steps (used for the methodology).
List<pw.Widget> _numberedSteps(String label, List<String> steps) => [
      _label(label),
      for (var i = 0; i < steps.length; i++)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                  width: 18,
                  child: pw.Text('${i + 1}.',
                      style: const pw.TextStyle(fontSize: 10))),
              pw.Expanded(
                  child: pw.Text(steps[i],
                      style:
                          const pw.TextStyle(fontSize: 10, lineSpacing: 1.5))),
            ],
          ),
        ),
      pw.SizedBox(height: 6),
    ];

Future<Uint8List> buildExperimentPdf(
    AppDatabase db, Experiment e, PdfFonts fonts) async {
  final project = await (db.select(db.projects)
        ..where((t) => t.id.equals(e.projectId)))
      .getSingleOrNull();
  final nameById = {
    for (final s in await db.select(db.strains).get()) s.id: s.name
  };
  final strainNames = [for (final id in e.strainIds) nameById[id] ?? id];
  final images = await _imageWidgets(db, experimentId: e.id);

  // Related tasks (linked to this experiment), in time order.
  final tasks = await (db.select(db.tasks)
        ..where((t) => t.experimentId.equals(e.id)))
      .get();
  tasks.sort(_byDue);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Progress log (newest first) with each entry's images.
  final updates = await (db.select(db.experimentUpdates)
        ..where((t) => t.experimentId.equals(e.id))
        ..orderBy([
          (t) => OrderingTerm(expression: t.happenedAt, mode: OrderingMode.desc)
        ]))
      .get();
  final updateBlocks = <pw.Widget>[];
  for (final u in updates) {
    updateBlocks.add(pw.SizedBox(height: 8));
    updateBlocks.add(_label(_date(u.happenedAt)));
    if (u.note.isNotEmpty) {
      updateBlocks.add(pw.Text(u.note,
          style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)));
    }
    updateBlocks.addAll(await _imageWidgets(db, updateId: u.id));
  }

  return _build(fonts, (ctx) => [
        _title(e.title),
        pw.SizedBox(height: 4),
        _subtle('Experiment  ·  ${_pretty(e.status.name)}'
            '${project != null ? '  ·  Project: ${project.title}' : ''}'),
        pw.SizedBox(height: 14),
        if (e.date != null) _field('Date', _date(e.date)),
        if (e.protocolRef.isNotEmpty) _field('Protocol ref', e.protocolRef),
        if (e.hypothesis.isNotEmpty) _field('Hypothesis', e.hypothesis),
        if (e.methodologySteps.isNotEmpty)
          ..._numberedSteps('Methodology', e.methodologySteps),
        if (e.resultsNotes.isNotEmpty) _field('Results notes', e.resultsNotes),
        if (e.conclusion.isNotEmpty) _field('Conclusion', e.conclusion),
        if (e.furtherPlan.isNotEmpty) _field('Further plan', e.furtherPlan),
        _label('Strains'),
        if (strainNames.isEmpty) _subtle('None.') else _chips(strainNames),
        pw.SizedBox(height: 10),
        if (e.dataLinks.isNotEmpty) ...[
          _label('Data links'),
          for (final l in e.dataLinks)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: pw.Text(l,
                  style:
                      const pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
            ),
        ],
        _sectionTitle('Tasks (${tasks.length})'),
        if (tasks.isEmpty)
          _subtle('None.')
        else
          for (final t in tasks) ..._taskDetail(t, today),
        if (images.isNotEmpty) ...[
          _sectionTitle('Result images (${images.length})'),
          ...images,
        ],
        if (updates.isNotEmpty) ...[
          _sectionTitle('Progress log (${updates.length})'),
          ...updateBlocks,
        ],
      ]);
}

/// Strain PDF: fields plus its attached images.
Future<Uint8List> buildStrainPdf(
    AppDatabase db, Strain s, PdfFonts fonts) async {
  final images = await _imageWidgets(db, strainId: s.id);
  return _build(fonts, (ctx) => [
        _title(s.name),
        pw.SizedBox(height: 4),
        _subtle('Strain'
            '${s.serialNumber.isNotEmpty ? '  ·  ${s.serialNumber}' : ''}'
            '${s.hostOrganism.isNotEmpty ? '  ·  ${s.hostOrganism}' : ''}'),
        pw.SizedBox(height: 14),
        if (s.serialNumber.isNotEmpty) _field('Serial number', s.serialNumber),
        if (s.genotype.isNotEmpty) _field('Genotype', s.genotype),
        if (s.plasmid.isNotEmpty) _field('Plasmid', s.plasmid),
        if (s.constructNotes.isNotEmpty)
          _field('Construct notes', s.constructNotes),
        if (s.selectionMarkers.isNotEmpty) ...[
          _label('Selection markers'),
          _chips(s.selectionMarkers),
          pw.SizedBox(height: 6),
        ],
        if (s.freezerLocation.isNotEmpty)
          _field('Freezer location', s.freezerLocation),
        if (s.notes.isNotEmpty) _field('Notes', s.notes),
        if (images.isNotEmpty) ...[
          _sectionTitle('Images (${images.length})'),
          ...images,
        ],
      ]);
}

/// Strains as one landscape table (one row per strain) — the multi-select export.
Future<Uint8List> buildStrainsTablePdf(
    AppDatabase db, List<Strain> strains, PdfFonts fonts) async {
  return _build(
    fonts,
    (ctx) => [
      _title('Strains (${strains.length})'),
      pw.SizedBox(height: 10),
      if (strains.isEmpty)
        _subtle('None selected.')
      else
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          headers: const [
            '#', 'Name', 'Serial', 'Host', 'Genotype', 'Plasmid', 'Markers',
            'Freezer'
          ],
          data: [
            for (var i = 0; i < strains.length; i++)
              [
                '${i + 1}',
                strains[i].name,
                strains[i].serialNumber,
                strains[i].hostOrganism,
                strains[i].genotype,
                strains[i].plasmid,
                strains[i].selectionMarkers.join(', '),
                strains[i].freezerLocation,
              ],
          ],
        ),
    ],
    pageFormat: PdfPageFormat.a4.landscape,
  );
}

/// Culture PDF: details, split lineage, selection, the operations log, images.
Future<Uint8List> buildCulturePdf(
    AppDatabase db, Culture c, PdfFonts fonts) async {
  final strain = c.strainId == null
      ? null
      : await (db.select(db.strains)..where((t) => t.id.equals(c.strainId!)))
          .getSingleOrNull();
  final markers = c.selectionMarkers.isNotEmpty
      ? c.selectionMarkers
      : (strain?.selectionMarkers ?? const <String>[]);
  final parent = c.parentCultureId == null
      ? null
      : await (db.select(db.cultures)
            ..where((t) => t.id.equals(c.parentCultureId!)))
          .getSingleOrNull();
  final events = await (db.select(db.cultureEvents)
        ..where((t) => t.cultureId.equals(c.id))
        ..orderBy([
          (t) => OrderingTerm(expression: t.happenedAt, mode: OrderingMode.desc)
        ]))
      .get();
  final images = await _imageWidgets(db, cultureId: c.id);

  String dt(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${_date(l)}  ${two(l.hour)}:${two(l.minute)}';
  }

  return _build(fonts, (ctx) => [
        _title(c.name.isEmpty ? 'Culture' : c.name),
        pw.SizedBox(height: 4),
        _subtle('Culture  ·  ${_pretty(c.status)}'
            '${strain != null ? '  ·  Strain: ${strain.name}' : ''}'),
        pw.SizedBox(height: 14),
        if (c.medium.isNotEmpty) _field('Medium', c.medium),
        if (c.vessel.isNotEmpty) _field('Vessel', c.vessel),
        if (c.inoculumAmount.isNotEmpty)
          _field('Inoculation amount', c.inoculumAmount),
        _field(c.parentCultureId != null ? 'Inoculated (split)' : 'Started',
            dt(c.startedDate)),
        if (c.endedDate != null) _field('Ended', dt(c.endedDate)),
        if (c.parentCultureId != null)
          _field(
              'Split from',
              '${parent?.name ?? 'mother culture'}  ·  '
                  'mother inoculated ${dt(c.parentInoculatedAt)}  ·  '
                  'split ${dt(c.startedDate)}'),
        if (markers.isNotEmpty) ...[
          _label('Selection markers'),
          _chips(markers),
          pw.SizedBox(height: 6),
        ],
        if (c.notes.isNotEmpty) _field('Notes', c.notes),
        if (events.isNotEmpty) ...[
          _sectionTitle('Operations log (${events.length})'),
          for (final e in events) ...[
            _label('${cultureOpLabel(e.type)}  ·  ${dt(e.happenedAt)}'),
            _bullet(cultureOpSummary(
                type: e.type,
                agent: e.agent,
                amount: e.amount,
                note: e.note)),
          ],
        ],
        if (images.isNotEmpty) ...[
          _sectionTitle('Images (${images.length})'),
          ...images,
        ],
      ]);
}

/// A small (≈5 cm × 2 cm) printable culture label: the strain serial number
/// (prominent) first, then strain name, time inoculated, selection marker and
/// purpose — in that order.
Future<Uint8List> buildCultureLabelPdf(
    AppDatabase db, Culture c, PdfFonts fonts) async {
  final strain = c.strainId == null
      ? null
      : await (db.select(db.strains)..where((t) => t.id.equals(c.strainId!)))
          .getSingleOrNull();
  final markers = c.selectionMarkers.isNotEmpty
      ? c.selectionMarkers
      : (strain?.selectionMarkers ?? const <String>[]);

  String dt(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${_date(l)} ${two(l.hour)}:${two(l.minute)}';
  }

  final serial = (strain?.serialNumber ?? '').trim();
  final strainName = (strain?.name ?? '').trim();
  final theme = pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold);

  pw.Widget row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.RichText(
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 7, lineSpacing: 1),
            children: [
              pw.TextSpan(
                  text: '$label: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TextSpan(text: value.trim().isEmpty ? '—' : value),
            ],
          ),
        ),
      );

  final doc = pw.Document();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat(5 * PdfPageFormat.cm, 2 * PdfPageFormat.cm,
        marginAll: 0.15 * PdfPageFormat.cm),
    theme: theme,
    build: (ctx) => pw.FittedBox(
      fit: pw.BoxFit.scaleDown,
      alignment: pw.Alignment.topLeft,
      child: pw.SizedBox(
        width: 4.7 * PdfPageFormat.cm,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // Serial number of the strain — first and most prominent.
            pw.Text(serial.isEmpty ? '(no serial)' : serial,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            row('Strain', strainName),
            row('Inoculated', dt(c.startedDate)),
            row('Selection', markers.join(', ')),
            row('Purpose', c.purpose),
          ],
        ),
      ),
    ),
  ));
  return doc.save();
}

/// Cultures as one landscape table (one row per culture) — the multi-select
/// export.
Future<Uint8List> buildCulturesTablePdf(
    AppDatabase db, List<Culture> cultures, PdfFonts fonts) async {
  final strainNameById = {
    for (final s in await db.select(db.strains).get()) s.id: s.name
  };
  String dt(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${_date(l)} ${two(l.hour)}:${two(l.minute)}';
  }

  return _build(
    fonts,
    (ctx) => [
      _title('Cultures (${cultures.length})'),
      pw.SizedBox(height: 10),
      if (cultures.isEmpty)
        _subtle('None selected.')
      else
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          headers: const [
            '#', 'Name', 'Strain', 'Status', 'Medium', 'Vessel', 'Started',
            'Ended'
          ],
          data: [
            for (var i = 0; i < cultures.length; i++)
              [
                '${i + 1}',
                cultures[i].name.isEmpty ? '(unnamed)' : cultures[i].name,
                cultures[i].strainId == null
                    ? '—'
                    : (strainNameById[cultures[i].strainId] ?? '—'),
                _pretty(cultures[i].status),
                cultures[i].medium,
                cultures[i].vessel,
                dt(cultures[i].startedDate),
                dt(cultures[i].endedDate),
              ],
          ],
        ),
    ],
    pageFormat: PdfPageFormat.a4.landscape,
  );
}

/// Reagent / buffer PDF: fields, plus the recipe (mainly for buffers).
Future<Uint8List> buildReagentPdf(
    AppDatabase db, Reagent r, PdfFonts fonts) async {
  final isBuffer = r.kind == 'buffer';
  return _build(fonts, (ctx) => [
        _title(r.name),
        pw.SizedBox(height: 4),
        _subtle('${isBuffer ? 'Buffer' : 'Reagent'}'
            '${r.supplier.isNotEmpty ? '  ·  ${r.supplier}' : ''}'),
        pw.SizedBox(height: 14),
        if (r.recipe.isNotEmpty) _field('Recipe', r.recipe),
        if (r.supplier.isNotEmpty) _field('Supplier', r.supplier),
        if (r.catalogNo.isNotEmpty) _field('Catalog no.', r.catalogNo),
        if (r.lot.isNotEmpty) _field('Lot', r.lot),
        if (r.location.isNotEmpty) _field('Location', r.location),
        if (r.quantity.isNotEmpty) _field('Quantity', r.quantity),
        if (r.expiryDate != null) _field('Expiry', _date(r.expiryDate)),
        if (r.notes.isNotEmpty) _field('Notes', r.notes),
      ]);
}

/// Reagents / buffers as one landscape table — the multi-select export. Carries
/// a Recipe column so buffer recipes are captured alongside reagent stock.
Future<Uint8List> buildReagentsTablePdf(
    AppDatabase db, List<Reagent> reagents, PdfFonts fonts) async {
  return _build(
    fonts,
    (ctx) => [
      _title('Reagents & buffers (${reagents.length})'),
      pw.SizedBox(height: 10),
      if (reagents.isEmpty)
        _subtle('None selected.')
      else
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          columnWidths: {
            0: const pw.FixedColumnWidth(16), // #
            1: const pw.FlexColumnWidth(1.7), // Name
            2: const pw.FlexColumnWidth(0.9), // Kind
            3: const pw.FlexColumnWidth(1.2), // Supplier
            4: const pw.FlexColumnWidth(1.1), // Catalog
            5: const pw.FlexColumnWidth(0.9), // Lot
            6: const pw.FlexColumnWidth(1.0), // Location
            7: const pw.FlexColumnWidth(0.8), // Qty
            8: const pw.FlexColumnWidth(1.0), // Expiry
            9: const pw.FlexColumnWidth(2.6), // Recipe
          },
          headers: const [
            '#', 'Name', 'Kind', 'Supplier', 'Catalog', 'Lot', 'Location',
            'Qty', 'Expiry', 'Recipe'
          ],
          data: [
            for (var i = 0; i < reagents.length; i++)
              [
                '${i + 1}',
                reagents[i].name,
                reagents[i].kind == 'buffer' ? 'Buffer' : 'Reagent',
                reagents[i].supplier,
                reagents[i].catalogNo,
                reagents[i].lot,
                reagents[i].location,
                reagents[i].quantity,
                _date(reagents[i].expiryDate),
                reagents[i].recipe,
              ],
          ],
        ),
    ],
    pageFormat: PdfPageFormat.a4.landscape,
  );
}

/// Protocol PDF: the procedure as numbered steps, plus summary, materials,
/// notes and any attached (annotated) images.
Future<Uint8List> buildProtocolPdf(
    AppDatabase db, Protocol p, PdfFonts fonts) async {
  // Fetch every protocol image, then split into per-step and general buckets by
  // the stable step id stored on each image.
  final allImgs = await (db.select(db.images)
        ..where((t) => t.protocolId.equals(p.id))
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
      .get();
  final stepIdSet = p.stepIds.toSet();
  final byStep = <String, List<AttachedImage>>{};
  final general = <AttachedImage>[];
  for (final im in allImgs) {
    final sid = im.stepId;
    if (sid != null && stepIdSet.contains(sid)) {
      byStep.putIfAbsent(sid, () => []).add(im);
    } else {
      general.add(im); // unassigned, or a step that no longer exists
    }
  }
  // Pre-build the image widgets (the content builder must be synchronous).
  final stepImgs = <String, List<pw.Widget>>{};
  for (final e in byStep.entries) {
    stepImgs[e.key] =
        await _imageWidgetsFromList(db, e.value, width: 400, height: 260);
  }
  final generalImgs = await _imageWidgetsFromList(db, general);

  return _build(fonts, (ctx) => [
        _title(p.name),
        pw.SizedBox(height: 4),
        _subtle('Protocol${p.category.isNotEmpty ? '  ·  ${p.category}' : ''}'),
        pw.SizedBox(height: 14),
        if (p.summary.isNotEmpty) _field('Summary', p.summary),
        if (p.materials.isNotEmpty) _field('Materials', p.materials),
        if (p.steps.isNotEmpty) ...[
          _label('Steps'),
          for (var i = 0; i < p.steps.length; i++) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 18,
                      child: pw.Text('${i + 1}.',
                          style: const pw.TextStyle(fontSize: 10))),
                  pw.Expanded(
                      child: pw.Text(p.steps[i],
                          style: const pw.TextStyle(
                              fontSize: 10, lineSpacing: 1.5))),
                ],
              ),
            ),
            // The images attached to this step, indented beneath it.
            if (i < p.stepIds.length && stepImgs[p.stepIds[i]] != null)
              pw.Padding(
                padding:
                    const pw.EdgeInsets.only(left: 18, top: 4, bottom: 6),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: stepImgs[p.stepIds[i]]!),
              ),
          ],
          pw.SizedBox(height: 6),
        ],
        if (p.notes.isNotEmpty) _field('Notes', p.notes),
        if (generalImgs.isNotEmpty) ...[
          _sectionTitle('Images (${generalImgs.length})'),
          ...generalImgs,
        ],
      ]);
}

/// Protocols as one landscape table — the multi-select export. Each protocol's
/// steps are joined into one numbered cell.
Future<Uint8List> buildProtocolsTablePdf(
    AppDatabase db, List<Protocol> protocols, PdfFonts fonts) async {
  String steps(Protocol p) {
    if (p.steps.isEmpty) return '—';
    return [for (var i = 0; i < p.steps.length; i++) '${i + 1}. ${p.steps[i]}']
        .join('\n');
  }

  return _build(
    fonts,
    (ctx) => [
      _title('Protocols (${protocols.length})'),
      pw.SizedBox(height: 10),
      if (protocols.isEmpty)
        _subtle('None selected.')
      else
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          columnWidths: {
            0: const pw.FixedColumnWidth(16), // #
            1: const pw.FlexColumnWidth(1.6), // Name
            2: const pw.FlexColumnWidth(1.0), // Category
            3: const pw.FlexColumnWidth(2.0), // Summary
            4: const pw.FlexColumnWidth(3.4), // Steps
          },
          headers: const ['#', 'Name', 'Category', 'Summary', 'Steps'],
          data: [
            for (var i = 0; i < protocols.length; i++)
              [
                '${i + 1}',
                protocols[i].name,
                protocols[i].category,
                protocols[i].summary,
                steps(protocols[i]),
              ],
          ],
        ),
    ],
    pageFormat: PdfPageFormat.a4.landscape,
  );
}

/// Manuscript PDF: fields and current status.
Future<Uint8List> buildManuscriptPdf(
    AppDatabase db, Manuscript m, PdfFonts fonts) async {
  final project = await (db.select(db.projects)
        ..where((t) => t.id.equals(m.projectId)))
      .getSingleOrNull();

  return _build(fonts, (ctx) => [
        _title(m.title),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text('Status:  ${_pretty(m.status.name)}',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 16),
        if (project != null) _field('Project', project.title),
        if (m.targetJournal.isNotEmpty)
          _field('Target journal', m.targetJournal),
        if (m.submissionId.isNotEmpty) _field('Submission ID', m.submissionId),
        if (m.submittedDate != null) _field('Submitted', _date(m.submittedDate)),
        if (m.notes.isNotEmpty) _field('Notes', m.notes),
      ]);
}

/// Clone-construction (Gibson assembly) PDF: the assembled-vector diagram and one
/// "assembly" table — a row for the backbone and each fragment carrying the role,
/// the used strain's serial number + freezer location + selection markers (kept
/// in the strain's notes), the fragment name, and the primers (fragments) or
/// restriction enzymes (backbone) used.
Future<Uint8List> buildClonePdf(
    AppDatabase db, CloneConstruction c, PdfFonts fonts) async {
  final strainsById = {
    for (final s in await db.select(db.strains).get()) s.id: s
  };
  final primerNameById = {
    for (final p in await db.select(db.primers).get()) p.id: p.name
  };
  final vectorPng = await renderCloneVectorPng(c, primerNames: primerNameById);

  String primerName(String id) =>
      id.isEmpty ? '—' : (primerNameById[id] ?? '(missing)');
  String serialOf(String id) {
    final s = strainsById[id];
    return (s != null && s.serialNumber.isNotEmpty) ? s.serialNumber : '—';
  }
  String locationOf(String id) {
    final s = strainsById[id];
    return (s != null && s.freezerLocation.isNotEmpty) ? s.freezerLocation : '—';
  }
  // Selection markers are recorded in the strain's notes field, per the lab.
  String markersOf(String id) {
    final s = strainsById[id];
    return (s != null && s.notes.isNotEmpty) ? s.notes : '—';
  }
  String primersOf(int i) {
    final fwd = primerName(c.fragments[i].fwdPrimerId);
    final rev = primerName(c.fragments[i].revPrimerId);
    final parts = <String>[
      if (fwd != '—') 'Fwd: $fwd',
      if (rev != '—') 'Rev: $rev',
    ];
    return parts.isEmpty ? '—' : parts.join('\n');
  }

  // One combined "assembly" table: the backbone row, then a row per fragment,
  // each joined to its strain's serial / location / selection markers (notes) and
  // showing the enzymes (backbone) or primers (fragments) used.
  final assemblyRows = <List<String>>[
    [
      'Backbone',
      serialOf(c.backboneStrainId),
      c.backboneName.isEmpty ? '—' : c.backboneName,
      c.enzymes.isEmpty ? '—' : c.enzymes,
      locationOf(c.backboneStrainId),
      markersOf(c.backboneStrainId),
    ],
    for (var i = 0; i < c.fragments.length; i++)
      [
        'Fragment ${i + 1}',
        serialOf(c.fragments[i].templateStrainId),
        c.fragments[i].name.isEmpty
            ? 'Fragment ${i + 1}'
            : c.fragments[i].name,
        primersOf(i),
        locationOf(c.fragments[i].templateStrainId),
        markersOf(c.fragments[i].templateStrainId),
      ],
  ];

  return _build(fonts, (ctx) => [
        _title(c.name.isEmpty ? 'Clone construction' : c.name),
        pw.SizedBox(height: 4),
        _subtle('Gibson assembly  ·  ${c.fragments.length} fragment(s)'),
        if (c.notes.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(c.notes,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
        ],
        if (vectorPng != null) ...[
          _sectionTitle('Assembled vector'),
          pw.Center(
              child: pw.Image(pw.MemoryImage(vectorPng),
                  width: 340, height: 340)),
        ],
        _sectionTitle('Assembly'),
        pw.TableHelper.fromTextArray(
          headerStyle:
              pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignment: pw.Alignment.centerLeft,
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.1), // Role
            1: const pw.FlexColumnWidth(1.2), // Strain serial
            2: const pw.FlexColumnWidth(1.8), // Fragment name
            3: const pw.FlexColumnWidth(1.8), // Primer / Enzyme
            4: const pw.FlexColumnWidth(1.3), // Strain location
            5: const pw.FlexColumnWidth(2.4), // Selection markers (notes)
          },
          headers: const [
            'Role',
            'Strain serial',
            'Fragment name',
            'Primer / Enzyme',
            'Strain location',
            'Selection markers',
          ],
          data: assemblyRows,
        ),
      ]);
}

String _countLine<T>(Iterable<T> items, String Function(T) key) {
  final m = <String, int>{};
  for (final i in items) {
    m.update(key(i), (v) => v + 1, ifAbsent: () => 1);
  }
  return m.entries.map((e) => '${e.value} ${_pretty(e.key)}').join(',  ');
}

/// Progress-report PDF: the saved header + written summary, followed by every
/// section of the current workspace gathered live (projects, experiments with
/// embedded images, tasks/deadlines, active cultures, manuscripts and
/// inventory). When the report has a reporting period, the time-based sections
/// (experiments, cultures) are narrowed to it; dated items outside the window
/// are dropped while undated items are kept.
Future<Uint8List> buildReportPdf(
    AppDatabase db, Report r, PdfFonts fonts) async {
  final wsId = await currentWorkspaceId(db);
  List<T> scope<T>(List<T> rows, String Function(T) wsOf) =>
      wsId == null ? rows : rows.where((x) => wsOf(x) == wsId).toList();

  var projects = scope(await db.select(db.projects).get(), (p) => p.workspaceId);
  var experiments =
      scope(await db.select(db.experiments).get(), (e) => e.workspaceId);
  var tasks = scope(await db.select(db.tasks).get(), (t) => t.workspaceId);
  final cultures = scope(await db.select(db.cultures).get(), (c) => c.workspaceId);
  var manuscripts =
      scope(await db.select(db.manuscripts).get(), (m) => m.workspaceId);
  final strains = scope(await db.select(db.strains).get(), (s) => s.workspaceId);
  final reagents = scope(await db.select(db.reagents).get(), (x) => x.workspaceId);
  final primers = scope(await db.select(db.primers).get(), (p) => p.workspaceId);

  // Apply the report's project / experiment selection (empty = everything).
  // Selecting a project includes all its experiments; additionally selecting
  // specific experiments narrows that project to just those.
  final selProj = r.projectIds.toSet();
  final selExp = r.experimentIds.toSet();
  final hasSelection = selProj.isNotEmpty || selExp.isNotEmpty;
  if (hasSelection) {
    final projectsWithExpSel = {
      for (final e in experiments)
        if (selExp.contains(e.id)) e.projectId
    };
    final included = <String>{
      ...selProj,
      ...projectsWithExpSel,
    };
    projects = projects.where((p) => included.contains(p.id)).toList();
    experiments = experiments
        .where((e) =>
            selExp.contains(e.id) ||
            (selProj.contains(e.projectId) &&
                !projectsWithExpSel.contains(e.projectId)))
        .toList();
    final keptExpIds = experiments.map((e) => e.id).toSet();
    tasks = tasks
        .where((t) =>
            (t.projectId != null && included.contains(t.projectId)) ||
            (t.experimentId != null && keptExpIds.contains(t.experimentId)))
        .toList();
    manuscripts =
        manuscripts.where((m) => included.contains(m.projectId)).toList();
  }

  final ws = wsId == null
      ? null
      : await (db.select(db.workspaces)..where((t) => t.id.equals(wsId)))
          .getSingleOrNull();

  final ps = r.periodStart, pe = r.periodEnd;
  bool inPeriod(DateTime? d) {
    if (ps == null && pe == null) return true;
    if (d == null) return true; // undated items aren't excluded by a period
    final l = d.toLocal();
    final dd = DateTime(l.year, l.month, l.day);
    if (ps != null && dd.isBefore(DateTime(ps.year, ps.month, ps.day))) {
      return false;
    }
    if (pe != null && dd.isAfter(DateTime(pe.year, pe.month, pe.day))) {
      return false;
    }
    return true;
  }

  // Relationship maps.
  final expsByProject = <String, List<Experiment>>{};
  for (final e in experiments) {
    expsByProject.putIfAbsent(e.projectId, () => []).add(e);
  }
  final projectTitleById = {for (final p in projects) p.id: p.title};
  final strainNameById = {for (final s in strains) s.id: s.name};

  // Inventory is included only when referenced or mentioned — not the entire
  // workspace. "Referenced" = a strain used by an included experiment (strainIds)
  // or a culture (strainId). "Mentioned" = the item's name appears in the
  // report's narrative text (summary, project / experiment / culture / task /
  // manuscript fields). Reagents and primers have no structural link in a report,
  // so they're included purely on a name mention.
  final referencedStrainIds = <String>{
    for (final e in experiments) ...e.strainIds,
    for (final c in cultures)
      if (c.strainId != null && c.strainId!.isNotEmpty) c.strainId!,
  };
  final mentionCorpus = [
    r.summary,
    r.title,
    for (final p in projects) '${p.title}\n${p.description}',
    for (final e in experiments)
      '${e.title}\n${e.hypothesis}\n${e.methodologySteps.join('\n')}\n'
          '${e.resultsNotes}\n${e.conclusion}\n${e.furtherPlan}',
    for (final c in cultures) '${c.name}\n${c.medium}\n${c.notes}',
    for (final t in tasks) '${t.title}\n${t.description}',
    for (final m in manuscripts) '${m.title}\n${m.notes}',
  ].join('\n').toLowerCase();
  bool mentioned(String name) {
    final n = name.trim().toLowerCase();
    return n.length >= 2 && mentionCorpus.contains(n);
  }

  final shownStrains = strains
      .where((s) => referencedStrainIds.contains(s.id) || mentioned(s.name))
      .toList();
  final shownReagents = reagents.where((x) => mentioned(x.name)).toList();
  final shownPrimers = primers.where((p) => mentioned(p.name)).toList();

  // Pre-fetch images (the content builder must be synchronous).
  final expsInPeriod = experiments.where((e) => inPeriod(e.date)).toList();
  final expImages = <String, List<pw.Widget>>{};
  for (final e in expsInPeriod) {
    final imgs = await _imageWidgets(db, experimentId: e.id);
    if (imgs.isNotEmpty) expImages[e.id] = imgs;
  }
  final activeCultures = cultures
      .where((c) => c.status == 'active' && inPeriod(c.startedDate))
      .toList();
  final cultureImages = <String, List<pw.Widget>>{};
  for (final c in activeCultures) {
    final imgs = await _imageWidgets(db, cultureId: c.id);
    if (imgs.isNotEmpty) cultureImages[c.id] = imgs;
  }
  final strainImages = <String, List<pw.Widget>>{};
  for (final s in shownStrains) {
    final imgs = await _imageWidgets(db, strainId: s.id);
    if (imgs.isNotEmpty) strainImages[s.id] = imgs;
  }
  // The report's own inserted figures.
  final reportImages = await _imageWidgets(db, reportId: r.id);

  // Task aggregates.
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final openTasks = tasks.where((t) => t.status != TaskStatus.done).toList()
    ..sort(_byDue);
  bool isOverdue(Task t) =>
      t.dueDate != null && t.dueDate!.toLocal().isBefore(today);
  final completed = tasks.where((t) => t.status == TaskStatus.done).length;

  final periodLabel = (ps == null && pe == null)
      ? 'All activity'
      : '${_date(ps)}  –  ${_date(pe)}';

  return _build(fonts, (ctx) => [
        _title(r.title),
        pw.SizedBox(height: 8),
        _field('To', r.recipient.isEmpty ? '—' : r.recipient),
        _field('From', r.author.isEmpty ? '—' : r.author),
        _field('Reporting period', periodLabel),
        if (ws != null) _field('Workspace', ws.name),
        if (hasSelection)
          _field('Scope',
              '${projects.length} project(s), ${experiments.length} experiment(s) selected'),

        _sectionTitle('Summary'),
        if (r.summary.trim().isEmpty)
          _subtle('—')
        else
          pw.Text(r.summary,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),

        _sectionTitle('At a glance'),
        _bullet('Projects: ${projects.length}'
            '${projects.isEmpty ? '' : '  (${_countLine(projects, (p) => p.status.name)})'}'),
        _bullet('Experiments: ${experiments.length}'
            '${experiments.isEmpty ? '' : '  (${_countLine(experiments, (e) => e.status.name)})'}'),
        _bullet('Open tasks: ${openTasks.length}'
            '   ·   Overdue: ${openTasks.where(isOverdue).length}'
            '   ·   Completed: $completed'),
        _bullet('Active cultures: ${cultures.where((c) => c.status == 'active').length}'
            '   ·   Manuscripts: ${manuscripts.length}'),
        _bullet('Inventory referenced — Strains: ${shownStrains.length}'
            '   ·   Reagents: ${shownReagents.length}'
            '   ·   Primers: ${shownPrimers.length}'),

        _sectionTitle('Projects (${projects.length})'),
        if (projects.isEmpty)
          _subtle('None.')
        else
          for (final p in projects) ...[
            pw.SizedBox(height: 8),
            _itemTitle(p.title),
            _subtle(
                '${_pretty(p.status.name)}  ·  ${_pretty(p.priority.name)} priority'),
            if (p.description.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2),
                child: pw.Text(p.description,
                    style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
              ),
            for (final e in expsByProject[p.id] ?? const <Experiment>[])
              _bullet('${e.title}   —   ${_pretty(e.status.name)}'),
          ],

        // The report's own inserted figures sit with the project content rather
        // than ahead of it.
        if (reportImages.isNotEmpty) ...[
          _sectionTitle('Figures (${reportImages.length})'),
          ...reportImages,
        ],

        _sectionTitle('Experiments in period (${expsInPeriod.length})'),
        if (expsInPeriod.isEmpty)
          _subtle('None.')
        else
          for (final e in expsInPeriod) ...[
            pw.SizedBox(height: 10),
            _itemTitle(e.title),
            _subtle('${_pretty(e.status.name)}'
                '${e.date != null ? '  ·  ${_date(e.date)}' : ''}'
                '${projectTitleById[e.projectId] != null ? '  ·  ${projectTitleById[e.projectId]}' : ''}'),
            if (e.hypothesis.isNotEmpty) _field('Hypothesis', e.hypothesis),
            if (e.methodologySteps.isNotEmpty)
              ..._numberedSteps('Methodology', e.methodologySteps),
            if (e.resultsNotes.isNotEmpty) _field('Results', e.resultsNotes),
            if (e.conclusion.isNotEmpty) _field('Conclusion', e.conclusion),
            if (e.furtherPlan.isNotEmpty) _field('Further plan', e.furtherPlan),
            if (e.strainIds.isNotEmpty) ...[
              _label('Strains'),
              _chips([for (final id in e.strainIds) strainNameById[id] ?? id]),
              pw.SizedBox(height: 6),
            ],
            ...?expImages[e.id],
          ],

        _sectionTitle('Open tasks & deadlines (${openTasks.length})'),
        if (openTasks.isEmpty)
          _subtle('No open tasks.')
        else
          for (final t in openTasks) ..._taskDetail(t, today),
        if (completed > 0) _subtle('+ $completed completed task(s).'),

        _sectionTitle('Active cultures (${activeCultures.length})'),
        if (activeCultures.isEmpty)
          _subtle('None.')
        else
          for (final c in activeCultures) ...[
            _bullet('${c.name.isEmpty ? '(unnamed)' : c.name}'
                '${c.strainId != null && strainNameById[c.strainId] != null ? '   —   ${strainNameById[c.strainId]}' : ''}'
                '${c.medium.isNotEmpty ? '  ·  ${c.medium}' : ''}'
                '   (started ${_date(c.startedDate)})'),
            ...?cultureImages[c.id],
          ],

        _sectionTitle('Manuscripts (${manuscripts.length})'),
        if (manuscripts.isEmpty)
          _subtle('None.')
        else
          for (final m in manuscripts)
            _bullet('${m.title}   —   ${_pretty(m.status.name)}'
                '${m.targetJournal.isNotEmpty ? '  ·  ${m.targetJournal}' : ''}'),

        _sectionTitle('Inventory referenced'),
        _subtle('Only strains, reagents and primers referenced or mentioned in '
            'this report are listed.'),
        pw.SizedBox(height: 6),
        _label('Strains (${shownStrains.length})'),
        if (shownStrains.isEmpty)
          _subtle('None referenced.')
        else
          _chips([for (final s in shownStrains) s.name]),
        // Referenced strains that have attached images, shown with their pictures.
        for (final s
            in shownStrains.where((s) => strainImages.containsKey(s.id))) ...[
          pw.SizedBox(height: 8),
          _label(s.name),
          ...strainImages[s.id]!,
        ],
        pw.SizedBox(height: 10),
        _label('Reagents (${shownReagents.length})'),
        if (shownReagents.isEmpty)
          _subtle('None referenced.')
        else
          _chips([for (final x in shownReagents) x.name]),
        pw.SizedBox(height: 10),
        _label('Primers (${shownPrimers.length})'),
        if (shownPrimers.isEmpty)
          _subtle('None referenced.')
        else
          _chips([for (final p in shownPrimers) p.name]),
      ]);
}

const _scheduleKindColor = <ScheduleKind, PdfColor>{
  ScheduleKind.task: PdfColor.fromInt(0xFF1E88E5),
  ScheduleKind.experiment: PdfColor.fromInt(0xFFC96442),
  ScheduleKind.projectStart: PdfColor.fromInt(0xFF43A047),
  ScheduleKind.projectTarget: PdfColor.fromInt(0xFFFB8C00),
  ScheduleKind.manuscript: PdfColor.fromInt(0xFF8E24AA),
  ScheduleKind.culture: PdfColor.fromInt(0xFF00897B),
  ScheduleKind.reagentExpiry: PdfColor.fromInt(0xFFE53935),
  ScheduleKind.birthday: PdfColor.fromInt(0xFFD81B60),
  ScheduleKind.personal: PdfColor.fromInt(0xFF5E35B1),
  ScheduleKind.holiday: PdfColor.fromInt(0xFF2E7D32),
};

String _clip(String s, int n) => s.length > n ? '${s.substring(0, n - 1)}…' : s;

/// Schedule PDF for one month: a calendar grid plus a date-grouped agenda. When
/// [projectIds]/[experimentIds] are given the schedule is narrowed to those
/// projects + experiments, and a "Project & experiment details" section is
/// appended (status, dates, hypothesis, results, strains, images). Empty
/// selection = the whole workspace, calendar only.
///
/// Non-academic events are chosen independently of that academic scope:
/// [customEventIds] selects which personal events to overlay (null = all,
/// `[]` = none), and [includeHolidays] toggles the holiday calendar.
Future<Uint8List> buildSchedulePdf(
  AppDatabase db,
  DateTime month,
  PdfFonts fonts, {
  List<String> projectIds = const [],
  List<String> experimentIds = const [],
  List<String>? customEventIds,
  bool includeHolidays = true,
}) async {
  final wsId = await currentWorkspaceId(db);
  List<T> scope<T>(List<T> rows, String Function(T) wsOf) =>
      wsId == null ? rows : rows.where((x) => wsOf(x) == wsId).toList();

  var projects = scope(await db.select(db.projects).get(), (p) => p.workspaceId);
  var experiments =
      scope(await db.select(db.experiments).get(), (e) => e.workspaceId);
  var tasks = scope(await db.select(db.tasks).get(), (t) => t.workspaceId);
  var manuscripts =
      scope(await db.select(db.manuscripts).get(), (m) => m.workspaceId);
  var cultures = scope(await db.select(db.cultures).get(), (c) => c.workspaceId);
  var reagents = scope(await db.select(db.reagents).get(), (r) => r.workspaceId);
  final strainNameById = {
    for (final s in await db.select(db.strains).get()) s.id: s.name
  };

  // Selection (same semantics as the report scope): a chosen project includes
  // its experiments; chosen experiments narrow that project to just those.
  final selProj = projectIds.toSet();
  final selExp = experimentIds.toSet();
  final hasSelection = selProj.isNotEmpty || selExp.isNotEmpty;
  if (hasSelection) {
    final projectsWithExpSel = {
      for (final e in experiments)
        if (selExp.contains(e.id)) e.projectId
    };
    final included = {...selProj, ...projectsWithExpSel};
    projects = projects.where((p) => included.contains(p.id)).toList();
    experiments = experiments
        .where((e) =>
            selExp.contains(e.id) ||
            (selProj.contains(e.projectId) &&
                !projectsWithExpSel.contains(e.projectId)))
        .toList();
    final keptExpIds = experiments.map((e) => e.id).toSet();
    tasks = tasks
        .where((t) =>
            (t.projectId != null && included.contains(t.projectId)) ||
            (t.experimentId != null && keptExpIds.contains(t.experimentId)))
        .toList();
    manuscripts =
        manuscripts.where((m) => included.contains(m.projectId)).toList();
    // Cultures/reagents aren't project-scoped — drop them from a focused export.
    cultures = const [];
    reagents = const [];
  }

  // Personal events + holidays, chosen by the caller independently of the
  // academic project/experiment scope above.
  final years = [month.year - 1, month.year, month.year + 1];
  var customEvents =
      scope(await db.select(db.customEvents).get(), (c) => c.workspaceId);
  if (customEventIds != null) {
    final keep = customEventIds.toSet();
    customEvents = customEvents.where((c) => keep.contains(c.id)).toList();
  }
  final region = includeHolidays
      ? (await SettingsRepository(db).get()).holidayRegion
      : 'none';

  final all = [
    ...buildSchedule(
      tasks: tasks,
      experiments: experiments,
      projects: projects,
      manuscripts: manuscripts,
      cultures: cultures,
      reagents: reagents,
    ),
    ...customEventOccurrences(customEvents, years),
    ...holidayOccurrences(years, region),
  ];

  // Detail section (selection only). Pre-fetch experiment images (async).
  final detail = <pw.Widget>[];
  if (hasSelection) {
    final expByProject = <String, List<Experiment>>{};
    for (final e in experiments) {
      (expByProject[e.projectId] ??= []).add(e);
    }
    for (final p in projects) {
      detail
        ..add(pw.SizedBox(height: 8))
        ..add(_itemTitle(p.title))
        ..add(_subtle('Project  ·  ${_pretty(p.status.name)}  ·  '
            '${_pretty(p.priority.name)} priority'));
      if (p.description.isNotEmpty) {
        detail.add(pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(p.description,
                style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5))));
      }
      if (p.startDate != null || p.targetDate != null) {
        detail.add(_field('Dates',
            'Start: ${_date(p.startDate)}      Target: ${_date(p.targetDate)}'));
      }
      if (p.tags.isNotEmpty) {
        detail
          ..add(_label('Tags'))
          ..add(_chips(p.tags));
      }
      final exps = expByProject[p.id] ?? const <Experiment>[];
      detail.add(_label('Experiments (${exps.length})'));
      for (final e in exps) {
        detail
          ..add(pw.SizedBox(height: 6))
          ..add(_itemTitle(e.title))
          ..add(_subtle('${_pretty(e.status.name)}'
              '${e.date != null ? '  ·  ${_date(e.date)}' : ''}'));
        if (e.hypothesis.isNotEmpty) detail.add(_field('Hypothesis', e.hypothesis));
        if (e.methodologySteps.isNotEmpty) {
          detail.addAll(_numberedSteps('Methodology', e.methodologySteps));
        }
        if (e.resultsNotes.isNotEmpty) detail.add(_field('Results', e.resultsNotes));
        if (e.conclusion.isNotEmpty) detail.add(_field('Conclusion', e.conclusion));
        if (e.furtherPlan.isNotEmpty) {
          detail.add(_field('Further plan', e.furtherPlan));
        }
        if (e.strainIds.isNotEmpty) {
          detail
            ..add(_label('Strains'))
            ..add(_chips([for (final id in e.strainIds) strainNameById[id] ?? id]));
        }
        detail.addAll(await _imageWidgets(db, experimentId: e.id));
      }
    }
  }

  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  final inMonth = all
      .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
      .toList();
  final byDay = groupByDay(inMonth);
  final cells = monthCells(start);
  final days = byDay.keys.toList()..sort();

  pw.Widget headerCell(String w) => pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Text(w,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget dayCell(DateTime day) {
    final within = day.month == month.month;
    final evs = byDay[day] ?? const <ScheduleEvent>[];
    return pw.Container(
      height: 64,
      padding: const pw.EdgeInsets.all(3),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('${day.day}',
            style: pw.TextStyle(
                fontSize: 9,
                color: within ? PdfColors.black : PdfColors.grey500)),
        pw.SizedBox(height: 1),
        for (final e in evs.take(3))
          pw.Text('• ${_clip(e.title, 14)}',
              maxLines: 1,
              style: pw.TextStyle(
                  fontSize: 6, color: _scheduleKindColor[e.kind])),
        if (evs.length > 3)
          pw.Text('+${evs.length - 3} more',
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
      ]),
    );
  }

  return _build(fonts, (ctx) => [
        _title('Schedule'),
        pw.SizedBox(height: 4),
        _subtle('${monthName(month.month)} ${month.year}'
            '${hasSelection ? '  ·  ${projects.length} project(s), ${experiments.length} experiment(s)' : ''}'),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            for (var i = 0; i < 7; i++) i: const pw.FlexColumnWidth(1)
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [for (final w in weekdayLabels) headerCell(w)],
            ),
            for (var i = 0; i < cells.length; i += 7)
              pw.TableRow(
                  children: [for (final d in cells.sublist(i, i + 7)) dayCell(d)]),
          ],
        ),
        _sectionTitle('Agenda'),
        if (inMonth.isEmpty)
          _subtle('Nothing scheduled this month.')
        else
          for (final day in days) ...[
            _label('${weekdayLabels[day.weekday - 1]}  ${_date(day)}'),
            for (final e in byDay[day]!)
              _bullet('${e.title}   —   ${e.kind.label}'),
            pw.SizedBox(height: 4),
          ],
        if (detail.isNotEmpty) ...[
          _sectionTitle('Project & experiment details'),
          ...detail,
        ],
      ]);
}
