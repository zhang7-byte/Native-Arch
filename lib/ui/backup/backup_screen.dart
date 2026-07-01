import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../data/backup.dart';
import '../../data/database.dart';
import '../../data/file_save_web.dart'
    if (dart.library.io) '../../data/file_save_io.dart';
import '../../data/project_repository.dart';
import '../../data/workspace_repository.dart';
import '../app_database_provider.dart';
import '../glass.dart';

/// Back up selected projects (with their experiments, tasks, linked strains,
/// the workspace's reagents, manuscripts and image attachments) to one JSON
/// file, and restore such a file. Scoped to the current workspace.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final Set<String> _selected = {};
  bool _busy = false;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _export(List<Project> projects) async {
    final db = AppDatabaseProvider.of(context);
    final ids =
        projects.where((p) => _selected.contains(p.id)).map((p) => p.id).toList();
    if (ids.isEmpty) return;
    setState(() => _busy = true);
    try {
      final wsId = await currentWorkspaceId(db);
      final wsName =
          wsId == null ? null : (await WorkspaceRepository(db).findById(wsId))?.name;
      final backup = await buildProjectBackup(db,
          projectIds: ids, workspaceId: wsId, workspaceName: wsName);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save LabTrack backup',
        fileName: 'labtrack-backup-${ids.length}-projects.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (!kIsWeb) {
        if (path == null) return; // cancelled
        await writeBytes(path, bytes);
      }
      final note =
          backup['imageBytes'] == 'bundled' ? ' (image bytes bundled)' : '';
      _toast('Exported ${ids.length} project(s)$note.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final db = AppDatabaseProvider.of(context);
    final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true);
    if (res == null || res.files.isEmpty) return;
    final bytes = res.files.first.bytes;
    if (bytes == null) return;

    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      _toast('That file is not valid JSON.');
      return;
    }
    if (!isLabTrackBackup(json)) {
      _toast('That is not a LabTrack backup file.');
      return;
    }

    final preview = await previewRestore(db, json);
    if (!mounted) return;
    final mode = await _showPreview(preview);
    if (mode == null) return;

    setState(() => _busy = true);
    try {
      final wsId = await currentWorkspaceId(db);
      final summary = await runRestore(db, json, mode, workspaceId: wsId);
      _toast('Restored: ${summary.added} added, ${summary.skipped} skipped.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<RestoreMode?> _showPreview(RestorePreview p) {
    var mode = RestoreMode.merge;
    return showGlassDialog<RestoreMode>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Restore backup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This file contains:'),
                const SizedBox(height: 4),
                for (final e in p.counts.entries)
                  if (e.value > 0) Text('•  ${e.value} ${e.key}'),
                const SizedBox(height: 8),
                Text('${p.existing} of ${p.total} already exist here (by id).'),
                Text(p.imageBytes == 'bundled'
                    ? 'Images: bytes bundled in the file.'
                    : 'Images: Storage paths only (bytes not in file).'),
                if (!p.isCompatible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '⚠ Backup schema v${p.schemaVersion}; this app is '
                      'v$backupSchemaVersion. Restoring anyway.',
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error),
                    ),
                  ),
                const Divider(height: 24),
                RadioListTile<RestoreMode>(
                  value: RestoreMode.merge,
                  // ignore: deprecated_member_use
                  groupValue: mode,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setLocal(() => mode = v!),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Merge'),
                  subtitle: const Text('Skip rows that already exist (by id).'),
                ),
                RadioListTile<RestoreMode>(
                  value: RestoreMode.copies,
                  // ignore: deprecated_member_use
                  groupValue: mode,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setLocal(() => mode = v!),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Import as copies'),
                  subtitle: const Text('Give everything new ids.'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, mode),
                child: const Text('Restore')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: StreamBuilder<List<Project>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          final projects = snap.data ?? const <Project>[];
          final allSelected =
              projects.isNotEmpty && _selected.length == projects.length;
          return Column(
            children: [
              if (_busy) const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text('Back up projects',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: projects.isEmpty
                          ? null
                          : () => setState(() {
                                if (allSelected) {
                                  _selected.clear();
                                } else {
                                  _selected
                                    ..clear()
                                    ..addAll(projects.map((p) => p.id));
                                }
                              }),
                      child: Text(allSelected ? 'Clear all' : 'Select all'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: projects.isEmpty
                    ? Center(
                        child: Text('No projects in this workspace.',
                            style: TextStyle(color: scheme.onSurfaceVariant)))
                    : ListView(
                        children: [
                          for (final p in projects)
                            CheckboxListTile(
                              value: _selected.contains(p.id),
                              onChanged: (v) => setState(() => v == true
                                  ? _selected.add(p.id)
                                  : _selected.remove(p.id)),
                              title: Text(p.title),
                            ),
                        ],
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _restore,
                          icon: const Icon(Icons.restore),
                          label: const Text('Restore…'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: (_busy || _selected.isEmpty)
                              ? null
                              : () => _export(projects),
                          icon: const Icon(Icons.download),
                          label: Text(_selected.isEmpty
                              ? 'Export'
                              : 'Export (${_selected.length})'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
