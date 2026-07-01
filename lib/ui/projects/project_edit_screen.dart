import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/project_repository.dart';
import '../app_database_provider.dart';
import '../labels.dart';

/// Create (when [project] is null) or edit a single project.
///
/// In [embedded] mode the form renders without its own Scaffold/AppBar so it can
/// live inside a desktop master-detail pane: it shows a slim header with a Save
/// (and, when creating, Cancel) action and calls [onSaved]/[onCancel] instead of
/// popping a route.
class ProjectEditScreen extends StatefulWidget {
  const ProjectEditScreen({
    super.key,
    this.project,
    this.embedded = false,
    this.onSaved,
    this.onCancel,
  });

  final Project? project;

  /// Render as an embedded pane (no Scaffold/AppBar) rather than a full route.
  final bool embedded;

  /// Called after a successful save when [embedded] (instead of popping).
  final VoidCallback? onSaved;

  /// Called when the user cancels an embedded "new project" form.
  final VoidCallback? onCancel;

  bool get isEditing => project != null;

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _tags;
  late ProjectStatus _status;
  late Priority _priority;
  DateTime? _startDate;
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = TextEditingController(text: p?.title ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _tags = TextEditingController(text: p?.tags.join(', ') ?? '');
    _status = p?.status ?? ProjectStatus.planning;
    _priority = p?.priority ?? Priority.medium;
    _startDate = p?.startDate;
    _targetDate = p?.targetDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseTags() => _tags.text
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _targetDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isStart ? _startDate = picked : _targetDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ProjectRepository(AppDatabaseProvider.of(context));
    final navigator = widget.embedded ? null : Navigator.of(context);
    setState(() => _saving = true);
    try {
      final tags = _parseTags();
      if (widget.isEditing) {
        await repo.update(
          widget.project!.id,
          ProjectsCompanion(
            title: Value(_title.text.trim()),
            description: Value(_description.text.trim()),
            status: Value(_status),
            priority: Value(_priority),
            startDate: Value(_startDate),
            targetDate: Value(_targetDate),
            tags: Value(tags),
          ),
        );
      } else {
        await repo.create(
          ProjectsCompanion.insert(
            title: _title.text.trim(),
            description: Value(_description.text.trim()),
            status: Value(_status),
            priority: Value(_priority),
            startDate: Value(_startDate),
            targetDate: Value(_targetDate),
            tags: Value(tags),
          ),
        );
      }
      if (widget.embedded) {
        widget.onSaved?.call();
      } else {
        navigator!.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving;
    final Widget body = Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              autofocus: !widget.isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                for (final s in ProjectStatus.values)
                  DropdownMenuItem(value: s, child: Text(enumLabel(s))),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                for (final p in Priority.values)
                  DropdownMenuItem(value: p, child: Text(enumLabel(p))),
              ],
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            ),
            const SizedBox(height: 8),
            _DateField(
              label: 'Start date',
              value: _startDate,
              onPick: () => _pickDate(isStart: true),
              onClear: () => setState(() => _startDate = null),
            ),
            _DateField(
              label: 'Target date',
              value: _targetDate,
              onPick: () => _pickDate(isStart: false),
              onClear: () => setState(() => _targetDate = null),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags',
                helperText: 'Comma-separated, e.g. AID2, GFP, Yarrowia',
              ),
            ),
          ],
        ),
      );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _embeddedHeader(scheme, canSave),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit project' : 'New project'),
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: body,
    );
  }

  /// Slim toolbar shown above the form when [ProjectEditScreen.embedded].
  Widget _embeddedHeader(ColorScheme scheme, bool canSave) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEditing ? 'Project' : 'New project',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface),
            ),
          ),
          if (!widget.isEditing && widget.onCancel != null)
            TextButton(
                onPressed: _saving ? null : widget.onCancel,
                child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: canSave ? _save : null,
              child: Text(_saving ? 'Saving…' : 'Save')),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('$label: ${formatDate(value)}')),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: onClear,
            ),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.event),
            label: const Text('Pick'),
          ),
        ],
      ),
    );
  }
}
