import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/culture_repository.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/image_repository.dart';

void main() {
  test('culture lifecycle: start from strain, attach image, archive, restore',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final cultures = CultureRepository(db);
    final images = ImageRepository(db);

    // A strain to start the culture from.
    final strainId = uuid.v4();
    await db
        .into(db.strains)
        .insert(StrainsCompanion.insert(id: Value(strainId), name: '2419'));

    // Start a culture from the strain.
    final cid = await cultures.create(CulturesCompanion(
      name: const Value('2419 in YPD'),
      strainId: Value(strainId),
      medium: const Value('YPD'),
    ));
    final c = await cultures.watchById(cid).first;
    expect(c!.strainId, strainId);
    expect(c.status, 'active');
    expect(c.endedDate, isNull);
    expect((await cultures.watchActive().first).any((x) => x.id == cid), isTrue);

    // Attach an image owned by the culture.
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    final imgId = await images.add(
        cultureId: cid,
        bytes: bytes,
        contentType: 'image/png',
        caption: 'Day 1');
    final imgs = await images.watchForCulture(cid).first;
    expect(imgs.length, 1);
    expect(imgs.first.cultureId, cid);
    expect(await images.bytesFor(imgId), bytes);

    // Archive: leaves the active list, appears in archived, ended_date stamped.
    await cultures.archive(cid);
    expect((await cultures.watchActive().first).any((x) => x.id == cid), isFalse);
    expect(
        (await cultures.watchArchived().first).any((x) => x.id == cid), isTrue);
    final archived = await cultures.watchById(cid).first;
    expect(archived!.status, 'archived');
    expect(archived.endedDate, isNotNull);
    // The image survives the status change.
    expect(await images.bytesFor(imgId), bytes);

    // Restore: back to active, ended_date cleared.
    await cultures.restore(cid);
    final restored = await cultures.watchById(cid).first;
    expect(restored!.status, 'active');
    expect(restored.endedDate, isNull);
    expect((await cultures.watchActive().first).any((x) => x.id == cid), isTrue);
    expect(
        (await cultures.watchArchived().first).any((x) => x.id == cid), isFalse);
  });
}
