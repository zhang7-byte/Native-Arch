import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../data/csv_import.dart' show ImportEntity, fieldsFor;
import '../../data/database.dart';
import '../../data/file_save_web.dart'
    if (dart.library.io) '../../data/file_save_io.dart';
import '../../data/primer_repository.dart';
import '../../data/protocol_repository.dart';
import '../../data/reagent_repository.dart';
import '../../data/strain_repository.dart';

String _cell(String v) =>
    (v.contains(',') || v.contains('"') || v.contains('\n'))
        ? '"${v.replaceAll('"', '""')}"'
        : v;

String _date(DateTime? d) {
  if (d == null) return '';
  String two(int x) => x.toString().padLeft(2, '0');
  final l = d.toLocal();
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

/// One list of cells per row, in the SAME column order as [fieldsFor], so the
/// output round-trips through the importer.
Future<List<List<String>>> _rows(AppDatabase db, ImportEntity e) async {
  switch (e) {
    case ImportEntity.strain:
      final list = await StrainRepository(db).watchAll().first;
      return [
        for (final s in list)
          [
            s.name,
            s.serialNumber,
            s.hostOrganism,
            s.genotype,
            s.plasmid,
            s.constructNotes,
            s.freezerLocation,
            s.notes,
          ],
      ];
    case ImportEntity.reagent:
      final list = await ReagentRepository(db).watchAll().first;
      return [
        for (final r in list)
          [
            r.name,
            r.kind,
            r.supplier,
            r.catalogNo,
            r.lot,
            r.location,
            _date(r.expiryDate),
            r.quantity,
            r.recipe,
            r.notes,
          ],
      ];
    case ImportEntity.primer:
      final list = await PrimerRepository(db).watchAll().first;
      return [
        for (final p in list)
          [
            p.name,
            p.serialNumber,
            p.sequence,
            p.targetGene,
            p.direction,
            p.tm,
            p.supplier,
            p.notes,
          ],
      ];
    case ImportEntity.protocol:
      final list = await ProtocolRepository(db).watchAll().first;
      return [
        for (final p in list)
          [
            p.name,
            p.category,
            p.summary,
            p.steps.join('|'),
            p.materials,
            p.notes,
          ],
      ];
  }
}

/// Serializes every [entity] row in the current workspace to a CSV string whose
/// columns exactly match what the importer expects (so exports round-trip).
Future<String> buildEntityCsv(AppDatabase db, ImportEntity entity) async {
  final header = fieldsFor(entity).map((f) => f.key).join(',');
  final rows = await _rows(db, entity);
  final lines = rows.map((cells) => cells.map(_cell).join(','));
  return '${[header, ...lines].join('\r\n')}\r\n';
}

/// Builds the [entity] CSV and saves it via a file dialog.
Future<void> exportEntityCsv(BuildContext context, AppDatabase db,
    ImportEntity entity, String baseName) async {
  final messenger = ScaffoldMessenger.of(context);
  final bytes =
      Uint8List.fromList(utf8.encode(await buildEntityCsv(db, entity)));
  final name = '$baseName.csv';
  final path = await FilePicker.saveFile(
    dialogTitle: 'Export CSV',
    fileName: name,
    type: FileType.custom,
    allowedExtensions: const ['csv'],
    bytes: bytes,
  );
  if (!kIsWeb) {
    if (path == null) return; // cancelled
    await writeBytes(path, bytes);
  }
  messenger.showSnackBar(SnackBar(content: Text('Exported $name')));
}
