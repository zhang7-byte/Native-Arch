import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/project_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import '../widgets.dart';
import 'project_detail_screen.dart';
import 'project_edit_screen.dart';

/// The Project list, with filters by status, priority and tag. Reactive.
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final Set<ProjectStatus> _statuses = {};
  final Set<Priority> _priorities = {};
  final Set<String> _tags = {};

  int get _activeCount => _statuses.length + _priorities.length + _tags.length;

  bool _matches(Project p) {
    if (_statuses.isNotEmpty && !_statuses.contains(p.status)) return false;
    if (_priorities.isNotEmpty && !_priorities.contains(p.priority)) {
      return false;
    }
    if (_tags.isNotEmpty && !p.tags.any(_tags.contains)) return false;
    return true;
  }

  void _openFilters(List<String> allTags) {
    showGlassModalSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            void toggle<T>(Set<T> set, T value) {
              setSheet(() => set.contains(value)
                  ? set.remove(value)
                  : set.add(value));
              setState(() {});
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Row(
                    children: [
                      Text('Filters',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      if (_activeCount > 0)
                        TextButton(
                          onPressed: () {
                            setSheet(() {
                              _statuses.clear();
                              _priorities.clear();
                              _tags.clear();
                            });
                            setState(() {});
                          },
                          child: const Text('Clear all'),
                        ),
                    ],
                  ),
                  const _FilterHeading('Status'),
                  Wrap(spacing: 8, children: [
                    for (final s in ProjectStatus.values)
                      FilterChip(
                        label: Text(enumLabel(s)),
                        selected: _statuses.contains(s),
                        onSelected: (_) => toggle(_statuses, s),
                      ),
                  ]),
                  const _FilterHeading('Priority'),
                  Wrap(spacing: 8, children: [
                    for (final p in Priority.values)
                      FilterChip(
                        label: Text(enumLabel(p)),
                        selected: _priorities.contains(p),
                        onSelected: (_) => toggle(_priorities, p),
                      ),
                  ]),
                  if (allTags.isNotEmpty) ...[
                    const _FilterHeading('Tag'),
                    Wrap(spacing: 8, children: [
                      for (final t in allTags)
                        FilterChip(
                          label: Text('#$t'),
                          selected: _tags.contains(t),
                          onSelected: (_) => toggle(_tags, t),
                        ),
                    ]),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProjectRepository(AppDatabaseProvider.of(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          StreamBuilder<List<Project>>(
            stream: repo.watchAll(),
            builder: (context, snapshot) {
              final allTags = <String>{
                for (final p in snapshot.data ?? const <Project>[]) ...p.tags
              }.toList()
                ..sort();
              return IconButton(
                tooltip: 'Filter',
                onPressed: () => _openFilters(allTags),
                icon: Badge(
                  isLabelVisible: _activeCount > 0,
                  label: Text('$_activeCount'),
                  child: const Icon(Icons.filter_list),
                ),
              );
            },
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: GlassFab(
        heroTag: 'fab-projects',
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ProjectEditScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: StreamBuilder<List<Project>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
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
          final all = snapshot.data!;
          final projects = all.where(_matches).toList();
          if (all.isEmpty) {
            return const Center(
              child: Text('No projects yet.\nTap "New project" to add one.',
                  textAlign: TextAlign.center),
            );
          }
          return Column(
            children: [
              if (_activeCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                            'Showing ${projects.length} of ${all.length}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _statuses.clear();
                          _priorities.clear();
                          _tags.clear();
                        }),
                        child: const Text('Clear filters'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: projects.isEmpty
                    ? const Center(child: Text('No projects match the filters.'))
                    : ListView.separated(
                        itemCount: projects.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) =>
                            _ProjectTile(project: projects[i], repo: repo),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterHeading extends StatelessWidget {
  const _FilterHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.repo});

  final Project project;
  final ProjectRepository repo;

  Future<void> _confirmDelete(BuildContext context) async {
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
    if (confirmed == true) await repo.delete(project.id);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      isThreeLine: true,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id))),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(project.title,
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
          GlassAction(
              Icons.edit_outlined,
              'Edit',
              () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProjectEditScreen(project: project)))),
          GlassAction(Icons.delete_outline, 'Delete',
              () => _confirmDelete(context),
              destructive: true),
        ],
      ),
    );
  }
}
