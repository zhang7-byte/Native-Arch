import 'package:drift/drift.dart';

import 'database.dart';
import 'sync/tombstone_writer.dart';
import 'workspace_repository.dart';

/// An inventory category that can be bulk-deleted from Settings.
enum InventoryKind {
  strains('strains', 'Strains'),
  reagents('reagents', 'Reagents'),
  primers('primers', 'Primers'),
  cultures('cultures', 'Cultures');

  const InventoryKind(this.table, this.label);
  final String table;
  final String label;
}

/// Counts how many rows of each [InventoryKind] exist in the current workspace.
Future<Map<InventoryKind, int>> inventoryCounts(AppDatabase db) async {
  final ws = await currentWorkspaceId(db);
  final out = <InventoryKind, int>{};
  for (final kind in InventoryKind.values) {
    final scope = ws == null ? '' : ' WHERE workspace_id = ?';
    final row = await db
        .customSelect('SELECT COUNT(*) AS n FROM ${kind.table}$scope',
            variables: ws == null ? const [] : [Variable<String>(ws)])
        .getSingle();
    out[kind] = row.read<int>('n');
  }
  return out;
}

/// Permanently deletes ALL rows of the selected inventory [kinds] in the current
/// workspace, along with their cascade children (attached images + blobs, and
/// culture logs), writing a tombstone for every removed row so the deletion
/// propagates on sync. Returns the number of primary inventory rows removed.
///
/// Unlike a single-item delete this does NOT route through the Trash — the UI
/// prompts the user to back up first.
Future<int> wipeInventory(AppDatabase db, Set<InventoryKind> kinds) async {
  if (kinds.isEmpty) return 0;
  final ws = await currentWorkspaceId(db);
  final scope = ws == null ? '' : ' AND workspace_id = ?';
  List<Variable<String>> wsVars() =>
      ws == null ? const [] : [Variable<String>(ws)];

  var removed = 0;
  final touched = <String>{};
  await db.transaction(() async {
    final tomb = <String, String>{};

    // Collect ids of [table] rows matching [extra] within the workspace.
    Future<List<String>> idsWhere(String table, String extra) async {
      final rows = await db
          .customSelect('SELECT id FROM $table WHERE ($extra)$scope',
              variables: wsVars())
          .get();
      return [for (final r in rows) r.read<String>('id')];
    }

    // Gather everything to tombstone FIRST (before deleting), so foreign-key
    // cascades don't remove child rows before we've recorded them.
    for (final kind in kinds) {
      final t = kind.table;
      if (t == 'strains') {
        for (final id in await idsWhere(
            'images', "strain_id IS NOT NULL AND strain_id <> ''")) {
          tomb[id] = 'images';
          touched.add('images');
        }
      } else if (t == 'cultures') {
        for (final id in await idsWhere(
            'images', "culture_id IS NOT NULL AND culture_id <> ''")) {
          tomb[id] = 'images';
          touched.add('images');
        }
        for (final id in await idsWhere('culture_events', '1=1')) {
          tomb[id] = 'culture_events';
          touched.add('culture_events');
        }
      }
      final primary = await idsWhere(t, '1=1');
      if (primary.isEmpty) continue;
      for (final id in primary) {
        tomb[id] = t;
      }
      removed += primary.length;
      touched.add(t);
    }

    // Delete the primary rows; FK cascade removes images / culture logs / blobs.
    for (final kind in kinds) {
      await db.customStatement(
          'DELETE FROM ${kind.table}${ws == null ? '' : ' WHERE workspace_id = ?'}',
          ws == null ? const [] : [ws]);
    }

    await writeTombstones(db, tomb);
    touched
      ..add('image_blobs')
      ..add('tombstones');
  });

  // Raw SQL above bypasses drift's stream tracking — notify so live lists clear.
  db.notifyUpdates(
      {for (final t in touched) TableUpdate(t, kind: UpdateKind.delete)});
  return removed;
}
