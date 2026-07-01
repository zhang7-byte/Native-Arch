import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'sync/tombstone_writer.dart';
import 'workspace_repository.dart';

/// Child relations to capture when an entity is trashed: parent table -> list of
/// (child table, foreign-key column). Mirrors the DB's ON DELETE CASCADE graph,
/// so the whole subtree is snapshotted before the hard delete.
const _cascade = <String, List<(String, String)>>{
  'projects': [
    ('experiments', 'project_id'),
    ('tasks', 'project_id'),
    ('manuscripts', 'project_id'),
  ],
  'experiments': [
    ('tasks', 'experiment_id'),
    ('experiment_updates', 'experiment_id'),
    ('images', 'experiment_id'),
  ],
  'experiment_updates': [
    ('images', 'update_id'),
  ],
  'strains': [
    ('images', 'strain_id'),
  ],
  'cultures': [
    ('images', 'culture_id'),
    ('culture_events', 'culture_id'),
  ],
  'reports': [
    ('images', 'report_id'),
  ],
};

/// Human label for each trashable table.
const _kind = <String, String>{
  'projects': 'Project',
  'experiments': 'Experiment',
  'tasks': 'Task',
  'strains': 'Strain',
  'reagents': 'Reagent',
  'manuscripts': 'Manuscript',
  'cultures': 'Culture',
  'primers': 'Primer',
  'reports': 'Report',
  'clone_constructions': 'Construction',
  'experiment_updates': 'Update',
  'custom_events': 'Event',
  'culture_events': 'Culture log',
  'images': 'Image',
};

/// FK-safe order to re-insert captured rows on restore.
const _restoreOrder = [
  'projects',
  'strains',
  'reagents',
  'primers',
  'reports',
  'clone_constructions',
  'experiments',
  'manuscripts',
  'tasks',
  'cultures',
  'experiment_updates',
  'custom_events',
  'culture_events',
  'images',
];

/// Reversible deletion via a local Trash buffer. [trash] snapshots the full
/// cascade subtree (rows + image bytes) into `trash_entries`, then hard-deletes
/// and tombstones it (so the deletion still propagates on sync). [restore]
/// re-inserts the snapshot and removes those tombstones.
class TrashRepository {
  TrashRepository(this._db);

  final AppDatabase _db;

  Stream<List<TrashEntry>> watchAll() => _db
      .customSelect(
        'SELECT * FROM trash_entries WHERE $workspaceScopeWhere '
        'ORDER BY deleted_at DESC',
        readsFrom: {_db.trashEntries, _db.syncMeta},
      )
      .watch()
      .map((rows) => rows.map((r) => _db.trashEntries.map(r.data)).toList());

  static bool canTrash(String table) => _kind.containsKey(table);

  /// Moves [table]/[id] (and its cascade subtree) to the Trash. Returns the new
  /// trash-entry id, or null if the row doesn't exist.
  Future<String?> trash(String table, String id) async {
    final touched = <String>{};
    final entryId = await _db.transaction(() async {
      // table -> { rowId -> rowMap }, gathered depth-first.
      final acc = <String, Map<String, Map<String, dynamic>>>{};
      Future<void> gather(String t, Map<String, dynamic> row) async {
        final rid = row['id'] as String;
        (acc[t] ??= {})[rid] = row;
        for (final (childTable, fk) in _cascade[t] ?? const <(String, String)>[]) {
          final children = await _db
              .customSelect('SELECT * FROM $childTable WHERE $fk = ?',
                  variables: [Variable<String>(rid)])
              .get();
          for (final c in children) {
            final cm = Map<String, dynamic>.from(c.data);
            if (acc[childTable]?.containsKey(cm['id']) ?? false) continue;
            await gather(childTable, cm);
          }
        }
      }

      final top = await _db
          .customSelect('SELECT * FROM $table WHERE id = ?',
              variables: [Variable<String>(id)])
          .getSingleOrNull();
      if (top == null) return null;
      final topRow = Map<String, dynamic>.from(top.data);
      await gather(table, topRow);

      // Capture image bytes for any images in the subtree.
      final blobs = <String, String>{};
      for (final imgId in acc['images']?.keys ?? const <String>[]) {
        final b = await (_db.select(_db.imageBlobs)
              ..where((t) => t.id.equals(imgId)))
            .getSingleOrNull();
        if (b != null) blobs[imgId] = base64Encode(b.bytes);
      }

      final tablesJson = {
        for (final e in acc.entries) e.key: e.value.values.toList()
      };
      final payload = jsonEncode({'tables': tablesJson, 'blobs': blobs});

      final ws = (topRow['workspace_id'] as String?) ?? '';
      final entryId = uuid.v4();
      await _db.into(_db.trashEntries).insert(TrashEntriesCompanion.insert(
            id: Value(entryId),
            entityTable: table,
            entityId: id,
            kind: Value(_kind[table] ?? ''),
            label: Value((topRow['title'] ??
                    topRow['name'] ??
                    topRow['caption'] ??
                    '')
                .toString()),
            payload: payload,
            workspaceId: Value(ws.isEmpty
                ? (await currentWorkspaceId(_db) ?? '')
                : ws),
          ));

      // Hard delete (cascade removes children + their blobs) + tombstones.
      final tombstones = <String, String>{
        for (final e in acc.entries)
          for (final rid in e.value.keys) rid: e.key
      };
      await _db.customStatement('DELETE FROM $table WHERE id = ?', [id]);
      await writeTombstones(_db, tombstones);
      touched
        ..addAll(acc.keys)
        ..add('image_blobs');
      return entryId;
    });
    // Raw SQL above doesn't tell drift which tables changed — notify so the
    // affected list streams refresh.
    if (entryId != null) {
      _db.notifyUpdates(
          {for (final t in touched) TableUpdate(t, kind: UpdateKind.delete)});
    }
    return entryId;
  }

  /// Re-inserts the snapshot for [trashEntryId] and clears its tombstones.
  Future<void> restore(String trashEntryId) async {
    final entry = await (_db.select(_db.trashEntries)
          ..where((t) => t.id.equals(trashEntryId)))
        .getSingleOrNull();
    if (entry == null) return;
    final data = jsonDecode(entry.payload) as Map<String, dynamic>;
    final tables = (data['tables'] as Map?)?.cast<String, dynamic>() ?? {};
    final blobs = (data['blobs'] as Map?)?.cast<String, dynamic>() ?? {};
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final touched = <String>{};

    await _db.transaction(() async {
      final restoredIds = <String>[];
      for (final table in _restoreOrder) {
        final rows = (tables[table] as List?) ?? const [];
        if (rows.isEmpty) continue;
        touched.add(table);
        for (final raw in rows) {
          final row = Map<String, dynamic>.from(raw as Map);
          // Refresh updated_at so a synced row resurfaces (wins over its old
          // server state) rather than looking stale.
          if (row.containsKey('updated_at')) row['updated_at'] = nowIso;
          final cols = row.keys.toList();
          final ph = List.filled(cols.length, '?').join(', ');
          await _db.customStatement(
            'INSERT OR REPLACE INTO $table (${cols.join(', ')}) VALUES ($ph)',
            cols.map((c) => row[c]).toList(),
          );
          restoredIds.add(row['id'] as String);
        }
      }
      for (final e in blobs.entries) {
        await _db.customStatement(
            'INSERT OR REPLACE INTO image_blobs (id, bytes) VALUES (?, ?)',
            [e.key, base64Decode(e.value as String)]);
      }
      if (blobs.isNotEmpty) touched.add('image_blobs');
      if (restoredIds.isNotEmpty) {
        final ph = List.filled(restoredIds.length, '?').join(',');
        await _db.customStatement(
            'DELETE FROM tombstones WHERE id IN ($ph)', restoredIds);
        touched.add('tombstones');
      }
      await (_db.delete(_db.trashEntries)
            ..where((t) => t.id.equals(trashEntryId)))
          .go();
    });
    // Raw INSERTs/DELETE above bypass drift's stream tracking — notify so the
    // restored rows reappear in live lists.
    _db.notifyUpdates(
        {for (final t in touched) TableUpdate(t, kind: UpdateKind.insert)});
  }

  /// Permanently removes one trash entry (the rows are already gone).
  Future<void> purge(String trashEntryId) =>
      (_db.delete(_db.trashEntries)..where((t) => t.id.equals(trashEntryId)))
          .go();

  /// Empties the Trash for the current workspace.
  Future<void> emptyAll() async {
    final ws = await currentWorkspaceId(_db);
    final q = _db.delete(_db.trashEntries);
    if (ws != null) q.where((t) => t.workspaceId.equals(ws));
    await q.go();
  }

  /// Drops entries deleted longer ago than [maxAge] (retention sweep on launch).
  Future<int> purgeExpired(Duration maxAge) {
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    return (_db.delete(_db.trashEntries)
          ..where((t) => t.deletedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
