import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/image_repository.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import 'annotate_screen.dart';
import 'annotation.dart';

/// Full-size view of a single attached image: pan/zoom with its drawn markup
/// overlaid, caption + notes editing, an annotate action, and delete.
class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.imageId});

  final String imageId;

  Future<void> _editDetails(
      BuildContext context, ImageRepository repo, AttachedImage img) async {
    final caption = TextEditingController(text: img.caption);
    final notes = TextEditingController(text: img.notes);
    final saved = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Image details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: caption,
                decoration: const InputDecoration(
                    labelText: 'Caption', hintText: 'e.g. Gel, lanes 1–8'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notes,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                    labelText: 'Notes', alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      await repo.updateCaption(img.id, caption.text.trim());
      await repo.updateNotes(img.id, notes.text.trim());
    }
  }

  Future<void> _delete(
      BuildContext context, ImageRepository repo, AttachedImage img) async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text('This image will be moved to the Trash. You can '
            'restore it from Settings → Recently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await repo.delete(img.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ImageRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<AttachedImage?>(
      stream: repo.watchById(imageId),
      builder: (context, snap) {
        final img = snap.data;
        if (img == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This image no longer exists.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Image'),
            actions: [
              IconButton(
                tooltip: 'Annotate',
                icon: const Icon(Icons.draw_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AnnotateScreen(imageId: img.id))),
              ),
              IconButton(
                tooltip: 'Edit caption & notes',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editDetails(context, repo, img),
              ),
              IconButton(
                tooltip: 'Delete image',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, repo, img),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<Uint8List?>(
                  future: repo.bytesFor(imageId),
                  builder: (context, s) {
                    final bytes = s.data;
                    if (bytes == null) {
                      return const Center(
                          child: Text('Image is not downloaded yet.'));
                    }
                    return InteractiveViewer(
                      maxScale: 5,
                      child: Center(
                        child: AnnotatedImage(
                            bytes: bytes, annotations: img.annotations),
                      ),
                    );
                  },
                ),
              ),
              if (img.caption.isNotEmpty || img.notes.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: scheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (img.caption.isNotEmpty)
                        Text(img.caption,
                            style: Theme.of(context).textTheme.titleSmall),
                      if (img.notes.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                              top: img.caption.isNotEmpty ? 6 : 0),
                          child: Text(img.notes),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
