import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';

/// Bumped with the DB schema; written into every backup so a restore can warn on
/// a mismatch. Matches [AppDatabase.schemaVersion].
const backupSchemaVersion = 26;
const backupAppTag = 'LabTrack';

/// Entity tables carried in a backup, in FK-safe restore order. Cultures
/// reference strains (so they come after strains) and images reference
/// experiments/strains/cultures (so they come last). Reports reference nothing
/// but the workspace. Older backups simply lack the newer keys, which restore
/// treats as empty.
const _restoreOrder = [
  'projects',
  'strains',
  'reagents',
  'primers',
  'reports',
  'protocols',
  'experiments',
  'manuscripts',
  'tasks',
  'cultures',
  'culture_events',
  'clone_constructions',
  'experiment_updates',
  'custom_events',
  'images',
];

enum RestoreMode {
  /// Keep ids; skip rows that already exist.
  merge,

  /// Assign new ids to everything (and remap references) — import as copies.
  copies,
}

Future<List<Map<String, dynamic>>> _selectIn(
    AppDatabase db, String table, String col, List<String> ids) async {
  if (ids.isEmpty) return [];
  final ph = List.filled(ids.length, '?').join(',');
  final rows = await db
      .customSelect('SELECT * FROM $table WHERE $col IN ($ph)',
          variables: ids.map((e) => Variable<String>(e)).toList())
      .get();
  return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
}

/// Builds a single self-contained backup of [projectIds] and everything under
/// them: experiments, tasks (by project or experiment), manuscripts, the strains
/// their experiments reference, the workspace's reagent inventory, and any image
/// attachments (captions + references, with bytes bundled when cached locally).
///
/// Scope is the current workspace: pass [workspaceId] so reagents and the export
/// are limited to it.
Future<Map<String, dynamic>> buildProjectBackup(
  AppDatabase db, {
  required List<String> projectIds,
  String? workspaceId,
  String? workspaceName,
}) async {
  final projects = await _selectIn(db, 'projects', 'id', projectIds);
  final pIds = projects.map((p) => p['id'] as String).toList();

  final experiments = await _selectIn(db, 'experiments', 'project_id', pIds);
  final eIds = experiments.map((e) => e['id'] as String).toList();
  final manuscripts = await _selectIn(db, 'manuscripts', 'project_id', pIds);

  // Tasks attached to one of these projects OR to one of their experiments.
  final taskMap = <String, Map<String, dynamic>>{};
  for (final t in [
    ...await _selectIn(db, 'tasks', 'project_id', pIds),
    ...await _selectIn(db, 'tasks', 'experiment_id', eIds),
  ]) {
    taskMap[t['id'] as String] = t;
  }
  final tasks = taskMap.values.toList();

  // Strains linked by the experiments' strain_ids.
  final strainIds = <String>{};
  for (final e in experiments) {
    try {
      final list = jsonDecode((e['strain_ids'] as String?) ?? '[]') as List;
      strainIds.addAll(list.map((x) => x.toString()));
    } catch (_) {}
  }
  final strains = await _selectIn(db, 'strains', 'id', strainIds.toList());

  // Reagents are standalone inventory (no project link) — snapshot the current
  // workspace's reagents.
  final reagents = workspaceId == null
      ? (await db.customSelect('SELECT * FROM reagents').get())
          .map((r) => Map<String, dynamic>.from(r.data))
          .toList()
      : await _selectIn(db, 'reagents', 'workspace_id', [workspaceId]);

  // Images attached to any of these experiments or strains.
  final imageMap = <String, Map<String, dynamic>>{};
  for (final im in [
    ...await _selectIn(db, 'images', 'experiment_id', eIds),
    ...await _selectIn(db, 'images', 'strain_id',
        strains.map((s) => s['id'] as String).toList()),
  ]) {
    imageMap[im['id'] as String] = im;
  }
  final images = imageMap.values.toList();

  // Bundle locally-cached image bytes (base64); leave Storage-only images as
  // references.
  var bundledAny = false;
  for (final im in images) {
    final blob = await (db.select(db.imageBlobs)
          ..where((t) => t.id.equals(im['id'] as String)))
        .getSingleOrNull();
    if (blob != null) {
      im['bytes'] = base64Encode(blob.bytes);
      bundledAny = true;
    }
  }

  return {
    'app': backupAppTag,
    'schemaVersion': backupSchemaVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'workspaceId': workspaceId,
    'workspaceName': workspaceName,
    'imageBytes': bundledAny ? 'bundled' : 'paths',
    'projects': projects,
    'experiments': experiments,
    'tasks': tasks,
    'strains': strains,
    'reagents': reagents,
    'manuscripts': manuscripts,
    'images': images,
  };
}

/// Builds a complete backup of EVERYTHING in [workspaceId] (or the whole
/// database when null): every project, experiment, task, manuscript, strain,
/// reagent, culture, primer and image attachment — image bytes bundled when
/// cached locally. This is the one-click "back up everything" snapshot offered
/// when the user closes the app. Restores through the same [runRestore] path.
Future<Map<String, dynamic>> buildWorkspaceBackup(
  AppDatabase db, {
  String? workspaceId,
  String? workspaceName,
}) async {
  Future<List<Map<String, dynamic>>> all(String table) async {
    final rows = workspaceId == null
        ? await db.customSelect('SELECT * FROM $table').get()
        : await db
            .customSelect('SELECT * FROM $table WHERE workspace_id = ?',
                variables: [Variable<String>(workspaceId)])
            .get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  final projects = await all('projects');
  final experiments = await all('experiments');
  final tasks = await all('tasks');
  final strains = await all('strains');
  final reagents = await all('reagents');
  final manuscripts = await all('manuscripts');
  final cultures = await all('cultures');
  final cultureEvents = await all('culture_events');
  final primers = await all('primers');
  final reports = await all('reports');
  final protocols = await all('protocols');
  final cloneConstructions = await all('clone_constructions');
  final experimentUpdates = await all('experiment_updates');
  final customEvents = await all('custom_events');
  final images = await all('images');

  // Bundle locally-cached image bytes (base64); Storage-only images stay as
  // references.
  var bundledAny = false;
  for (final im in images) {
    final blob = await (db.select(db.imageBlobs)
          ..where((t) => t.id.equals(im['id'] as String)))
        .getSingleOrNull();
    if (blob != null) {
      im['bytes'] = base64Encode(blob.bytes);
      bundledAny = true;
    }
  }

  return {
    'app': backupAppTag,
    'schemaVersion': backupSchemaVersion,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'workspaceId': workspaceId,
    'workspaceName': workspaceName,
    'imageBytes': bundledAny ? 'bundled' : 'paths',
    'projects': projects,
    'experiments': experiments,
    'tasks': tasks,
    'strains': strains,
    'reagents': reagents,
    'manuscripts': manuscripts,
    'cultures': cultures,
    'culture_events': cultureEvents,
    'primers': primers,
    'reports': reports,
    'protocols': protocols,
    'clone_constructions': cloneConstructions,
    'experiment_updates': experimentUpdates,
    'custom_events': customEvents,
    'images': images,
  };
}

/// What a restore would add, for the preview step.
class RestorePreview {
  RestorePreview(
      this.counts, this.existing, this.imageBytes, this.schemaVersion);

  final Map<String, int> counts; // per table
  final int existing; // rows whose id already exists locally
  final String imageBytes; // 'bundled' | 'paths'
  final int schemaVersion;

  int get total => counts.values.fold(0, (a, b) => a + b);
  bool get isCompatible => schemaVersion == backupSchemaVersion;
}

bool isLabTrackBackup(Map<String, dynamic> json) =>
    json['app'] == backupAppTag && json['schemaVersion'] is num;

Future<RestorePreview> previewRestore(
    AppDatabase db, Map<String, dynamic> json) async {
  final counts = <String, int>{};
  var existing = 0;
  for (final t in _restoreOrder) {
    final rows = (json[t] as List?)?.cast<Map>() ?? const [];
    counts[t] = rows.length;
    final ids = rows.map((r) => r['id'] as String).toList();
    if (ids.isNotEmpty) {
      final ph = List.filled(ids.length, '?').join(',');
      final found = await db
          .customSelect('SELECT id FROM $t WHERE id IN ($ph)',
              variables: ids.map((e) => Variable<String>(e)).toList())
          .get();
      existing += found.length;
    }
  }
  return RestorePreview(
    counts,
    existing,
    json['imageBytes'] as String? ?? 'paths',
    (json['schemaVersion'] as num?)?.toInt() ?? 0,
  );
}

class RestoreSummary {
  RestoreSummary(this.added, this.skipped);
  final int added;
  final int skipped;
}

String _remapStrainIds(String? raw, Map<String, String> map) {
  if (raw == null) return '[]';
  try {
    final list =
        (jsonDecode(raw) as List).map((x) => map[x.toString()] ?? x.toString());
    return jsonEncode(list.toList());
  } catch (_) {
    return raw;
  }
}

/// Restores [json] into [db]. In [RestoreMode.merge], rows whose id already
/// exists are skipped; in [RestoreMode.copies], every row gets a fresh id and
/// all references are remapped. Restored rows are re-tagged to [workspaceId]
/// (the current workspace).
Future<RestoreSummary> runRestore(
  AppDatabase db,
  Map<String, dynamic> json,
  RestoreMode mode, {
  String? workspaceId,
}) async {
  // New-id maps (copies mode).
  final idMaps = <String, Map<String, String>>{
    for (final t in _restoreOrder) t: {}
  };
  if (mode == RestoreMode.copies) {
    for (final t in _restoreOrder) {
      for (final r in (json[t] as List?)?.cast<Map>() ?? const []) {
        idMaps[t]![r['id'] as String] = uuid.v4();
      }
    }
  }

  final allowed = <String, Set<String>>{
    'projects': db.projects.$columns.map((c) => c.name).toSet(),
    'experiments': db.experiments.$columns.map((c) => c.name).toSet(),
    'tasks': db.tasks.$columns.map((c) => c.name).toSet(),
    'strains': db.strains.$columns.map((c) => c.name).toSet(),
    'reagents': db.reagents.$columns.map((c) => c.name).toSet(),
    'manuscripts': db.manuscripts.$columns.map((c) => c.name).toSet(),
    'cultures': db.cultures.$columns.map((c) => c.name).toSet(),
    'culture_events': db.cultureEvents.$columns.map((c) => c.name).toSet(),
    'primers': db.primers.$columns.map((c) => c.name).toSet(),
    'reports': db.reports.$columns.map((c) => c.name).toSet(),
    'protocols': db.protocols.$columns.map((c) => c.name).toSet(),
    'clone_constructions':
        db.cloneConstructions.$columns.map((c) => c.name).toSet(),
    'experiment_updates':
        db.experimentUpdates.$columns.map((c) => c.name).toSet(),
    'custom_events': db.customEvents.$columns.map((c) => c.name).toSet(),
    'images': db.images.$columns.map((c) => c.name).toSet(),
  };

  String mapId(String table, Object? old) =>
      old == null ? '' : (idMaps[table]![old as String] ?? old);

  var added = 0, skipped = 0;
  await db.transaction(() async {
    for (final t in _restoreOrder) {
      for (final raw in (json[t] as List?)?.cast<Map>() ?? const []) {
        final row = Map<String, dynamic>.from(raw);
        final base64bytes = row.remove('bytes') as String?; // images only

        if (mode == RestoreMode.copies) {
          row['id'] = idMaps[t]![row['id'] as String];
          switch (t) {
            case 'experiments':
              if (row['project_id'] != null) {
                row['project_id'] = mapId('projects', row['project_id']);
              }
              row['strain_ids'] =
                  _remapStrainIds(row['strain_ids'] as String?, idMaps['strains']!);
            case 'tasks':
              if (row['project_id'] != null) {
                row['project_id'] = mapId('projects', row['project_id']);
              }
              if (row['experiment_id'] != null) {
                row['experiment_id'] = mapId('experiments', row['experiment_id']);
              }
            case 'manuscripts':
              if (row['project_id'] != null) {
                row['project_id'] = mapId('projects', row['project_id']);
              }
            case 'cultures':
              if (row['strain_id'] != null) {
                row['strain_id'] = mapId('strains', row['strain_id']);
              }
              if (row['parent_culture_id'] != null) {
                row['parent_culture_id'] =
                    mapId('cultures', row['parent_culture_id']);
              }
            case 'culture_events':
              if (row['culture_id'] != null) {
                row['culture_id'] = mapId('cultures', row['culture_id']);
              }
            case 'images':
              if (row['experiment_id'] != null) {
                row['experiment_id'] = mapId('experiments', row['experiment_id']);
              }
              if (row['strain_id'] != null) {
                row['strain_id'] = mapId('strains', row['strain_id']);
              }
              if (row['culture_id'] != null) {
                row['culture_id'] = mapId('cultures', row['culture_id']);
              }
          }
        }

        if (workspaceId != null && allowed[t]!.contains('workspace_id')) {
          row['workspace_id'] = workspaceId;
        }

        final id = row['id'] as String;
        if (mode == RestoreMode.merge) {
          final exists = await db
              .customSelect('SELECT 1 FROM $t WHERE id = ?',
                  variables: [Variable<String>(id)])
              .getSingleOrNull();
          if (exists != null) {
            skipped++;
            continue;
          }
        }

        final cols = row.keys.where(allowed[t]!.contains).toList();
        final ph = List.filled(cols.length, '?').join(', ');
        await db.customStatement(
          'INSERT INTO $t (${cols.join(', ')}) VALUES ($ph)',
          cols.map((c) => row[c]).toList(),
        );
        added++;

        if (t == 'images' && base64bytes != null) {
          await db.into(db.imageBlobs).insert(
                ImageBlobsCompanion.insert(
                    id: id, bytes: base64Decode(base64bytes)),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    }
  });
  return RestoreSummary(added, skipped);
}
