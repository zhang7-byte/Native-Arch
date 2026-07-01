import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../data/backup.dart';
import '../../data/database.dart';
import '../../data/file_save_web.dart'
    if (dart.library.io) '../../data/file_save_io.dart';
import '../../data/workspace_repository.dart';
import '../glass.dart';

/// What the user chose in the close dialog.
enum CloseChoice { cancel, minimizeToTray, quit }

/// Shown when the user tries to close the desktop window. Reminds them that
/// LabTrack data lives on this device, offers a one-click full-workspace backup,
/// and lets them minimise to the tray instead of quitting.
/// Returns the close choice and whether to sync to the cloud first.
Future<(CloseChoice, bool)> showCloseBackupDialog(
    BuildContext context, AppDatabase db) async {
  final result = await showGlassDialog<(CloseChoice, bool)>(
    context: context,
    builder: (_) => _CloseBackupDialog(db: db),
  );
  return result ?? (CloseChoice.cancel, false);
}

class _CloseBackupDialog extends StatefulWidget {
  const _CloseBackupDialog({required this.db});

  final AppDatabase db;

  @override
  State<_CloseBackupDialog> createState() => _CloseBackupDialogState();
}

class _CloseBackupDialogState extends State<_CloseBackupDialog> {
  bool _busy = false;
  bool _sync = true;
  String? _error;

  String _stamp() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${two(n.month)}-${two(n.day)}-${two(n.hour)}${two(n.minute)}';
  }

  /// One click: snapshot everything in the current workspace to a JSON file,
  /// then (on success) tell the caller to go ahead and close.
  Future<void> _backupEverything() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final db = widget.db;
      final wsId = await currentWorkspaceId(db);
      final wsName = wsId == null
          ? null
          : (await WorkspaceRepository(db).findById(wsId))?.name;
      final backup = await buildWorkspaceBackup(db,
          workspaceId: wsId, workspaceName: wsName);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));

      final path = await FilePicker.saveFile(
        dialogTitle: 'Save LabTrack backup',
        fileName: 'labtrack-backup-${_stamp()}.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (!kIsWeb) {
        if (path == null) {
          // User cancelled the save dialog — stay on this dialog so they can
          // choose again rather than closing without a backup.
          if (mounted) setState(() => _busy = false);
          return;
        }
        await writeBytes(path, bytes);
      }
      if (mounted) {
        Navigator.pop(context, (CloseChoice.quit, _sync)); // backed up → quit
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Backup failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassAlertDialog(
      title: const Text('Close LabTrack?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LabTrack keeps your data on this device. Save a backup of '
            'everything in this workspace — projects, experiments, tasks, '
            'strains, reagents, cultures, primers, manuscripts and images — '
            'before you quit, or keep it running in the system tray.',
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _sync,
            onChanged:
                _busy ? null : (v) => setState(() => _sync = v ?? false),
            title: const Text('Sync to the cloud before closing'),
          ),
          if (_busy) ...[
            const SizedBox(height: 18),
            Row(
              children: const [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Backing up…'),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: scheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.pop(context, (CloseChoice.cancel, false)),
          child: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: _busy
              ? null
              : () =>
                  Navigator.pop(context, (CloseChoice.minimizeToTray, false)),
          icon: const Icon(Icons.move_to_inbox_outlined),
          label: const Text('Minimize to tray'),
        ),
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.pop(context, (CloseChoice.quit, _sync)),
          child: const Text('Quit without backup'),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _backupEverything,
          icon: const Icon(Icons.download),
          label: const Text('Back up & quit'),
        ),
      ],
    );
  }
}
