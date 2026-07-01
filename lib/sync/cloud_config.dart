import '../data/database.dart';

// Device-local keys in sync_meta (never synced/backed-up).
const _kUrl = 'supabase_url';
const _kKey = 'supabase_anon_key';

/// The Supabase URL + anon key the user saved on this device (empty if unset).
Future<(String url, String anonKey)> readCloudConfig(AppDatabase db) async {
  final rows = await (db.select(db.syncMeta)
        ..where((t) => t.key.isIn([_kUrl, _kKey])))
      .get();
  final map = {for (final r in rows) r.key: r.value};
  return (map[_kUrl] ?? '', map[_kKey] ?? '');
}

/// Persists the Supabase URL + anon key locally (takes effect on next launch).
Future<void> saveCloudConfig(AppDatabase db,
    {required String url, required String anonKey}) async {
  await db.into(db.syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion.insert(key: _kUrl, value: url.trim()));
  await db.into(db.syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion.insert(key: _kKey, value: anonKey.trim()));
}
