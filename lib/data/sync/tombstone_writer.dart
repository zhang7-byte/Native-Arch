import '../database.dart';

/// Records a tombstone (id -> table name) for each deleted row so the deletion
/// can be propagated to other devices during sync. Upserts, so re-deleting an
/// already-tombstoned id just refreshes it.
Future<void> writeTombstones(
    AppDatabase db, Map<String, String> idToTable) async {
  for (final entry in idToTable.entries) {
    await db.into(db.tombstones).insertOnConflictUpdate(
          TombstonesCompanion.insert(id: entry.key, entityTable: entry.value),
        );
  }
}
