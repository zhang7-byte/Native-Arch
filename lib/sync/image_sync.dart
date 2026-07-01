import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';

/// Abstraction over a binary object store. The real implementation is Supabase
/// Storage; tests substitute an in-memory fake so the image sync round-trip is
/// verifiable without a live backend.
abstract class ImageStorage {
  Future<void> upload(String path, Uint8List bytes, String contentType);
  Future<Uint8List> download(String path);
}

/// Supabase Storage backed implementation. Files live in [bucket] under the
/// owner's path (user id today, workspace id once shared workspaces are in).
class SupabaseImageStorage implements ImageStorage {
  SupabaseImageStorage(this._client, {this.bucket = 'images'});

  final SupabaseClient _client;
  final String bucket;

  @override
  Future<void> upload(String path, Uint8List bytes, String contentType) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
  }

  @override
  Future<Uint8List> download(String path) =>
      _client.storage.from(bucket).download(path);
}

String _extFor(String contentType) => switch (contentType) {
      'image/png' => '.png',
      'image/jpeg' || 'image/jpg' => '.jpg',
      'image/gif' => '.gif',
      'image/webp' => '.webp',
      _ => '.bin',
    };

/// Uploads the bytes of every local image not yet in Storage (empty
/// `storage_path`) and records the returned path on the row, so the subsequent
/// metadata push carries it. Bytes go to Storage under `<ownerPath>/<imageId>` —
/// never into the Postgres row.
Future<int> uploadPendingImages(
    AppDatabase db, ImageStorage storage, String ownerPath) async {
  final pending =
      await (db.select(db.images)..where((t) => t.storagePath.equals(''))).get();
  var uploaded = 0;
  for (final img in pending) {
    final blob = await (db.select(db.imageBlobs)
          ..where((t) => t.id.equals(img.id)))
        .getSingleOrNull();
    if (blob == null) continue; // bytes not local — nothing to upload
    // Store under the workspace's path so co-members can read it (falls back to
    // the per-user path for any not-yet-tagged image).
    final folder = img.workspaceId.isNotEmpty ? img.workspaceId : ownerPath;
    final path = '$folder/${img.id}${_extFor(img.contentType)}';
    await storage.upload(path, blob.bytes, img.contentType);
    await (db.update(db.images)..where((t) => t.id.equals(img.id)))
        .write(ImagesCompanion(storagePath: Value(path)));
    uploaded++;
  }
  return uploaded;
}

/// Downloads and caches the bytes of every image that has a `storage_path` but
/// no local blob (e.g. metadata pulled from another device). Skips files that
/// aren't fetchable yet; a later sync retries. Returns how many were cached.
Future<int> downloadMissingImages(AppDatabase db, ImageStorage storage) async {
  final rows = await db.customSelect(
    "SELECT i.id AS id, i.storage_path AS storage_path FROM images i "
    "LEFT JOIN image_blobs b ON b.id = i.id "
    "WHERE i.storage_path <> '' AND b.id IS NULL",
  ).get();
  var fetched = 0;
  for (final r in rows) {
    final id = r.data['id'] as String;
    final path = r.data['storage_path'] as String;
    try {
      final bytes = await storage.download(path);
      await db.into(db.imageBlobs).insertOnConflictUpdate(
            ImageBlobsCompanion.insert(id: id, bytes: bytes),
          );
      fetched++;
    } catch (_) {
      // Not available yet (or transient) — leave it for the next sync.
    }
  }
  // Let thumbnail FutureBuilders re-read now-cached bytes.
  if (fetched > 0) db.notifyUpdates({TableUpdate('images')});
  return fetched;
}
