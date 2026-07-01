import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/backup.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/image_repository.dart';

const _ws = 'ws-1';
final _imgBytes = Uint8List.fromList([10, 20, 30, 40, 50]);

/// Seeds two exportable projects (p1, p2) plus an un-selected p3, with
/// experiments, tasks, linked strains, a manuscript, a reagent and one image.
Future<String> _seed(AppDatabase db) async {
  await db.into(db.projects).insert(ProjectsCompanion.insert(
      id: const Value('p1'), title: 'Project One', workspaceId: const Value(_ws)));
  await db.into(db.projects).insert(ProjectsCompanion.insert(
      id: const Value('p2'), title: 'Project Two', workspaceId: const Value(_ws)));
  await db.into(db.projects).insert(ProjectsCompanion.insert(
      id: const Value('p3'), title: 'Other', workspaceId: const Value(_ws)));

  await db.into(db.strains).insert(StrainsCompanion.insert(
      id: const Value('s1'), name: '2407', workspaceId: const Value(_ws)));
  await db.into(db.strains).insert(StrainsCompanion.insert(
      id: const Value('s2'), name: '2419', workspaceId: const Value(_ws)));

  await db.into(db.experiments).insert(ExperimentsCompanion.insert(
      id: const Value('e1'),
      projectId: 'p1',
      title: 'Exp 1',
      strainIds: const Value(['s1', 's2']),
      workspaceId: const Value(_ws)));
  await db.into(db.experiments).insert(ExperimentsCompanion.insert(
      id: const Value('e2'),
      projectId: 'p2',
      title: 'Exp 2',
      strainIds: const Value(['s1']),
      workspaceId: const Value(_ws)));
  await db.into(db.experiments).insert(ExperimentsCompanion.insert(
      id: const Value('e3'),
      projectId: 'p3',
      title: 'Exp 3 (not exported)',
      workspaceId: const Value(_ws)));

  await db.into(db.tasks).insert(TasksCompanion.insert(
      id: const Value('t1'),
      title: 'Task on P1',
      projectId: const Value('p1'),
      workspaceId: const Value(_ws)));
  await db.into(db.tasks).insert(TasksCompanion.insert(
      id: const Value('t2'),
      title: 'Task on E2',
      experimentId: const Value('e2'),
      workspaceId: const Value(_ws)));

  await db.into(db.manuscripts).insert(ManuscriptsCompanion.insert(
      id: const Value('m1'),
      projectId: 'p1',
      title: 'Manuscript',
      workspaceId: const Value(_ws)));

  await db.into(db.reagents).insert(ReagentsCompanion.insert(
      id: const Value('r1'), name: 'Reagent A', workspaceId: const Value(_ws)));

  return ImageRepository(db).add(
      experimentId: 'e1',
      bytes: _imgBytes,
      contentType: 'image/png',
      caption: 'Gel photo');
}

/// Round-trips the backup through JSON text, the way a saved file would.
Map<String, dynamic> _throughFile(Map<String, dynamic> backup) =>
    jsonDecode(jsonEncode(backup)) as Map<String, dynamic>;

void main() {
  test('export of two projects captures their full graph', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);

    final backup = await buildProjectBackup(db,
        projectIds: ['p1', 'p2'], workspaceId: _ws, workspaceName: 'Lab');

    expect(backup['schemaVersion'], backupSchemaVersion);
    expect(backup['app'], 'LabTrack');
    expect((backup['projects'] as List).length, 2); // not p3
    expect((backup['experiments'] as List).length, 2); // e1, e2 (not e3)
    expect((backup['tasks'] as List).length, 2);
    expect((backup['strains'] as List).length, 2); // linked via strain_ids
    expect((backup['reagents'] as List).length, 1); // workspace inventory
    expect((backup['manuscripts'] as List).length, 1);
    final images = backup['images'] as List;
    expect(images.length, 1);
    expect(images.first['caption'], 'Gel photo');
    expect(images.first['bytes'], isNotNull); // bundled
    expect(backup['imageBytes'], 'bundled');
  });

  test('restore (merge) round-trips cleanly into a fresh database', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    final imageId = await _seed(src);
    final json = _throughFile(await buildProjectBackup(src,
        projectIds: ['p1', 'p2'], workspaceId: _ws));

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);

    final preview = await previewRestore(dst, json);
    expect(preview.total, 11); // 2+2+2+2+1+1+1
    expect(preview.existing, 0);
    expect(preview.isCompatible, isTrue);

    final summary = await runRestore(dst, json, RestoreMode.merge, workspaceId: _ws);
    expect(summary.added, 11);
    expect(summary.skipped, 0);

    expect((await dst.select(dst.projects).get()).length, 2);
    expect((await dst.select(dst.experiments).get()).length, 2);
    expect((await dst.select(dst.tasks).get()).length, 2);
    expect((await dst.select(dst.strains).get()).length, 2);
    expect((await dst.select(dst.reagents).get()).length, 1);
    expect((await dst.select(dst.manuscripts).get()).length, 1);
    // Image metadata + bundled bytes survived.
    expect(await ImageRepository(dst).bytesFor(imageId), _imgBytes);
    final e1 = (await (dst.select(dst.experiments)
              ..where((t) => t.id.equals('e1')))
            .getSingle());
    expect(e1.strainIds, ['s1', 's2']);
  });

  test('restore is idempotent in merge mode (no duplicates)', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    await _seed(src);
    final json = _throughFile(
        await buildProjectBackup(src, projectIds: ['p1', 'p2'], workspaceId: _ws));

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);
    await runRestore(dst, json, RestoreMode.merge, workspaceId: _ws);

    final second = await runRestore(dst, json, RestoreMode.merge, workspaceId: _ws);
    expect(second.added, 0);
    expect(second.skipped, 11);
    expect((await dst.select(dst.projects).get()).length, 2); // still 2
  });

  test('full workspace backup includes cultures + primers and round-trips',
      () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    final imageId = await _seed(src);
    await src.into(src.cultures).insert(CulturesCompanion.insert(
        id: const Value('c1'),
        name: const Value('Overnight 2407'),
        strainId: const Value('s1'),
        workspaceId: const Value(_ws)));
    await src.into(src.primers).insert(PrimersCompanion.insert(
        id: const Value('pr1'),
        name: 'M13F',
        sequence: const Value('GTAAAACGACGGCCAGT'),
        workspaceId: const Value(_ws)));
    await src.into(src.reports).insert(ReportsCompanion(
        id: const Value('rep1'),
        title: const Value('June progress'),
        recipient: const Value('Dr. Su'),
        summary: const Value('Good month.'),
        projectIds: const Value(['p1']),
        workspaceId: const Value(_ws)));
    await src.into(src.cloneConstructions).insert(CloneConstructionsCompanion(
        id: const Value('cc1'),
        name: const Value('pLT-GFP'),
        backboneStrainId: const Value('s1'),
        fragments: Value(const [CloneFragment(name: 'GFP', templateStrainId: 's2')]),
        workspaceId: const Value(_ws)));
    await src.into(src.experimentUpdates).insert(ExperimentUpdatesCompanion.insert(
        id: const Value('u1'),
        experimentId: 'e1',
        note: const Value('progress'),
        workspaceId: const Value(_ws)));
    await ImageRepository(src).updateAnnotations(imageId,
        const [ImageAnnotation(type: 'box', x1: 0.1, y1: 0.1, x2: 0.4, y2: 0.4)]);
    await ImageRepository(src).updateNotes(imageId, 'note on gel');

    final backup =
        await buildWorkspaceBackup(src, workspaceId: _ws, workspaceName: 'Lab');
    expect(backup['schemaVersion'], backupSchemaVersion);
    expect((backup['projects'] as List).length, 3); // ALL projects (incl p3)
    expect((backup['strains'] as List).length, 2); // ALL workspace strains
    expect((backup['cultures'] as List).length, 1);
    expect((backup['primers'] as List).length, 1);
    expect((backup['reports'] as List).length, 1);
    expect((backup['clone_constructions'] as List).length, 1);
    expect((backup['experiment_updates'] as List).length, 1);

    final json = _throughFile(backup);
    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);

    final summary =
        await runRestore(dst, json, RestoreMode.merge, workspaceId: _ws);
    expect(summary.skipped, 0);
    expect((await dst.select(dst.cultures).get()).length, 1);
    expect((await dst.select(dst.primers).get()).length, 1);
    final restoredReport = (await dst.select(dst.reports).get()).single;
    expect(restoredReport.title, 'June progress');
    expect(restoredReport.projectIds, ['p1']); // selection survived
    final cc = (await dst.select(dst.cloneConstructions).get()).single;
    expect(cc.name, 'pLT-GFP');
    expect(cc.fragments.single.name, 'GFP');
    expect(
        (await dst.select(dst.experimentUpdates).get()).single.note, 'progress');
    final restoredImg =
        (await dst.select(dst.images).get()).firstWhere((i) => i.id == imageId);
    expect(restoredImg.notes, 'note on gel');
    expect(restoredImg.annotations.length, 1); // annotation JSON survived
    expect((await dst.select(dst.cultures).get()).first.strainId, 's1');

    // Copies mode remaps the culture's strain reference to the copied strain.
    await runRestore(dst, json, RestoreMode.copies, workspaceId: _ws);
    final cultures = await dst.select(dst.cultures).get();
    expect(cultures.length, 2); // original + copy
    final strainIds =
        (await dst.select(dst.strains).get()).map((s) => s.id).toSet();
    for (final cu in cultures) {
      expect(cu.strainId == null || strainIds.contains(cu.strainId), isTrue);
    }
  });

  test('import as copies creates new ids with references remapped', () async {
    final src = AppDatabase(NativeDatabase.memory());
    addTearDown(src.close);
    await _seed(src);
    final json = _throughFile(
        await buildProjectBackup(src, projectIds: ['p1', 'p2'], workspaceId: _ws));

    final dst = AppDatabase(NativeDatabase.memory());
    addTearDown(dst.close);
    await runRestore(dst, json, RestoreMode.merge, workspaceId: _ws);
    final copy = await runRestore(dst, json, RestoreMode.copies, workspaceId: _ws);
    expect(copy.added, 11);

    final projects = await dst.select(dst.projects).get();
    expect(projects.length, 4); // 2 originals + 2 copies
    final projIds = projects.map((p) => p.id).toSet();
    expect(projIds.contains('p1'), isTrue); // original kept
    expect(projIds.length, 4); // copies got new ids

    // Every experiment still points at an existing project (FKs remapped).
    final exps = await dst.select(dst.experiments).get();
    expect(exps.length, 4);
    expect(exps.every((e) => projIds.contains(e.projectId)), isTrue);

    // The copied experiment's strain_ids were remapped to the copied strains.
    final strainIds = (await dst.select(dst.strains).get()).map((s) => s.id).toSet();
    for (final e in exps) {
      expect(e.strainIds.every(strainIds.contains), isTrue);
    }
    expect((await dst.select(dst.images).get()).length, 2); // copied too
  });
}
