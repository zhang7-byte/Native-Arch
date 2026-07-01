import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/image_repository.dart';
import 'package:labtrack/ui/images/annotation.dart';

Uint8List _png() {
  final im = img.Image(width: 80, height: 60);
  for (var y = 0; y < im.height; y++) {
    for (var x = 0; x < im.width; x++) {
      im.setPixelRgb(x, y, (x * 3) & 0xFF, (y * 4) & 0xFF, 120);
    }
  }
  return img.encodePng(im);
}

void main() {
  // Everything runs inside tester.runAsync so drift queries use real timers AND
  // the engine is available for image decode/encode (the flatten).
  testWidgets('annotations + notes persist and flatten to PNG', (tester) async {
    await tester.runAsync(() async {
      final db = AppDatabase(NativeDatabase.memory());
      try {
        await db
            .into(db.strains)
            .insert(StrainsCompanion.insert(id: const Value('s1'), name: 'S'));
        final repo = ImageRepository(db);
        final png = _png();
        final imgId =
            await repo.add(strainId: 's1', bytes: png, contentType: 'image/png');

        await repo.updateAnnotations(imgId, const [
          ImageAnnotation(type: 'arrow', x1: 0.1, y1: 0.1, x2: 0.5, y2: 0.5),
          ImageAnnotation(
              type: 'text', x1: 0.2, y1: 0.8, x2: 0.2, y2: 0.8, text: 'band'),
        ]);
        await repo.updateNotes(imgId, 'lane 3 correct');

        final stored = await (db.select(db.images)
              ..where((t) => t.id.equals(imgId)))
            .getSingleOrNull();
        expect(stored!.notes, 'lane 3 correct');
        expect(stored.annotations.length, 2); // JSON converter round-trips
        expect(stored.annotations.first.type, 'arrow');
        expect(stored.annotations[1].text, 'band');

        final flat = await renderAnnotatedImagePng(png, stored.annotations);
        expect(flat, isNotNull);
        expect(flat!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]); // PNG signature

        // No annotations → null (caller uses the original bytes).
        expect(await renderAnnotatedImagePng(png, const []), isNull);
      } finally {
        await db.close();
      }
    });
  });
}
