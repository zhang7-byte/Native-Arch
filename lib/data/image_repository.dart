import 'package:drift/drift.dart';

import 'database.dart';
import 'trash_repository.dart';
import 'workspace_repository.dart';

/// Reads and writes image attachments. Metadata lives in `images` (synced like
/// any entity); the bytes are cached locally in `image_blobs` so attachments
/// render offline. Bytes are never written to the synced row — on sync they go
/// to Supabase Storage (see [image_sync]).
class ImageRepository {
  ImageRepository(this._db);

  final AppDatabase _db;

  Stream<List<AttachedImage>> watchForExperiment(String experimentId) {
    final q = _db.select(_db.images)
      ..where((t) => t.experimentId.equals(experimentId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  Stream<List<AttachedImage>> watchForStrain(String strainId) {
    final q = _db.select(_db.images)
      ..where((t) => t.strainId.equals(strainId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  Stream<List<AttachedImage>> watchForCulture(String cultureId) {
    final q = _db.select(_db.images)
      ..where((t) => t.cultureId.equals(cultureId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  Stream<List<AttachedImage>> watchForUpdate(String updateId) {
    final q = _db.select(_db.images)
      ..where((t) => t.updateId.equals(updateId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  Stream<List<AttachedImage>> watchForReport(String reportId) {
    final q = _db.select(_db.images)
      ..where((t) => t.reportId.equals(reportId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  Stream<List<AttachedImage>> watchForProtocol(String protocolId) {
    final q = _db.select(_db.images)
      ..where((t) => t.protocolId.equals(protocolId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  /// Protocol images attached to a specific step.
  Stream<List<AttachedImage>> watchForProtocolStep(
      String protocolId, String stepId) {
    final q = _db.select(_db.images)
      ..where((t) => t.protocolId.equals(protocolId) & t.stepId.equals(stepId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  /// Protocol images not tied to any step (step_id IS NULL).
  Stream<List<AttachedImage>> watchForProtocolGeneral(String protocolId) {
    final q = _db.select(_db.images)
      ..where((t) => t.protocolId.equals(protocolId) & t.stepId.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return q.watch();
  }

  /// Detaches every image of [stepId] from its step (they become general
  /// protocol images) — used when that step is removed from the protocol.
  Future<void> clearProtocolStep(String protocolId, String stepId) =>
      (_db.update(_db.images)
            ..where((t) =>
                t.protocolId.equals(protocolId) & t.stepId.equals(stepId)))
          .write(const ImagesCompanion(stepId: Value(null)));

  /// After a protocol's steps are saved, detaches any image whose step no longer
  /// exists (its step_id isn't among [keptStepIds]) so it falls back to a
  /// general protocol image instead of disappearing.
  Future<void> reconcileProtocolSteps(
      String protocolId, List<String> keptStepIds) {
    final q = _db.update(_db.images)
      ..where((t) {
        final base = t.protocolId.equals(protocolId) & t.stepId.isNotNull();
        return keptStepIds.isEmpty
            ? base
            : base & t.stepId.isNotIn(keptStepIds);
      });
    return q.write(const ImagesCompanion(stepId: Value(null)));
  }

  Stream<AttachedImage?> watchById(String id) =>
      (_db.select(_db.images)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  /// The locally-cached bytes for [imageId], or null if not cached yet (e.g. a
  /// synced row whose file has not been downloaded from Storage).
  Future<Uint8List?> bytesFor(String imageId) async {
    final row = await (_db.select(_db.imageBlobs)
          ..where((t) => t.id.equals(imageId)))
        .getSingleOrNull();
    return row?.bytes;
  }

  /// Attaches an image to exactly one of an experiment, strain or culture. Stores
  /// the bytes locally immediately so the attachment shows offline; sync uploads
  /// them to Storage later. Returns the new image id.
  Future<String> add({
    String? experimentId,
    String? strainId,
    String? cultureId,
    String? updateId,
    String? reportId,
    String? protocolId,
    String? stepId,
    required Uint8List bytes,
    required String contentType,
    String caption = '',
  }) async {
    final owners =
        [experimentId, strainId, cultureId, updateId, reportId, protocolId]
            .where((e) => e != null)
            .length;
    assert(owners == 1,
        'an image belongs to exactly one of an experiment, strain, culture, update, report or protocol');
    final id = uuid.v4();
    // Inherit the parent's workspace so the attachment stays with its data.
    String workspaceId = '';
    if (experimentId != null) {
      workspaceId = (await (_db.select(_db.experiments)
                    ..where((t) => t.id.equals(experimentId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    } else if (strainId != null) {
      workspaceId = (await (_db.select(_db.strains)
                    ..where((t) => t.id.equals(strainId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    } else if (cultureId != null) {
      workspaceId = (await (_db.select(_db.cultures)
                    ..where((t) => t.id.equals(cultureId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    } else if (updateId != null) {
      workspaceId = (await (_db.select(_db.experimentUpdates)
                    ..where((t) => t.id.equals(updateId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    } else if (reportId != null) {
      workspaceId = (await (_db.select(_db.reports)
                    ..where((t) => t.id.equals(reportId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    } else if (protocolId != null) {
      workspaceId = (await (_db.select(_db.protocols)
                    ..where((t) => t.id.equals(protocolId)))
                  .getSingleOrNull())
              ?.workspaceId ??
          '';
    }
    if (workspaceId.isEmpty) workspaceId = await currentWorkspaceId(_db) ?? '';
    await _db.transaction(() async {
      await _db.into(_db.images).insert(ImagesCompanion.insert(
            id: Value(id),
            experimentId: Value(experimentId),
            strainId: Value(strainId),
            cultureId: Value(cultureId),
            updateId: Value(updateId),
            reportId: Value(reportId),
            protocolId: Value(protocolId),
            stepId: Value(stepId),
            caption: Value(caption),
            contentType: Value(contentType),
            workspaceId: Value(workspaceId),
          ));
      await _db
          .into(_db.imageBlobs)
          .insert(ImageBlobsCompanion.insert(id: id, bytes: bytes));
    });
    return id;
  }

  Future<void> updateCaption(String id, String caption) =>
      (_db.update(_db.images)..where((t) => t.id.equals(id)))
          .write(ImagesCompanion(caption: Value(caption)));

  Future<void> updateNotes(String id, String notes) =>
      (_db.update(_db.images)..where((t) => t.id.equals(id)))
          .write(ImagesCompanion(notes: Value(notes)));

  Future<void> updateAnnotations(String id, List<ImageAnnotation> annotations) =>
      (_db.update(_db.images)..where((t) => t.id.equals(id)))
          .write(ImagesCompanion(annotations: Value(annotations)));

  /// Moves the image to the Trash (its bytes are captured for restore).
  Future<void> delete(String id) => TrashRepository(_db).trash('images', id);
}
