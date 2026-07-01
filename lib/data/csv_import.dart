import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import 'database.dart';
import 'workspace_repository.dart';

enum ImportEntity { strain, reagent, primer, protocol }

/// A target field for CSV mapping (the SPEC.md Section 3 fields).
class ImportField {
  const ImportField(this.key, this.label,
      {this.required = false, this.isDate = false});
  final String key;
  final String label;
  final bool required;
  final bool isDate;
}

const _strainFields = [
  ImportField('name', 'Name', required: true),
  ImportField('serial_number', 'Serial number'),
  ImportField('host_organism', 'Host organism'),
  ImportField('genotype', 'Genotype'),
  ImportField('plasmid', 'Plasmid'),
  ImportField('construct_notes', 'Construct notes'),
  ImportField('freezer_location', 'Freezer location'),
  ImportField('notes', 'Notes'),
];

const _reagentFields = [
  ImportField('name', 'Name', required: true),
  ImportField('kind', 'Kind'), // 'reagent' or 'buffer'
  ImportField('supplier', 'Supplier'),
  ImportField('catalog_no', 'Catalog no.'),
  ImportField('lot', 'Lot'),
  ImportField('location', 'Location'),
  ImportField('expiry_date', 'Expiry date', isDate: true),
  ImportField('quantity', 'Quantity'),
  ImportField('recipe', 'Recipe'),
  ImportField('notes', 'Notes'),
];

const _primerFields = [
  ImportField('name', 'Name', required: true),
  ImportField('serial_number', 'Serial number'),
  ImportField('sequence', 'Sequence'),
  ImportField('target_gene', 'Target gene'),
  ImportField('direction', 'Direction'),
  ImportField('tm', 'Tm'),
  ImportField('supplier', 'Supplier'),
  ImportField('notes', 'Notes'),
];

const _protocolFields = [
  ImportField('name', 'Name', required: true),
  ImportField('category', 'Category'),
  ImportField('summary', 'Summary'),
  ImportField('steps', 'Steps'), // steps separated by '|' or newlines
  ImportField('materials', 'Materials'),
  ImportField('notes', 'Notes'),
];

List<ImportField> fieldsFor(ImportEntity e) => switch (e) {
      ImportEntity.strain => _strainFields,
      ImportEntity.reagent => _reagentFields,
      ImportEntity.primer => _primerFields,
      ImportEntity.protocol => _protocolFields,
    };

/// Example rows for the downloadable templates (kept in the same column order as
/// [fieldsFor]).
const _sampleRows = <ImportEntity, List<List<String>>>{
  ImportEntity.strain: [
    ['2419', 'SU-S001', 'Yarrowia lipolytica', 'MATA ura3-302', 'p5219',
        'IAA-inducible AID2 + dGFP', 'Box A2', 'imported from CSV'],
    ['EC100', 'SU-S002', 'Escherichia coli', 'F- endA1 recA1', 'pUC19',
        'cloning host', 'Box C3', ''],
  ],
  ImportEntity.reagent: [
    ['Auxin (IAA)', 'reagent', 'Sigma-Aldrich', 'I2886', 'SLBX1234', 'Shelf 2',
        '2026-12-31', '5 g', '', 'light-sensitive'],
    ['TAE 50x', 'buffer', '', '', '', 'Shelf 1', '', '1 L',
        'Tris base 242 g; glacial acetic acid 57.1 mL; 0.5 M EDTA pH 8 100 mL; '
            'water to 1 L', 'dilute to 1x before use'],
  ],
  ImportEntity.primer: [
    ['M13F', 'SU-P001', 'GTAAAACGACGGCCAGT', 'lacZ', 'forward', '52', 'IDT',
        'universal sequencing primer'],
    ['oLT-114', 'SU-P002', 'CGGATAACAATTTCACACAGG', 'mIAA7', 'reverse', '55',
        'IDT', ''],
  ],
  ImportEntity.protocol: [
    [
      'Heat-shock transformation',
      'Transformation',
      'Standard chemical transformation of competent E. coli.',
      'Thaw competent cells on ice|Add 1-5 uL plasmid, mix gently|'
          'Incubate on ice 30 min|Heat shock 42C for 45 s|Ice 2 min|'
          'Add 950 uL SOC, recover 37C 1 h|Plate on selective agar',
      'Competent cells; SOC; selective LB agar plates',
      'Keep everything on ice until recovery',
    ],
    [
      'Agarose gel electrophoresis',
      'Analysis',
      'Separate DNA fragments by size on an agarose gel.',
      'Cast 1% agarose gel with stain|Load samples and ladder|'
          'Run at 100 V for 30 min|Image under UV',
      '1% agarose; 1x TAE; DNA ladder; loading dye',
      '',
    ],
  ],
};

String _csvCell(String v) =>
    (v.contains(',') || v.contains('"') || v.contains('\n'))
        ? '"${v.replaceAll('"', '""')}"'
        : v;

/// A downloadable example CSV for [entity]: the exact header row the importer
/// expects (the field keys) plus a couple of illustrative rows, so users can see
/// the required format before composing their own.
String sampleCsv(ImportEntity entity) {
  final header = fieldsFor(entity).map((f) => f.key).join(',');
  final rows = _sampleRows[entity]!.map((r) => r.map(_csvCell).join(','));
  return '${[header, ...rows].join('\r\n')}\r\n';
}

/// How rows are matched for upsert (shown in the UI).
String matchKeyLabel(ImportEntity e) =>
    e == ImportEntity.reagent ? 'catalog_no + lot' : 'name';

class ParsedCsv {
  ParsedCsv(this.headers, this.rows);
  final List<String> headers;
  final List<List<String>> rows;
}

ParsedCsv parseCsv(String content) {
  final normalized =
      content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final table =
      Csv(dynamicTyping: false, autoDetect: false).decode(normalized);
  if (table.isEmpty) return ParsedCsv([], []);
  final headers = table.first.map((c) => c.toString().trim()).toList();
  final rows = <List<String>>[];
  for (final r in table.skip(1)) {
    final cells = r.map((c) => c.toString()).toList();
    if (cells.every((c) => c.trim().isEmpty)) continue; // skip blank lines
    rows.add(cells);
  }
  return ParsedCsv(headers, rows);
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

/// Auto-maps entity fields to CSV columns by normalized header match.
Map<String, int> autoMapping(List<String> headers, ImportEntity entity) {
  final byNorm = <String, int>{};
  for (var i = 0; i < headers.length; i++) {
    byNorm.putIfAbsent(_norm(headers[i]), () => i);
  }
  final mapping = <String, int>{};
  for (final f in fieldsFor(entity)) {
    for (final candidate in {_norm(f.key), _norm(f.label)}) {
      if (byNorm.containsKey(candidate)) {
        mapping[f.key] = byNorm[candidate]!;
        break;
      }
    }
  }
  return mapping;
}

/// Parses yyyy-MM-dd (and yyyy/MM/dd, yyyy.MM.dd, full ISO); null if invalid.
DateTime? tryParseDate(String s) {
  s = s.trim();
  if (s.isEmpty) return null;
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso;
  final m = RegExp(r'^(\d{4})[/.](\d{1,2})[/.](\d{1,2})$').firstMatch(s);
  if (m != null) {
    return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }
  return null;
}

String? cell(List<String> row, Map<String, int> mapping, String key) {
  final idx = mapping[key];
  if (idx == null || idx < 0 || idx >= row.length) return null;
  return row[idx].trim();
}

/// Validation problems for one row (empty list = importable).
List<String> rowProblems(
    ImportEntity entity, List<String> row, Map<String, int> mapping) {
  final problems = <String>[];
  for (final f in fieldsFor(entity)) {
    final v = cell(row, mapping, f.key) ?? '';
    if (f.required && v.isEmpty) problems.add('missing ${f.label}');
    if (f.isDate && v.isNotEmpty && tryParseDate(v) == null) {
      problems.add('bad date "$v"');
    }
  }
  if (entity == ImportEntity.reagent) {
    // Buffers are matched on name, so they don't need a catalog_no / lot.
    final isBuffer =
        (cell(row, mapping, 'kind') ?? '').toLowerCase().contains('buffer');
    if (!isBuffer) {
      final catalogNo = cell(row, mapping, 'catalog_no') ?? '';
      final lot = cell(row, mapping, 'lot') ?? '';
      if (catalogNo.isEmpty && lot.isEmpty) {
        problems.add('needs catalog_no or lot to match on');
      }
    }
  }
  return problems;
}

class ImportSummary {
  ImportSummary(this.inserted, this.updated, this.skipped);
  final int inserted;
  final int updated;
  final int skipped;
}

/// Imports the valid rows in one transaction; invalid rows are skipped.
///
/// When [addAsNew] is true, every valid row is inserted as a NEW entry — use this
/// to bulk-import a list that may contain repeated names. When false (matching
/// mode), rows are upserted: strains/primers match on `name`, reagents on
/// `catalog_no` + `lot`, and a match updates that row in place (only mapped
/// columns are written, so unmapped fields keep their existing values).
Future<ImportSummary> runImport(
  AppDatabase db,
  ImportEntity entity,
  ParsedCsv csv,
  Map<String, int> mapping, {
  bool addAsNew = false,
}) async {
  var inserted = 0, updated = 0, skipped = 0;
  final ws = await currentWorkspaceId(db);
  final wsValue = ws == null ? const Value<String>.absent() : Value(ws);
  await db.transaction(() async {
    for (final row in csv.rows) {
      if (rowProblems(entity, row, mapping).isNotEmpty) {
        skipped++;
        continue;
      }
      Value<String> text(String key) {
        final idx = mapping[key];
        return idx == null
            ? const Value.absent()
            : Value(cell(row, mapping, key) ?? '');
      }

      if (entity == ImportEntity.strain) {
        final name = cell(row, mapping, 'name')!;
        final companion = StrainsCompanion(
          name: Value(name),
          serialNumber: text('serial_number'),
          hostOrganism: text('host_organism'),
          genotype: text('genotype'),
          plasmid: text('plasmid'),
          constructNotes: text('construct_notes'),
          freezerLocation: text('freezer_location'),
          notes: text('notes'),
          workspaceId: wsValue,
        );
        final existing = addAsNew
            ? null
            : await (db.select(db.strains)
                  ..where((t) => ws == null
                      ? t.name.equals(name)
                      : t.name.equals(name) & t.workspaceId.equals(ws)))
                .getSingleOrNull();
        if (existing != null) {
          await (db.update(db.strains)..where((t) => t.id.equals(existing.id)))
              .write(companion);
          updated++;
        } else {
          await db.into(db.strains).insert(companion);
          inserted++;
        }
      } else if (entity == ImportEntity.reagent) {
        final name = cell(row, mapping, 'name')!;
        final catalogNo = cell(row, mapping, 'catalog_no') ?? '';
        final lot = cell(row, mapping, 'lot') ?? '';
        final isBuffer = (cell(row, mapping, 'kind') ?? '')
            .toLowerCase()
            .contains('buffer');
        // Normalize the kind cell to the two known values (default reagent).
        Value<String> kind() => mapping['kind'] == null
            ? const Value.absent()
            : Value(isBuffer ? 'buffer' : 'reagent');
        Value<DateTime?> expiry() {
          final idx = mapping['expiry_date'];
          if (idx == null) return const Value.absent();
          final v = cell(row, mapping, 'expiry_date') ?? '';
          // Store as parsed (local date, like the date pickers elsewhere).
          return Value(v.isEmpty ? null : tryParseDate(v));
        }

        final companion = ReagentsCompanion(
          name: text('name'),
          kind: kind(),
          supplier: text('supplier'),
          catalogNo: text('catalog_no'),
          lot: text('lot'),
          location: text('location'),
          expiryDate: expiry(),
          quantity: text('quantity'),
          recipe: text('recipe'),
          notes: text('notes'),
          workspaceId: wsValue,
        );
        // Reagents upsert on catalog_no + lot; buffers (which usually lack
        // those) upsert on name within the workspace.
        final existing = addAsNew
            ? null
            : await (db.select(db.reagents)
                  ..where((t) {
                    final base = isBuffer
                        ? t.name.equals(name) & t.kind.equals('buffer')
                        : t.catalogNo.equals(catalogNo) & t.lot.equals(lot);
                    return ws == null ? base : base & t.workspaceId.equals(ws);
                  }))
                .getSingleOrNull();
        if (existing != null) {
          await (db.update(db.reagents)
                ..where((t) => t.id.equals(existing.id)))
              .write(companion);
          updated++;
        } else {
          await db.into(db.reagents).insert(companion);
          inserted++;
        }
      } else if (entity == ImportEntity.protocol) {
        final name = cell(row, mapping, 'name')!;
        // Steps live in one cell, separated by '|' or newlines. Stable ids are
        // generated alongside so in-app per-step image links have something to
        // reference.
        final stepsIdx = mapping['steps'];
        final stepList = stepsIdx == null
            ? const <String>[]
            : (cell(row, mapping, 'steps') ?? '')
                .split(RegExp(r'[\n|]'))
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

        final companion = ProtocolsCompanion(
          name: Value(name),
          category: text('category'),
          summary: text('summary'),
          steps: stepsIdx == null ? const Value.absent() : Value(stepList),
          stepIds: stepsIdx == null
              ? const Value.absent()
              : Value([for (final _ in stepList) uuid.v4()]),
          materials: text('materials'),
          notes: text('notes'),
          workspaceId: wsValue,
        );
        final existing = addAsNew
            ? null
            : await (db.select(db.protocols)
                  ..where((t) => ws == null
                      ? t.name.equals(name)
                      : t.name.equals(name) & t.workspaceId.equals(ws)))
                .getSingleOrNull();
        if (existing != null) {
          await (db.update(db.protocols)
                ..where((t) => t.id.equals(existing.id)))
              .write(companion);
          updated++;
        } else {
          await db.into(db.protocols).insert(companion);
          inserted++;
        }
      } else {
        // primer — upsert on name
        final name = cell(row, mapping, 'name')!;
        final companion = PrimersCompanion(
          name: Value(name),
          serialNumber: text('serial_number'),
          sequence: text('sequence'),
          targetGene: text('target_gene'),
          direction: text('direction'),
          tm: text('tm'),
          supplier: text('supplier'),
          notes: text('notes'),
          workspaceId: wsValue,
        );
        final existing = addAsNew
            ? null
            : await (db.select(db.primers)
                  ..where((t) => ws == null
                      ? t.name.equals(name)
                      : t.name.equals(name) & t.workspaceId.equals(ws)))
                .getSingleOrNull();
        if (existing != null) {
          await (db.update(db.primers)..where((t) => t.id.equals(existing.id)))
              .write(companion);
          updated++;
        } else {
          await db.into(db.primers).insert(companion);
          inserted++;
        }
      }
    }
  });
  return ImportSummary(inserted, updated, skipped);
}
