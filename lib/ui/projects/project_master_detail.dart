import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/project_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'project_edit_screen.dart';

/// Desktop three-pane experience for Projects: a persistent list on the left
/// and an inline editor on the right. Selecting an item edits it in place and
/// "New project" opens a blank editor — no full-screen navigation. Both panes
/// share a single [ProjectRepository.watchAll] stream.
class ProjectMasterDetail extends StatefulWidget {
  const ProjectMasterDetail({super.key});

  @override
  State<ProjectMasterDetail> createState() => _ProjectMasterDetailState();
}

class _ProjectMasterDetailState extends State<ProjectMasterDetail> {
  String? _selectedId;
  bool _creating = false;
  bool _selectNewestOnNextData = false;

  void _select(String id) => setState(() {
        _selectedId = id;
        _creating = false;
      });

  void _startNew() => setState(() {
        _creating = true;
        _selectedId = null;
      });

  Future<void> _confirmDelete(
      BuildContext context, ProjectRepository repo, Project project) async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text(
            '"${project.title}" and its experiments, tasks and manuscripts '
            'will be moved to the Trash. You can restore them from '
            'Settings → Recently deleted.'),
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
      await repo.delete(project.id);
      if (mounted && _selectedId == project.id) {
        setState(() => _selectedId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository(AppDatabaseProvider.of(context));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: StreamBuilder<List<Project>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <Project>[];

          // Just created a new project: select the newest row (the stream is
          // ordered by updated_at DESC, so the one we just wrote is first) once
          // it arrives.
          if (_selectNewestOnNextData && rows.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_selectNewestOnNextData) return;
              setState(() {
                _selectedId = rows.first.id;
                _selectNewestOnNextData = false;
              });
            });
          }

          // Resolve the selected project from the shared stream.
          Project? selected;
          for (final p in rows) {
            if (p.id == _selectedId) {
              selected = p;
              break;
            }
          }
          // Selection deleted elsewhere — drop it after this frame.
          if (_selectedId != null && selected == null && snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedId != null) {
                setState(() => _selectedId = null);
              }
            });
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 340,
                child: _listPane(context, repo, scheme, snapshot, rows),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(child: _detailPane(scheme, selected)),
            ],
          );
        },
      ),
    );
  }

  Widget _listPane(
    BuildContext context,
    ProjectRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Project>> snapshot,
    List<Project> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: title, New, account.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Text('Projects',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface)),
              ),
              IconButton(
                tooltip: 'New project',
                onPressed: _startNew,
                icon: const Icon(Icons.add),
              ),
              const AccountButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _list(context, repo, scheme, snapshot, rows)),
      ],
    );
  }

  Widget _list(
    BuildContext context,
    ProjectRepository repo,
    ColorScheme scheme,
    AsyncSnapshot<List<Project>> snapshot,
    List<Project> rows,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load projects:\n${snapshot.error}',
              textAlign: TextAlign.center),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No projects yet.\nTap + to add one.',
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final project = rows[i];
        final isSelected = project.id == _selectedId;
        return ListTile(
          selected: isSelected,
          selectedTileColor: scheme.primary.withValues(alpha: 0.10),
          isThreeLine: true,
          onTap: () => _select(project.id),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(project.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.description.isNotEmpty)
                Text(project.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  LabelChip(enumLabel(project.status),
                      color: projectStatusColor(project.status, scheme)),
                  LabelChip('${enumLabel(project.priority)} priority',
                      color: priorityColor(project.priority, scheme)),
                  for (final tag in project.tags) OutlineChip('#$tag'),
                ],
              ),
            ],
          ),
          trailing: GlassMoreButton(
            tooltip: 'Project actions',
            actions: [
              GlassAction(Icons.edit_outlined, 'Edit',
                  () => _select(project.id)),
              GlassAction(Icons.delete_outline, 'Delete',
                  () => _confirmDelete(context, repo, project),
                  destructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _detailPane(ColorScheme scheme, Project? selected) {
    if (_creating) {
      return ProjectEditScreen(
        // Fresh state for each new-project session.
        key: const ValueKey('project-new'),
        embedded: true,
        onSaved: () => setState(() {
          _creating = false;
          _selectNewestOnNextData = true;
        }),
        onCancel: () => setState(() => _creating = false),
      );
    }
    if (selected != null) {
      return ProjectEditScreen(
        // Re-key on id so switching selection rebuilds the form's state.
        key: ValueKey('project-${selected.id}'),
        embedded: true,
        project: selected,
        onSaved: () {},
      );
    }
    return _emptyDetail(scheme);
  }

  Widget _emptyDetail(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_outlined,
                size: 48, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Select a project to view and edit it,',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            Text('or tap + to add a new one.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
