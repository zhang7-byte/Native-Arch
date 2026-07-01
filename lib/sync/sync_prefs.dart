import '../data/database.dart';

/// Which direction to sync when the app closes. Device-local (in `sync_meta`).
/// Default is push, so closing a device you've been editing publishes its state.
enum CloseSync {
  push('push', 'Push (upload this device to the cloud)'),
  pull('pull', 'Pull (download the cloud to this device)');

  const CloseSync(this.key, this.label);
  final String key;
  final String label;

  static CloseSync fromKey(String? k) =>
      values.firstWhere((c) => c.key == k, orElse: () => push);
}

const _kCloseSync = 'close_sync';

Future<CloseSync> readCloseSync(AppDatabase db) async {
  final row = await (db.select(db.syncMeta)..where((t) => t.key.equals(_kCloseSync)))
      .getSingleOrNull();
  return CloseSync.fromKey(row?.value);
}

Stream<CloseSync> watchCloseSync(AppDatabase db) =>
    (db.select(db.syncMeta)..where((t) => t.key.equals(_kCloseSync)))
        .watchSingleOrNull()
        .map((r) => CloseSync.fromKey(r?.value));

Future<void> saveCloseSync(AppDatabase db, CloseSync mode) =>
    db.into(db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(key: _kCloseSync, value: mode.key));
