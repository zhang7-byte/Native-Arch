import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import '../data/workspace_repository.dart';
import 'snapshot.dart';

class SyncResult {
  const SyncResult(
      {required this.pushed, required this.pulled, required this.deleted});
  final int pushed;
  final int pulled;
  final int deleted;
}

/// Snapshot-based cloud sync with EXPLICIT direction.
///
/// Each device uploads/downloads ONE compressed full-database snapshot (all
/// entity tables + workspaces/memberships + image bytes) stored in the
/// `sync_snapshots` table. The user (or the close handler) chooses the direction:
///
///  - [push] uploads this device's snapshot, overwriting the cloud copy.
///  - [pull] downloads the cloud snapshot, replacing this device's data (after a
///    local safety backup).
///
/// There is intentionally no automatic last-writer-wins merge: that resurrected
/// deletes (deleting a row lowered the local "version", so the stale cloud copy
/// kept winning). Explicit push/pull makes the direction unambiguous.
class SyncService {
  SyncService(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  /// Upload this device's full snapshot, overwriting the cloud copy.
  Future<SyncResult> push() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in to sync.');
    final snap = await buildSnapshot(_db);
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from('sync_snapshots').upsert({
      'user_id': user.id,
      'payload': encodeSnapshot(snap),
      'data_version': now,
      'updated_at': now,
    });
    return SyncResult(pushed: snapshotRowCount(snap), pulled: 0, deleted: 0);
  }

  /// Download the cloud snapshot and replace this device's data with it (a local
  /// pre-sync backup file is written first).
  Future<SyncResult> pull() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in to sync.');
    final List<Map<String, dynamic>> rows = await _client
        .from('sync_snapshots')
        .select('payload')
        .eq('user_id', user.id);
    if (rows.isEmpty) {
      throw StateError('Nothing in the cloud yet — push from a device first.');
    }
    final snap = decodeSnapshotPayload(rows.first['payload'] as String);
    await backupBeforeApply(_db);
    await applySnapshot(_db, snap);
    // The snapshot replaced the workspaces — reselect a valid current one.
    await ensureDefaultWorkspace(_db);
    return SyncResult(pushed: 0, pulled: snapshotRowCount(snap), deleted: 0);
  }
}
