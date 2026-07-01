import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/experiment_repository.dart';
import 'package:labtrack/data/image_repository.dart';
import 'package:labtrack/sync/image_sync.dart';

/// In-memory stand-in for Supabase Storage, so the image round-trip is testable
/// without a live backend.
class FakeImageStorage implements ImageStorage {
  final Map<String, Uint8List> store = {};

  @override
  Future<void> upload(String path, Uint8List bytes, String contentType) async {
    store[path] = bytes;
  }

  @override
  Future<Uint8List> download(String path) async {
    final b = store[path];
    if (b == null) throw Exception('not found: $path');
    return b;
  }
}

Future<String> _seedExperiment(AppDatabase db, {String? projectId}) async {
  final pid = projectId ?? uuid.v4();
  await db
      .into(db.projects)
      .insert(ProjectsCompanion.insert(title: 'P', id: Value(pid)));
  final eid = uuid.v4();
  await db.into(db.experiments).insert(
      ExperimentsCompanion.insert(projectId: pid, title: 'E', id: Value(eid)));
  return eid;
}

void main() {
  test('attaching an image stores metadata and local bytes (no upload yet)',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final eid = await _seedExperiment(db);
    final repo = ImageRepository(db);
    final bytes = Uint8List.fromList(List.generate(64, (i) => i));

    final id = await repo.add(
        experimentId: eid,
        bytes: bytes,
        contentType: 'image/png',
        caption: 'Gel');

    final imgs = await repo.watchForExperiment(eid).first;
    expect(imgs.length, 1);
    expect(imgs.first.caption, 'Gel');
    expect(imgs.first.contentType, 'image/png');
    expect(imgs.first.storagePath, ''); // bytes never went to the synced row
    expect(await repo.bytesFor(id), bytes); // shows offline
  });

  test('an attached image survives a restart', () async {
    final dir = Directory.systemTemp.createTempSync('lt_img');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/img.sqlite');

    final db1 = AppDatabase(NativeDatabase(file));
    final eid = await _seedExperiment(db1);
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final id = await ImageRepository(db1)
        .add(experimentId: eid, bytes: bytes, contentType: 'image/jpeg');
    await db1.close();

    final db2 = AppDatabase(NativeDatabase(file));
    addTearDown(db2.close);
    expect(await ImageRepository(db2).bytesFor(id), bytes);
  });

  test('deleting an image removes its cached bytes and tombstones it', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final eid = await _seedExperiment(db);
    final repo = ImageRepository(db);
    final id = await repo.add(
        experimentId: eid,
        bytes: Uint8List.fromList([9, 9]),
        contentType: 'image/png');

    await repo.delete(id);

    expect(await repo.bytesFor(id), isNull); // FK cascade removed the blob
    expect(await repo.watchForExperiment(eid).first, isEmpty);
    final tombs = await db.select(db.tombstones).get();
    expect(tombs.any((t) => t.id == id && t.entityTable == 'images'), isTrue);
  });

  test('deleting the parent experiment cascades and tombstones its images',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final eid = await _seedExperiment(db);
    final repo = ImageRepository(db);
    final id = await repo.add(
        experimentId: eid,
        bytes: Uint8List.fromList([7]),
        contentType: 'image/png');

    await ExperimentRepository(db).delete(eid);

    expect(await repo.bytesFor(id), isNull);
    final tombs = await db.select(db.tombstones).get();
    expect(tombs.any((t) => t.id == id && t.entityTable == 'images'), isTrue);
  });

  test('an attached image survives a sync round-trip '
      '(upload -> metadata sync -> download)', () async {
    final storage = FakeImageStorage();
    final dbA = AppDatabase(NativeDatabase.memory());
    final dbB = AppDatabase(NativeDatabase.memory());
    addTearDown(dbA.close);
    addTearDown(dbB.close);

    // Device A attaches an image to an experiment.
    final pid = uuid.v4();
    final eid = await _seedExperiment(dbA, projectId: pid);
    final repoA = ImageRepository(dbA);
    final bytes = Uint8List.fromList(List.generate(256, (i) => i % 256));
    final id = await repoA.add(
        experimentId: eid,
        bytes: bytes,
        contentType: 'image/png',
        caption: 'Plate 1');

    // A pushes: upload the file to Storage and stamp the returned path.
    expect(await uploadPendingImages(dbA, storage, 'user-A'), 1);
    final imgA = (await repoA.watchForExperiment(eid).first).first;
    expect(imgA.storagePath, isNotEmpty);
    expect(storage.store.containsKey(imgA.storagePath), isTrue);

    // Device B already has the project + experiment (synced earlier); the image
    // METADATA row syncs in carrying no bytes (only the storage path).
    await dbB
        .into(dbB.projects)
        .insert(ProjectsCompanion.insert(title: 'P', id: Value(pid)));
    await dbB.into(dbB.experiments).insert(
        ExperimentsCompanion.insert(projectId: pid, title: 'E', id: Value(eid)));
    await dbB.into(dbB.images).insert(ImagesCompanion.insert(
          id: Value(imgA.id),
          experimentId: Value(eid),
          caption: Value(imgA.caption),
          contentType: Value(imgA.contentType),
          storagePath: Value(imgA.storagePath),
        ));
    expect(await ImageRepository(dbB).bytesFor(id), isNull); // no bytes yet

    // B pulls: download the file from Storage into its local cache.
    expect(await downloadMissingImages(dbB, storage), 1);

    // B now displays the same image with bytes intact and caption preserved.
    expect(await ImageRepository(dbB).bytesFor(id), bytes);
    final imgB = (await ImageRepository(dbB).watchForExperiment(eid).first).first;
    expect(imgB.caption, 'Plate 1');
  });
}
