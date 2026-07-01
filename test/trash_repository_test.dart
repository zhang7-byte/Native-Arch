import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/image_repository.dart';
import 'package:labtrack/data/project_repository.dart';
import 'package:labtrack/data/trash_repository.dart';

void main() {
  test('trashing a project captures the subtree; restore brings it all back',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(id: const Value('p1'), title: 'Proj'));
    await db.into(db.experiments).insert(ExperimentsCompanion.insert(
        id: const Value('e1'), projectId: 'p1', title: 'Exp'));
    await db.into(db.tasks).insert(TasksCompanion.insert(
        id: const Value('t1'), title: 'Task', projectId: const Value('p1')));
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final imgId = await ImageRepository(db).add(
        experimentId: 'e1',
        bytes: bytes,
        contentType: 'image/png',
        caption: 'gel');

    // Delete via the normal repo path (routes through Trash).
    await ProjectRepository(db).delete('p1');

    // Everything is gone from the live tables.
    expect(await db.select(db.projects).get(), isEmpty);
    expect(await db.select(db.experiments).get(), isEmpty);
    expect(await db.select(db.tasks).get(), isEmpty);
    expect(await db.select(db.images).get(), isEmpty);
    expect(await db.select(db.imageBlobs).get(), isEmpty);

    final trash = TrashRepository(db);
    final entries = await trash.watchAll().first;
    expect(entries.length, 1);
    expect(entries.single.kind, 'Project');
    expect(entries.single.label, 'Proj');
    // project + experiment + task + image were tombstoned.
    expect((await db.select(db.tombstones).get()).length, 4);

    // Restore.
    await trash.restore(entries.single.id);
    expect((await db.select(db.projects).get()).single.title, 'Proj');
    expect((await db.select(db.experiments).get()).single.id, 'e1');
    expect((await db.select(db.tasks).get()).single.id, 't1');
    expect((await db.select(db.images).get()).single.id, imgId);
    expect(await ImageRepository(db).bytesFor(imgId), bytes); // blob restored
    // Tombstones cleared (no longer "deleted") + trash entry consumed.
    expect(await db.select(db.tombstones).get(), isEmpty);
    expect(await trash.watchAll().first, isEmpty);
  });

  test('purge removes a trash entry without restoring the rows', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.reagents)
        .insert(ReagentsCompanion.insert(id: const Value('r1'), name: 'R'));
    final trash = TrashRepository(db);
    final entryId = await trash.trash('reagents', 'r1');
    expect(entryId, isNotNull);
    expect((await trash.watchAll().first).length, 1);

    await trash.purge(entryId!);
    expect(await trash.watchAll().first, isEmpty);
    expect(await db.select(db.reagents).get(), isEmpty); // stays deleted
  });

  test('purgeExpired drops only entries past the retention window', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.trashEntries).insert(TrashEntriesCompanion.insert(
        entityTable: 'reagents',
        entityId: 'x',
        payload: '{}',
        deletedAt:
            Value(DateTime.now().toUtc().subtract(const Duration(days: 40)))));
    await db.into(db.trashEntries).insert(TrashEntriesCompanion.insert(
        entityTable: 'reagents', entityId: 'y', payload: '{}')); // recent

    final removed =
        await TrashRepository(db).purgeExpired(const Duration(days: 30));
    expect(removed, 1);
    expect((await db.select(db.trashEntries).get()).single.entityId, 'y');
  });
}
