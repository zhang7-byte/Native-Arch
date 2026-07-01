import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/data/seed.dart';

void main() {
  test('first-run seed loads 6 projects + 1 manuscript with the FK intact',
      () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);

    final projects = await db.select(db.projects).get();
    expect(projects, hasLength(6));

    final manuscripts = await db.select(db.manuscripts).get();
    expect(manuscripts, hasLength(1));

    // The manuscript's project_id must resolve to the seeded cAID project.
    final ms = manuscripts.single;
    final parent = await (db.select(db.projects)
          ..where((t) => t.id.equals(ms.projectId)))
        .getSingleOrNull();
    expect(parent, isNotNull);
    expect(parent!.title, 'Constrained AID degron (cAID)');
    expect(ms.submissionId, 'sb-2025-009706.R1');
    expect(ms.status, ManuscriptStatus.accepted);
  });

  test('seed maps statuses, priorities and tags from SPEC.md', () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);

    final byTitle = {
      for (final p in await db.select(db.projects).get()) p.title: p,
    };

    final caid = byTitle['Constrained AID degron (cAID)']!;
    expect(caid.status, ProjectStatus.manuscript_prep);
    expect(caid.priority, Priority.high);
    expect(caid.tags, ['AID2', 'GFP', 'mIAA7', 'Yarrowia']);

    expect(byTitle['Self-excising polyprotein cassette']!.status,
        ProjectStatus.planning);
    expect(byTitle['De novo USP7 binder design']!.priority, Priority.medium);
  });

  test('seed loads 6 experiments wired to their projects, with strain ids',
      () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);

    final experiments = await db.select(db.experiments).get();
    expect(experiments, hasLength(6));

    final projectIdByTitle = {
      for (final p in await db.select(db.projects).get()) p.title: p.id,
    };

    final spectra = experiments
        .firstWhere((e) => e.title == 'GFP fluorescence spectra, dGFP variants');
    expect(spectra.projectId, projectIdByTitle['dGFP degron-core mutant screen']);
    // Two strains; the placeholder refs are resolved to real ids (see the
    // strain-resolution test below).
    expect(spectra.strainIds, hasLength(2));
    expect(spectra.status, ExperimentStatus.done);

    // Every seeded experiment points at a real project.
    final projectIds = projectIdByTitle.values.toSet();
    expect(experiments.every((e) => projectIds.contains(e.projectId)), isTrue);
  });

  test('seed loads 4 strains and resolves experiment strain_ids to real ids',
      () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);

    final strains = await db.select(db.strains).get();
    expect(
        strains.map((s) => s.name).toSet(), {'2407', '2419', '2542', '2904'});

    final strainIdByName = {for (final s in strains) s.name: s.id};

    final spectra = (await db.select(db.experiments).get()).firstWhere(
        (e) => e.title == 'GFP fluorescence spectra, dGFP variants');
    // The placeholder refs str-2419 / str-2542 were resolved to real UUIDs.
    expect(spectra.strainIds.toSet(),
        {strainIdByName['2419'], strainIdByName['2542']});
    expect(spectra.strainIds.any((id) => id.startsWith('str-')), isFalse);
  });

  test('seeding does not run when the seed flag is false', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(await db.select(db.projects).get(), isEmpty);
    expect(await db.select(db.experiments).get(), isEmpty);
    expect(await db.select(db.strains).get(), isEmpty);
  });

  test('removeSeedData deletes the demo rows and disables re-seeding', () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);
    expect((await db.select(db.projects).get()).length, 6);

    final removed = await removeSeedData(db);
    // 6 projects + 6 experiments + 1 manuscript + 4 strains.
    expect(removed, 17);
    expect(await db.select(db.projects).get(), isEmpty);
    expect(await db.select(db.experiments).get(), isEmpty);
    expect(await db.select(db.manuscripts).get(), isEmpty);
    expect(await db.select(db.strains).get(), isEmpty);
    expect(await isSeedDisabled(db), isTrue);

    // Tombstones recorded so the deletion propagates during sync.
    expect((await db.select(db.tombstones).get()).length, removed);

    // Re-seeding is now permanently off, even on an emptied database.
    await seedDatabase(db);
    expect(await db.select(db.projects).get(), isEmpty);

    // Idempotent: a second removal finds nothing.
    expect(await removeSeedData(db), 0);
  });

  test("removeSeedData keeps the user's own rows", () async {
    final db = AppDatabase(NativeDatabase.memory(), true);
    addTearDown(db.close);
    await db
        .into(db.projects)
        .insert(ProjectsCompanion.insert(title: 'My real project'));
    await db.into(db.strains).insert(StrainsCompanion.insert(name: 'My strain'));

    await removeSeedData(db);

    expect((await db.select(db.projects).get()).map((p) => p.title),
        ['My real project']);
    expect((await db.select(db.strains).get()).map((s) => s.name),
        ['My strain']);
  });
}
