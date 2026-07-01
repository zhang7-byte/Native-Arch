import 'dart:convert';

import 'package:drift/drift.dart';

/// Persists a `List<String>` as a JSON-encoded text column.
///
/// SQLite has no native array type, so list-valued fields (Project.tags,
/// Experiment.dataLinks) are stored as a single JSON string. JSON keeps the
/// column portable and round-trips directly to a Postgres `jsonb`/text column
/// when Supabase sync is added later.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const <String>[];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// One fragment of a Gibson-assembly clone construction. Strain/primer
/// references are *logical* ids (resolved in the app and degrading gracefully if
/// the referenced row is gone) — the same approach as Experiment.strainIds.
class CloneFragment {
  const CloneFragment({
    this.name = '',
    this.templateStrainId = '',
    this.fwdPrimerId = '',
    this.revPrimerId = '',
    this.sizeBp = '',
    this.notes = '',
  });

  final String name;
  final String templateStrainId; // PCR template (a strain)
  final String fwdPrimerId; // forward primer (from inventory)
  final String revPrimerId; // reverse primer
  final String sizeBp; // amplicon size, free text (e.g. "1.2 kb")
  final String notes;

  CloneFragment copyWith({
    String? name,
    String? templateStrainId,
    String? fwdPrimerId,
    String? revPrimerId,
    String? sizeBp,
    String? notes,
  }) =>
      CloneFragment(
        name: name ?? this.name,
        templateStrainId: templateStrainId ?? this.templateStrainId,
        fwdPrimerId: fwdPrimerId ?? this.fwdPrimerId,
        revPrimerId: revPrimerId ?? this.revPrimerId,
        sizeBp: sizeBp ?? this.sizeBp,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'templateStrainId': templateStrainId,
        'fwdPrimerId': fwdPrimerId,
        'revPrimerId': revPrimerId,
        'sizeBp': sizeBp,
        'notes': notes,
      };

  factory CloneFragment.fromJson(Map<String, dynamic> j) => CloneFragment(
        name: j['name'] as String? ?? '',
        templateStrainId: j['templateStrainId'] as String? ?? '',
        fwdPrimerId: j['fwdPrimerId'] as String? ?? '',
        revPrimerId: j['revPrimerId'] as String? ?? '',
        sizeBp: j['sizeBp'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
      );
}

/// Persists a `List<CloneFragment>` as JSON text (see [StringListConverter]).
class CloneFragmentListConverter
    extends TypeConverter<List<CloneFragment>, String> {
  const CloneFragmentListConverter();

  @override
  List<CloneFragment> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const <CloneFragment>[];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => CloneFragment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<CloneFragment> value) =>
      jsonEncode(value.map((e) => e.toJson()).toList());
}

/// One markup annotation drawn over an attached image. Coordinates are
/// normalised to 0..1 of the image so they survive scaling. `type` is
/// `arrow` | `rect` | `oval` | `text`; for `text`, [text] is the label and
/// (x1,y1) is its anchor.
class ImageAnnotation {
  const ImageAnnotation({
    required this.type,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.text = '',
    this.color = 0xFFE53935, // red
    this.strokeWidth = 3,
  });

  final String type;
  final double x1, y1, x2, y2;
  final String text;
  final int color;
  final double strokeWidth;

  ImageAnnotation copyWith({double? x1, double? y1, double? x2, double? y2}) =>
      ImageAnnotation(
        type: type,
        x1: x1 ?? this.x1,
        y1: y1 ?? this.y1,
        x2: x2 ?? this.x2,
        y2: y2 ?? this.y2,
        text: text,
        color: color,
        strokeWidth: strokeWidth,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        if (text.isNotEmpty) 'text': text,
        'color': color,
        'strokeWidth': strokeWidth,
      };

  factory ImageAnnotation.fromJson(Map<String, dynamic> j) => ImageAnnotation(
        type: j['type'] as String? ?? 'arrow',
        x1: (j['x1'] as num?)?.toDouble() ?? 0,
        y1: (j['y1'] as num?)?.toDouble() ?? 0,
        x2: (j['x2'] as num?)?.toDouble() ?? 0,
        y2: (j['y2'] as num?)?.toDouble() ?? 0,
        text: j['text'] as String? ?? '',
        color: (j['color'] as num?)?.toInt() ?? 0xFFE53935,
        strokeWidth: (j['strokeWidth'] as num?)?.toDouble() ?? 3,
      );
}

/// Persists a `List<ImageAnnotation>` as JSON text.
class ImageAnnotationListConverter
    extends TypeConverter<List<ImageAnnotation>, String> {
  const ImageAnnotationListConverter();

  @override
  List<ImageAnnotation> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const <ImageAnnotation>[];
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => ImageAnnotation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<ImageAnnotation> value) =>
      jsonEncode(value.map((e) => e.toJson()).toList());
}
