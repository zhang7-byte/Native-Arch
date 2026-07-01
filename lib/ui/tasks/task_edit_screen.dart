import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/project_repository.dart';
import '../../data/task_repository.dart';
import '../app_database_provider.dart';
import '../labels.dart';

/// Create (when [task] is null) or edit a task. A task may attach to a project,
/// an experiment, both, or neither. [defaultProjectId]/[defaultExperimentId]
/// preselect the link when adding from a detail screen.
///
/// In [embedded] mode the form renders without its own Scaffold/AppBar so it can
/// live inside a desktop master-detail pane: it shows a slim header with a Save
/// (and, when creating, Cancel) action and calls [onSaved]/[onCancel] instead of
/// popping a route.
class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({
    super.key,
    this.task,
    this.defaultProjectId,
    this.defaultExperimentId,
    this.embedded = false,
    this.onSaved,
    this.onCancel,
  });

  final Task? task;
  final String? defaultProjectId;
  final String? defaultExperimentId;

  /// Render as an embedded pane (no Scaffold/AppBar) rather than a full route.
  final bool embedded;

  /// Called after a successful save when [embedded] (instead of popping).
  final VoidCallback? onSaved;

  /// Called when the user cancels an embedded "new task" form.
  final VoidCallback? onCancel;

  bool get isEditing => task != null;

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskStatus _status;
  late Priority _priority;
  DateTime? _dueDate;
  String? _projectId;
  String? _experimentId;
  List<Project>? _projects;
  List<Experiment>? _experiments;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? Priority.medium;
    _dueDate = t?.dueDate;
    _projectId = t?.projectId ?? widget.defaultProjectId;
    _experimentId = t?.experimentId ?? widget.defaultExperimentId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_projects == null) _load();
  }

  Future<void> _load() async {
    final db = AppDatabaseProvider.of(context);
    final projects = await ProjectRepository(db).all();
    final experiments = await ExperimentRepository(db).all();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _experiments = experiments;
      // Drop ids that no longer exist so the dropdowns stay valid.
      if (!projects.any((p) => p.id == _projectId)) _projectId = null;
      if (!experiments.any((e) => e.id == _experimentId)) _experimentId = null;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = TaskRepository(AppDatabaseProvider.of(context));
    final navigator = widget.embedded ? null : Navigator.of(context);
    setState(() => _saving = true);
    try {
      if (widget.isEditing) {
        await repo.update(
          widget.task!.id,
          TasksCompanion(
            title: Value(_title.text.trim()),
            description: Value(_description.text.trim()),
            status: Value(_status),
            priority: Value(_priority),
            dueDate: Value(_dueDate),
            projectId: Value(_projectId),
            experimentId: Value(_experimentId),
          ),
        );
      } else {
        await repo.create(
          TasksCompanion.insert(
            title: _title.text.trim(),
            description: Value(_description.text.trim()),
            status: Value(_status),
            priority: Value(_priority),
            dueDate: Value(_dueDate),
            projectId: Value(_projectId),
            experimentId: Value(_experimentId),
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
    final projects = _projects;
    final experiments = _experiments;
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving;
    final Widget body = (projects == null || experiments == null)
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _title,
                    autofocus: !widget.isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    minLines: 2,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TaskStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final s in TaskStatus.values)
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
                    onChanged: (v) =>
                        setState(() => _priority = v ?? _priority),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Due: ${formatDate(_dueDate)}')),
                      if (_dueDate != null)
                        IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear',
                            onPressed: () => setState(() => _dueDate = null)),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: const Text('Pick'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    initialValue: _projectId,
                    decoration: const InputDecoration(
                        labelText: 'Project (optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final p in projects)
                        DropdownMenuItem(value: p.id, child: Text(p.title)),
                    ],
                    onChanged: (v) => setState(() => _projectId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: _experimentId,
                    decoration: const InputDecoration(
                        labelText: 'Experiment (optional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('None')),
                      for (final e in experiments)
                        DropdownMenuItem(value: e.id, child: Text(e.title)),
                    ],
                    onChanged: (v) => setState(() => _experimentId = v),
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
        title: Text(widget.isEditing ? 'Edit task' : 'New task'),
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

  /// Slim toolbar shown above the form when [TaskEditScreen.embedded].
  Widget _embeddedHeader(ColorScheme scheme, bool canSave) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEditing ? 'Task' : 'New task',
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
