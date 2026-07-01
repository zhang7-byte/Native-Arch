import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/image_repository.dart';
import '../app_database_provider.dart';
import 'image_viewer_screen.dart';

String contentTypeForExtension(String? ext) => switch (ext?.toLowerCase()) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

/// A reusable "Images" block for an entity detail view: a thumbnail grid plus an
/// "Add" action. Belongs to exactly one owner (experiment, strain, culture or a
/// progress-log update). [title] lets callers relabel it (e.g. "Result images").
class ImagesSection extends StatelessWidget {
  const ImagesSection({
    super.key,
    this.experimentId,
    this.strainId,
    this.cultureId,
    this.updateId,
    this.reportId,
    this.protocolId,
    this.title = 'Images',
    this.dense = false,
  }) : assert(
            (experimentId != null ? 1 : 0) +
                    (strainId != null ? 1 : 0) +
                    (cultureId != null ? 1 : 0) +
                    (updateId != null ? 1 : 0) +
                    (reportId != null ? 1 : 0) +
                    (protocolId != null ? 1 : 0) ==
                1,
            'attach images to exactly one owner');

  final String? experimentId;
  final String? strainId;
  final String? cultureId;
  final String? updateId;
  final String? reportId;
  final String? protocolId;
  final String title;
  final bool dense;

  Stream<List<AttachedImage>> _watch(ImageRepository repo) =>
      experimentId != null
          ? repo.watchForExperiment(experimentId!)
          : strainId != null
              ? repo.watchForStrain(strainId!)
              : cultureId != null
                  ? repo.watchForCulture(cultureId!)
                  : updateId != null
                      ? repo.watchForUpdate(updateId!)
                      : reportId != null
                          ? repo.watchForReport(reportId!)
                          : repo.watchForProtocolGeneral(protocolId!);

  Future<void> _add(BuildContext context, ImageRepository repo) async {
    final result =
        await FilePicker.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    await repo.add(
      experimentId: experimentId,
      strainId: strainId,
      cultureId: cultureId,
      updateId: updateId,
      reportId: reportId,
      protocolId: protocolId,
      bytes: bytes,
      contentType: contentTypeForExtension(file.extension),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image attached')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ImageRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: dense
                    ? Theme.of(context).textTheme.labelLarge
                    : Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => _add(context, repo),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add'),
            ),
          ],
        ),
        StreamBuilder<List<AttachedImage>>(
          stream: _watch(repo),
          builder: (context, snap) {
            final items = snap.data ?? const <AttachedImage>[];
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No images yet.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              );
            }
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final img in items) _Thumb(image: img, repo: repo)],
            );
          },
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.repo});

  final AttachedImage image;
  final ImageRepository repo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ImageViewerScreen(imageId: image.id))),
      child: SizedBox(
        width: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FutureBuilder<Uint8List?>(
                    future: repo.bytesFor(image.id),
                    builder: (context, s) {
                      final bytes = s.data;
                      return Container(
                        width: 104,
                        height: 104,
                        color: scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: bytes != null
                            ? Image.memory(bytes,
                                width: 104, height: 104, fit: BoxFit.cover)
                            : Icon(Icons.cloud_download_outlined,
                                color: scheme.onSurfaceVariant),
                      );
                    },
                  ),
                ),
                if (image.annotations.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.draw,
                          size: 13, color: scheme.onSurface),
                    ),
                  ),
              ],
            ),
            if (image.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(image.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }
}
