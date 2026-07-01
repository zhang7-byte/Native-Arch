import 'package:flutter/foundation.dart';

import '../data/database.dart';

/// Read-only ("lockdown") mode. When on, the UI blocks adding, editing and
/// deleting — viewing and exporting stay available. Device-local (stored in
/// `sync_meta`, never synced) and exposed as a [ValueNotifier] so the FABs,
/// action menus and the lock banner react instantly.
final appLock = ValueNotifier<bool>(false);

const _lockKey = 'lockdown';

/// Loads the saved lock state on startup.
Future<void> loadAppLock(AppDatabase db) async {
  final row = await (db.select(db.syncMeta)..where((t) => t.key.equals(_lockKey)))
      .getSingleOrNull();
  appLock.value = row?.value == '1';
}

/// Set by the Android back-button close flow when it has already handled (or
/// deliberately skipped) the close-sync, so the app-lifecycle `paused`/`detached`
/// handler in `main.dart` doesn't sync a second time. One-shot: the handler
/// reads it and clears it.
bool suppressNextCloseSync = false;

/// Persists and applies the lock state.
Future<void> setAppLock(AppDatabase db, bool locked) async {
  await db.into(db.syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion.insert(key: _lockKey, value: locked ? '1' : ''));
  appLock.value = locked;
}
