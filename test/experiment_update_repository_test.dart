import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/experiment_update_repository.dart';
import 'package:labtrack/data/image_repository.dart';

void main() {
  test('add / watch / edit / delete updates, with image cascade', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(id: const Value('p1'), title: 'P'));
    await db.into(db.experiments).insert(ExperimentsCompanion.insert(
        id: const Value('e1'), projectId: 'p1', title: 'E'));

    final repo = ExperimentUpdateRepository(db);
    final id = await repo.add(
        experimentId: 'e1', happenedAt: DateTime(2026, 6, 26), note: 'first run');

    var list = await repo.watchForExperiment('e1').first;
    expect(list.length, 1);
    expect(list.first.note, 'first run');

    // Attach an image to the update.
    final imgId = await ImageRepository(db).add(
        updateId: id,
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/png');
    expect((await ImageRepository(db).watchForUpdate(id).first).length, 1);

    await repo.edit(id, happenedAt: DateTime(2026, 6, 27), note: 'edited');
    expect((await repo.watchForExperiment('e1').first).first.note, 'edited');

    await repo.delete(id);
    expect(await repo.watchForExperiment('e1').first, isEmpty);
    expect(await db.select(db.images).get(), isEmpty); // cascaded
    final tombs = await db.select(db.tombstones).get();
    expect(tombs.any((t) => t.id == id && t.entityTable == 'experiment_updates'),
        isTrue);
    expect(tombs.any((t) => t.id == imgId && t.entityTable == 'images'), isTrue);
  });
}
