import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';
import 'snapshot_backup_io.dart'
    if (dart.library.js_interop) 'snapshot_backup_web.dart';
import 'snapshot_gzip_io.dart'
    if (dart.library.js_interop) 'snapshot_gzip_web.dart';

/// Tables carried in a sync snapshot — every workspace-scoped entity plus the
/// workspaces that own them. Order is FK-safe for re-insert (parents before
/// children); FK checks are deferred during apply regardless.
const snapshotTables = [
  'workspaces',
  'projects',
  'strains',
  'reagents',
  'primers',
  'reports',
  'protocols',
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

/// The latest `updated_at` across all snapshot tables — the snapshot's "version"
/// for last-writer-wins. Empty string when there's no data at all.
Future<String> snapshotDataVersion(AppDatabase db) async {
  var max = '';
  for (final t in snapshotTables) {
    final row = await db
        .customSelect('SELECT MAX(updated_at) AS m FROM $t')
        .getSingleOrNull();
    final m = row?.data['m'];
    if (m is String && m.compareTo(max) > 0) max = m;
  }
  return max;
}

/// Builds a full-database snapshot: every snapshot table's rows plus the image
/// byte blobs (base64). Self-contained — applying it reproduces the data exactly.
Future<Map<String, dynamic>> buildSnapshot(AppDatabase db) async {
  final out = <String, dynamic>{'version': 1};
  for (final t in snapshotTables) {
    final rows = await db.customSelect('SELECT * FROM $t').get();
    out[t] = rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }
  final blobs = await db.select(db.imageBlobs).get();
  out['image_blobs'] = {for (final b in blobs) b.id: base64Encode(b.bytes)};
  return out;
}

/// Total entity rows in a snapshot (for the sync result summary).
int snapshotRowCount(Map<String, dynamic> snap) {
  var n = 0;
  for (final t in snapshotTables) {
    n += (snap[t] as List?)?.length ?? 0;
  }
  return n;
}

/// Compresses + base64-encodes a snapshot map for upload.
String encodeSnapshot(Map<String, dynamic> snap) =>
    base64Encode(snapDeflate(utf8.encode(jsonEncode(snap))));

/// Inverse of [encodeSnapshot] — decodes a downloaded payload to a snapshot map.
Map<String, dynamic> decodeSnapshotPayload(String payload) =>
    jsonDecode(utf8.decode(snapInflate(base64Decode(payload))))
        as Map<String, dynamic>;

/// Replaces ALL local data with [snap]. Device-local tables (sync_meta,
/// tombstones, trash, app_settings) are untouched. FK enforcement is deferred so
/// rows can be cleared/inserted in any order.
Future<void> applySnapshot(AppDatabase db, Map<String, dynamic> snap) async {
  await db.transaction(() async {
    await db.customStatement('PRAGMA defer_foreign_keys = ON');
    for (final t in snapshotTables) {
      await db.customStatement('DELETE FROM $t');
      final rows = (snap[t] as List?) ?? const [];
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final cols = row.keys.toList();
        final ph = List.filled(cols.length, '?').join(', ');
        await db.customStatement(
          'INSERT INTO $t (${cols.join(', ')}) VALUES ($ph)',
          cols.map((c) => row[c]).toList(),
        );
      }
    }
    await db.customStatement('DELETE FROM image_blobs');
    final blobs = (snap['image_blobs'] as Map?) ?? const {};
    for (final e in blobs.entries) {
      await db.customStatement(
        'INSERT INTO image_blobs (id, bytes) VALUES (?, ?)',
        [e.key, base64Decode(e.value as String)],
      );
    }
  });
  db.notifyUpdates({
    for (final t in snapshotTables) TableUpdate(t),
    TableUpdate('image_blobs'),
  });
}

/// Safety net: writes the current (about-to-be-overwritten) data to a local file
/// before a download is applied. Returns the path, or null on web / failure.
Future<String?> backupBeforeApply(AppDatabase db) async {
  try {
    final json = jsonEncode(await buildSnapshot(db));
    final stamp =
        DateTime.now().toUtc().toIso8601String().replaceAll(RegExp('[:.]'), '-');
    return await savePresyncBackup(json, stamp);
  } catch (_) {
    return null;
  }
}
