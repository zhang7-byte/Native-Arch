import 'package:drift/drift.dart';

import 'database.dart';
import 'sync/tombstone_writer.dart';

// Stable seed ids: UUID v5 derived from the spec's placeholder ref, so two
// independent fresh installs generate identical ids for seed rows. Sync then
// deduplicates them by last-writer-wins instead of creating duplicates.
const _seedNamespace = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';
String _seedId(String ref) => uuid.v5(_seedNamespace, 'labtrack:$ref');

/// Seed rows carry a fixed OLD timestamp so demonstration data always LOSES the
/// snapshot last-writer-wins sync — a fresh device pulls the real data instead of
/// pushing its seed over it.
final _seedDate = DateTime.utc(2000, 1, 1);

/// `sync_meta` flag set once the user removes the demonstration data, so the
/// idempotent re-seed (which would otherwise refill an emptied table on the next
/// launch) stays off permanently. Device-local — not synced.
const seedDisabledKey = 'seed_disabled';

/// Whether the user has removed the demonstration data on this device.
Future<bool> isSeedDisabled(AppDatabase db) async {
  final row = await (db.select(db.syncMeta)
        ..where((t) => t.key.equals(seedDisabledKey)))
      .getSingleOrNull();
  return row?.value == '1';
}

/// `sync_meta` flag set once the user has answered the first-run "include
/// demonstration data?" prompt, so it's only ever asked once. Device-local.
const seedDecidedKey = 'seed_decided';

/// True between startup and the user answering the first-run demo-data prompt
/// (set by [resolveDemoData], cleared by [setSeedDecision]). The HomeShell reads
/// it to show the one-time prompt on a brand-new install.
bool demoDataUndecided = false;

Future<String?> _meta(AppDatabase db, String key) async {
  final row = await (db.select(db.syncMeta)..where((t) => t.key.equals(key)))
      .getSingleOrNull();
  return row?.value;
}

Future<void> _setMeta(AppDatabase db, String key, String value) =>
    db.into(db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: key, value: value));

/// Decides what to do about demonstration data at startup. An EXISTING install
/// keeps the previous behaviour (ensure the demo rows unless the user removed
/// them); a brand-new, empty install defers seeding until the user answers the
/// first-run prompt (signalled via [demoDataUndecided]).
Future<void> resolveDemoData(AppDatabase db) async {
  if (await isSeedDisabled(db)) return; // already removed/declined — never seed
  final decided = (await _meta(db, seedDecidedKey)) == '1';
  final hasProjects = (await db.select(db.projects).get()).isNotEmpty;
  if (decided || hasProjects) {
    if (!decided) await _setMeta(db, seedDecidedKey, '1');
    await seedDatabase(db); // idempotent; no-op when seeding is disabled
  } else {
    demoDataUndecided = true; // ask before seeding
  }
}

/// Records the user's first-run demonstration-data choice. When [include] is
/// false it sets the same "seed disabled" flag the Remove action uses, so the
/// data is never seeded later.
Future<void> setSeedDecision(AppDatabase db, {required bool include}) async {
  await _setMeta(db, seedDecidedKey, '1');
  await _setMeta(db, seedDisabledKey, include ? '' : '1');
  if (include) await seedDatabase(db);
  demoDataUndecided = false;
}

/// One seed project from SPEC.md Section 4. `ref` is the spec's placeholder id
/// (e.g. "prj-001"); a stable UUID is derived from it and foreign keys are
/// wired to that UUID.
typedef _SeedProject = ({
  String ref,
  String title,
  String description,
  ProjectStatus status,
  Priority priority,
  List<String> tags,
});

/// One seed experiment from SPEC.md Section 4. `projectRef` points at a
/// `_SeedProject.ref`; `strainIds` are the spec's placeholder strain ids, kept
/// as-is until Stage 4 loads the strains.
typedef _SeedExperiment = ({
  String ref,
  String projectRef,
  String title,
  String hypothesis,
  ExperimentStatus status,
  List<String> strainIds,
  String protocolRef,
  String resultsNotes,
  List<String> dataLinks,
});

const List<_SeedProject> _seedProjects = [
  (
    ref: 'prj-001',
    title: 'Constrained AID degron (cAID)',
    description:
        "mIAA7 embedded within GFP's exposed loop after E172, constraining the degron so it only triggers turnover on auxin. Validated in Y. lipolytica using an RFP nanobody and the carotenoid enzyme CrtW as targets.",
    status: ProjectStatus.manuscript_prep,
    priority: Priority.high,
    tags: ['AID2', 'GFP', 'mIAA7', 'Yarrowia'],
  ),
  (
    ref: 'prj-002',
    title: 'dGFP degron-core mutant screen',
    description:
        'Screen of six mIAA7 degron-core variants on p5219 (V2A, P7G, V8A, V8G, R9A, R9K), measuring leaky degradation, fold integrity, and IAA induction efficiency. Readouts: GFP fluorescence spectra and OD-normalized degradation kinetics.',
    status: ProjectStatus.active,
    priority: Priority.high,
    tags: ['dGFP', 'AID2', 'p5219', 'kinetics'],
  ),
  (
    ref: 'prj-003',
    title: 'PFOA biosorption via hLFABP surface display',
    description:
        'Engineered Y. lipolytica displaying GFP-hLFABP for PFOA bioremediation. PFOA removal quantified by LC-MS/MS, analysed with ANOVA and Tukey HSD.',
    status: ProjectStatus.active,
    priority: Priority.medium,
    tags: ['PFOA', 'biosorption', 'hLFABP', 'Yarrowia'],
  ),
  (
    ref: 'prj-004',
    title: 'Self-excising polyprotein cassette',
    description:
        'Split-intein polyprotein cassette combined with AID2. Includes the split-intein AND-gate concept (Route 2: PTS controls whether the degron connects to the target protein, rather than splitting the degron core) and a dTAG feasibility path for plant deployment.',
    status: ProjectStatus.planning,
    priority: Priority.medium,
    tags: ['intein', 'AND-gate', 'AID2', 'dTAG'],
  ),
  (
    ref: 'prj-005',
    title: 'Cyanobacterial intein genome scan',
    description:
        'Scanning cyanobacterial genomes (Nostoc commune, N. flagelliforme, Aphanizomenon flos-aquae, Arthrospira platensis FACHB-835) for inteins. Found DnaE split inteins conserved across all three cyanobacteria scanned, DnaB/DnaX contiguous inteins in both Nostoc species, and a novel NrdJ maxi-intein in N. commune. Structural mini-intein trimming followed.',
    status: ProjectStatus.active,
    priority: Priority.medium,
    tags: ['intein', 'DnaE', 'DnaB', 'mini-intein'],
  ),
  (
    ref: 'prj-006',
    title: 'De novo USP7 binder design',
    description:
        'De novo binder design targeting USP7 (PDB 1NBF) using RFdiffusion, ProteinMPNN, and AF2-Multimer, with PyMOL hotspot analysis. Runs on the RTX 5090 workstation.',
    status: ProjectStatus.active,
    priority: Priority.medium,
    tags: ['USP7', 'RFdiffusion', 'ProteinMPNN', 'binder'],
  ),
];

const List<_SeedExperiment> _seedExperiments = [
  (
    ref: 'exp-001',
    projectRef: 'prj-002',
    title: 'GFP fluorescence spectra, dGFP variants',
    hypothesis:
        'Degron-core mutations shift baseline GFP folding/brightness in the absence of IAA.',
    status: ExperimentStatus.done,
    strainIds: ['str-2419', 'str-2542'],
    protocolRef: 'Plate-reader emission scan',
    resultsNotes: '',
    dataLinks: [],
  ),
  (
    ref: 'exp-002',
    projectRef: 'prj-002',
    title: 'OD-normalized degradation kinetics, strains 2419 and 2542',
    hypothesis:
        'IAA induction drives dGFP turnover; rate varies by degron-core variant.',
    status: ExperimentStatus.running,
    strainIds: ['str-2419', 'str-2542'],
    protocolRef: 'Time-course GFP signal / OD600',
    resultsNotes: '',
    dataLinks: [],
  ),
  (
    ref: 'exp-003',
    projectRef: 'prj-002',
    title: 'Anti-FLAG Western, liberation QC gate',
    hypothesis:
        'Degron liberation from the fusion is intact before kinetics are trusted.',
    status: ExperimentStatus.planned,
    strainIds: ['str-2542'],
    protocolRef: 'SDS-PAGE + anti-FLAG blot',
    resultsNotes: 'Gate: pass before accepting CHX-chase data.',
    dataLinks: [],
  ),
  (
    ref: 'exp-004',
    projectRef: 'prj-003',
    title: 'PFOA biosorption pilot, LC-MS/MS',
    hypothesis: 'GFP-hLFABP surface display increases PFOA removal vs control.',
    status: ExperimentStatus.done,
    strainIds: [],
    protocolRef: 'Biosorption assay + LC-MS/MS',
    resultsNotes: 'Analysed with ANOVA and Tukey HSD.',
    dataLinks: [],
  ),
  (
    ref: 'exp-005',
    projectRef: 'prj-005',
    title: 'Mini-intein trimming, NFL1 DnaB',
    hypothesis: 'HEN-domain deletion yields a folded 137 aa mini-intein.',
    status: ExperimentStatus.done,
    strainIds: [],
    protocolRef: 'pLDDT-guided Cα analysis on CIF/PDB',
    resultsNotes: 'Top candidate: NFL1 DnaB, 137 aa, avg pLDDT 94.9.',
    dataLinks: [],
  ),
  (
    ref: 'exp-006',
    projectRef: 'prj-006',
    title: 'USP7 hotspot selection',
    hypothesis: 'Surface hotspots on 1NBF define a designable binding patch.',
    status: ExperimentStatus.running,
    strainIds: [],
    protocolRef: 'PyMOL hotspot analysis on PDB 1NBF',
    resultsNotes: '',
    dataLinks: [],
  ),
];

/// One seed strain from SPEC.md Section 4. `ref` is the spec's placeholder id
/// (e.g. "str-2419") that seeded experiments reference in their `strain_ids`.
typedef _SeedStrain = ({
  String ref,
  String name,
  String hostOrganism,
  String genotype,
  String plasmid,
  String constructNotes,
  String freezerLocation,
  String notes,
});

const List<_SeedStrain> _seedStrains = [
  (
    ref: 'str-2407',
    name: '2407',
    hostOrganism: 'Yarrowia lipolytica',
    genotype: 'VERIFY',
    plasmid: '',
    constructNotes: 'dGFP reference strain',
    freezerLocation: '',
    notes: '',
  ),
  (
    ref: 'str-2419',
    name: '2419',
    hostOrganism: 'Yarrowia lipolytica',
    genotype: 'VERIFY',
    plasmid: 'p5219',
    constructNotes: 'IAA-inducible AID2 + dGFP variant',
    freezerLocation: '',
    notes: '',
  ),
  (
    ref: 'str-2542',
    name: '2542',
    hostOrganism: 'Yarrowia lipolytica',
    genotype: 'VERIFY',
    plasmid: 'p5219',
    constructNotes: 'IAA-inducible AID2 + dGFP variant',
    freezerLocation: '',
    notes: '',
  ),
  (
    ref: 'str-2904',
    name: '2904',
    hostOrganism: 'Yarrowia lipolytica',
    genotype: 'VERIFY',
    plasmid: '',
    constructNotes: 'dGFP kinetics strain',
    freezerLocation: '',
    notes: '',
  ),
];

/// Loads the SPEC.md Section 4 seed data. Idempotent and table-by-table, so each
/// stage's new seed batch is added even to a database created by an earlier
/// stage, and nothing is duplicated on later launches. Runs in one transaction.
Future<void> seedDatabase(AppDatabase db) async {
  // Respect an explicit "remove demonstration data" — never refill afterwards.
  if (await isSeedDisabled(db)) return;
  await db.transaction(() async {
    // Projects — insert if none, then map each spec ref to its row id (by title
    // for projects seeded on a previous run).
    final idForRef = <String, String>{};
    final existingProjects = await db.select(db.projects).get();
    if (existingProjects.isEmpty) {
      for (final p in _seedProjects) {
        final id = _seedId(p.ref);
        idForRef[p.ref] = id;
        await db.into(db.projects).insert(
              ProjectsCompanion.insert(
                id: Value(id),
                title: p.title,
                description: Value(p.description),
                status: Value(p.status),
                priority: Value(p.priority),
                tags: Value(p.tags),
                createdAt: Value(_seedDate),
                updatedAt: Value(_seedDate),
              ),
            );
      }
    } else {
      final idByTitle = {for (final row in existingProjects) row.title: row.id};
      for (final p in _seedProjects) {
        final id = idByTitle[p.title];
        if (id != null) idForRef[p.ref] = id;
      }
    }

    // Manuscript ms-001 -> prj-001 (keep the foreign key intact).
    final hasManuscripts = (await db.select(db.manuscripts).get()).isNotEmpty;
    if (!hasManuscripts && idForRef.containsKey('prj-001')) {
      await db.into(db.manuscripts).insert(
            ManuscriptsCompanion.insert(
              id: Value(_seedId('ms-001')),
              projectId: idForRef['prj-001']!,
              title:
                  'Constrained AID degron for tunable protein depletion in Yarrowia lipolytica',
              targetJournal: const Value('ACS Synthetic Biology'),
              status: const Value(ManuscriptStatus.accepted),
              submissionId: const Value('sb-2025-009706.R1'),
              notes: const Value('Accepted after first revision.'),
              createdAt: Value(_seedDate),
              updatedAt: Value(_seedDate),
            ),
          );
    }

    // Experiments, wired to their project's id. Skips any whose parent project
    // can't be resolved (e.g. a seed project was renamed) rather than failing.
    final hasExperiments = (await db.select(db.experiments).get()).isNotEmpty;
    if (!hasExperiments) {
      for (final e in _seedExperiments) {
        final projectId = idForRef[e.projectRef];
        if (projectId == null) continue;
        await db.into(db.experiments).insert(
              ExperimentsCompanion.insert(
                id: Value(_seedId(e.ref)),
                projectId: projectId,
                title: e.title,
                hypothesis: Value(e.hypothesis),
                status: Value(e.status),
                strainIds: Value(e.strainIds),
                protocolRef: Value(e.protocolRef),
                resultsNotes: Value(e.resultsNotes),
                dataLinks: Value(e.dataLinks),
                createdAt: Value(_seedDate),
                updatedAt: Value(_seedDate),
              ),
            );
      }
    }

    // Strains.
    final existingStrains = await db.select(db.strains).get();
    if (existingStrains.isEmpty) {
      for (final s in _seedStrains) {
        await db.into(db.strains).insert(
              StrainsCompanion.insert(
                id: Value(_seedId(s.ref)),
                name: s.name,
                hostOrganism: Value(s.hostOrganism),
                genotype: Value(s.genotype),
                plasmid: Value(s.plasmid),
                constructNotes: Value(s.constructNotes),
                freezerLocation: Value(s.freezerLocation),
                notes: Value(s.notes),
                createdAt: Value(_seedDate),
                updatedAt: Value(_seedDate),
              ),
            );
      }
    }

    // Resolve experiment strain_ids: replace the spec's placeholder strain refs
    // (e.g. "str-2419") with the real strain UUIDs, matched by strain name.
    // Idempotent — once resolved the ids are UUIDs and no longer match a ref.
    final strainIdByName = {
      for (final row in await db.select(db.strains).get()) row.name: row.id,
    };
    final strainIdForRef = <String, String>{};
    for (final s in _seedStrains) {
      final id = strainIdByName[s.name];
      if (id != null) strainIdForRef[s.ref] = id;
    }
    if (strainIdForRef.isNotEmpty) {
      for (final e in await db.select(db.experiments).get()) {
        if (e.strainIds.any(strainIdForRef.containsKey)) {
          final resolved =
              e.strainIds.map((id) => strainIdForRef[id] ?? id).toList();
          await (db.update(db.experiments)..where((t) => t.id.equals(e.id)))
              .write(ExperimentsCompanion(
                  strainIds: Value(resolved), updatedAt: Value(_seedDate)));
        }
      }
    }

    // One-time: re-stamp seed rows left by an older build (which seeded with a
    // "now" timestamp) to the fixed old date, so demonstration data can never win
    // the last-writer-wins snapshot sync on an already-seeded device.
    final fixed = await (db.select(db.syncMeta)
          ..where((t) => t.key.equals('seed_dates_fixed')))
        .getSingleOrNull();
    if (fixed == null) {
      final seedIds = <String>{
        for (final p in _seedProjects) _seedId(p.ref),
        for (final e in _seedExperiments) _seedId(e.ref),
        for (final s in _seedStrains) _seedId(s.ref),
        _seedId('ms-001'),
      };
      final old = _seedDate.toIso8601String();
      for (final table in const [
        'projects',
        'experiments',
        'strains',
        'manuscripts'
      ]) {
        for (final id in seedIds) {
          await db.customStatement(
            'UPDATE $table SET updated_at = ?, created_at = ? WHERE id = ?',
            [old, old, id],
          );
        }
      }
      await db.into(db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: 'seed_dates_fixed', value: '1'));
    }
  });
}

/// Removes the SPEC.md demonstration data — the seed projects (and the
/// experiments, tasks, manuscripts and images that cascade from them) and the
/// seed strains — identified by their stable seed ids, so the user's own rows
/// are untouched. Records tombstones so the deletion propagates during sync, and
/// sets [seedDisabledKey] so the data is never re-seeded. Returns the number of
/// rows removed. Idempotent: a second call finds nothing and removes 0.
Future<int> removeSeedData(AppDatabase db) async {
  final seedProjectIds = _seedProjects.map((p) => _seedId(p.ref)).toList();
  final seedStrainIds = _seedStrains.map((s) => _seedId(s.ref)).toList();
  var removed = 0;

  await db.transaction(() async {
    // Seed projects that still exist (the user may have deleted some already).
    final projectIds = (await (db.select(db.projects)
              ..where((t) => t.id.isIn(seedProjectIds)))
            .get())
        .map((p) => p.id)
        .toList();

    final expIds = projectIds.isEmpty
        ? <String>[]
        : (await (db.select(db.experiments)
                  ..where((t) => t.projectId.isIn(projectIds)))
                .get())
            .map((e) => e.id)
            .toList();

    final taskIds = projectIds.isEmpty
        ? <String>[]
        : (await (db.select(db.tasks)
                  ..where((t) {
                    final byProject = t.projectId.isIn(projectIds);
                    return expIds.isEmpty
                        ? byProject
                        : byProject | t.experimentId.isIn(expIds);
                  }))
                .get())
            .map((t) => t.id)
            .toList();

    final msIds = projectIds.isEmpty
        ? <String>[]
        : (await (db.select(db.manuscripts)
                  ..where((t) => t.projectId.isIn(projectIds)))
                .get())
            .map((m) => m.id)
            .toList();

    // Seed strains that still exist (project-independent inventory).
    final strainIds = (await (db.select(db.strains)
              ..where((t) => t.id.isIn(seedStrainIds)))
            .get())
        .map((s) => s.id)
        .toList();

    // Images cascade-deleted with those experiments or strains.
    final imageIds = <String>[];
    if (expIds.isNotEmpty) {
      imageIds.addAll((await (db.select(db.images)
                ..where((t) => t.experimentId.isIn(expIds)))
              .get())
          .map((i) => i.id));
    }
    if (strainIds.isNotEmpty) {
      imageIds.addAll((await (db.select(db.images)
                ..where((t) => t.strainId.isIn(strainIds)))
              .get())
          .map((i) => i.id));
    }

    if (projectIds.isNotEmpty) {
      await (db.delete(db.projects)..where((t) => t.id.isIn(projectIds))).go();
    }
    if (strainIds.isNotEmpty) {
      await (db.delete(db.strains)..where((t) => t.id.isIn(strainIds))).go();
    }

    await writeTombstones(db, {
      for (final id in projectIds) id: 'projects',
      for (final id in expIds) id: 'experiments',
      for (final id in taskIds) id: 'tasks',
      for (final id in msIds) id: 'manuscripts',
      for (final id in strainIds) id: 'strains',
      for (final id in imageIds) id: 'images',
    });

    removed = projectIds.length +
        expIds.length +
        taskIds.length +
        msIds.length +
        strainIds.length +
        imageIds.length;

    // Never re-seed after an explicit removal.
    await db.into(db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: seedDisabledKey, value: '1'));
  });

  return removed;
}
