import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/clone_repository.dart';
import '../../data/culture_repository.dart';
import '../../data/experiment_repository.dart';
import '../../data/primer_repository.dart';
import '../../data/project_repository.dart';
import '../../data/protocol_repository.dart';
import '../../data/reagent_repository.dart';
import '../../data/report_repository.dart';
import '../../data/strain_repository.dart';
import '../../data/task_repository.dart';
import '../../platform/window_title_bar.dart';
import '../app_database_provider.dart';
import '../cloning/clone_edit_screen.dart';
import '../cultures/culture_detail_screen.dart';
import '../experiments/experiment_detail_screen.dart';
import '../glass.dart';
import '../primers/primer_edit_screen.dart';
import '../projects/project_detail_screen.dart';
import '../protocols/protocol_edit_screen.dart';
import '../reagents/reagent_edit_screen.dart';
import '../report/report_edit_screen.dart';
import '../strains/strain_detail_screen.dart';
import '../tasks/task_edit_screen.dart';

/// What part of the data a search is limited to. [all] searches everything.
enum SearchScope {
  all('Everywhere'),
  projects('Projects'),
  experiments('Experiments'),
  tasks('Tasks'),
  strains('Strains'),
  reagents('Reagents'),
  cultures('Cultures'),
  primers('Primers'),
  cloning('Cloning'),
  protocols('Protocols'),
  reports('Reports');

  const SearchScope(this.label);
  final String label;
}

/// One row in the global-search results: a typed, openable entity match.
class SearchHit {
  SearchHit({
    required this.scope,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.haystack,
    required this.open,
  });

  final SearchScope scope;
  final IconData icon;
  final String title;
  final String subtitle;

  /// Lowercased text the query is matched against (title + a free-text field).
  final String haystack;

  /// Opens the entity's detail/edit screen on the given navigator.
  final void Function(NavigatorState nav) open;
}

String _snippet(String type, String text) {
  final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty) return type;
  return '$type · ${t.length > 90 ? '${t.substring(0, 90)}…' : t}';
}

SearchHit _hit(SearchScope scope, IconData icon, String title, String type,
    String secondary, Widget Function() screen,
    {String related = ''}) {
  return SearchHit(
    scope: scope,
    icon: icon,
    title: title.trim().isEmpty ? '(untitled)' : title,
    subtitle: _snippet(type, secondary),
    // [related] is searchable but not shown — it lets an entry be found by a
    // related entity (e.g. a culture by its strain's name/serial).
    haystack: '$title $secondary $related'.toLowerCase(),
    open: (nav) => nav.push(MaterialPageRoute(builder: (_) => screen())),
  );
}

/// Loads a one-shot snapshot of every searchable entity in the CURRENT
/// workspace (each repo's `watchAll` is workspace-scoped) and turns it into
/// openable [SearchHit]s.
Future<List<SearchHit>> gatherSearchHits(AppDatabase db) async {
  final hits = <SearchHit>[];

  // Parent entities are loaded up front so children can be found by their
  // related entity's name/serial too ("include related entries").
  final projects = await ProjectRepository(db).watchAll().first;
  final experiments = await ExperimentRepository(db).watchAll().first;
  final strains = await StrainRepository(db).watchAll().first;
  final projectById = {for (final p in projects) p.id: p};
  final experimentById = {for (final e in experiments) e.id: e};
  final strainById = {for (final s in strains) s.id: s};

  String strainTag(String? id) {
    final s = id == null ? null : strainById[id];
    return s == null ? '' : '${s.name} ${s.serialNumber}';
  }

  for (final p in projects) {
    hits.add(_hit(SearchScope.projects, Icons.science_outlined, p.title,
        'Project', p.description, () => ProjectDetailScreen(projectId: p.id)));
  }
  for (final e in experiments) {
    // Findable by the parent project's title and the linked strains too.
    final related = '${projectById[e.projectId]?.title ?? ''} '
        '${e.strainIds.map(strainTag).join(' ')}';
    hits.add(_hit(
        SearchScope.experiments,
        Icons.biotech_outlined,
        e.title,
        'Experiment',
        e.hypothesis,
        () => ExperimentDetailScreen(experimentId: e.id),
        related: related));
  }
  for (final t in await TaskRepository(db).watchAll().first) {
    // Findable by the parent project / experiment title too.
    final related = '${projectById[t.projectId]?.title ?? ''} '
        '${experimentById[t.experimentId]?.title ?? ''}';
    hits.add(_hit(SearchScope.tasks, Icons.checklist_outlined, t.title, 'Task',
        t.description, () => TaskEditScreen(task: t),
        related: related));
  }
  for (final s in strains) {
    // Serial number is shown in the subtitle and therefore searchable.
    final secondary = s.serialNumber.isNotEmpty
        ? (s.notes.isNotEmpty
            ? '#${s.serialNumber} · ${s.notes}'
            : '#${s.serialNumber}')
        : s.notes;
    hits.add(_hit(SearchScope.strains, Icons.coronavirus_outlined, s.name,
        'Strain', secondary, () => StrainDetailScreen(strainId: s.id)));
  }
  for (final r in await ReagentRepository(db).watchAll().first) {
    hits.add(_hit(SearchScope.reagents, Icons.inventory_2_outlined, r.name,
        'Reagent', r.notes, () => ReagentEditScreen(reagent: r)));
  }
  for (final c in [
    ...await CultureRepository(db).watchActive().first,
    ...await CultureRepository(db).watchArchived().first,
  ]) {
    hits.add(_hit(SearchScope.cultures, Icons.bubble_chart_outlined, c.name,
        'Culture', c.notes, () => CultureDetailScreen(cultureId: c.id),
        related: strainTag(c.strainId)));
  }
  for (final p in await PrimerRepository(db).watchAll().first) {
    hits.add(_hit(SearchScope.primers, Icons.biotech_outlined, p.name, 'Primer',
        p.notes, () => PrimerEditScreen(primer: p)));
  }
  for (final c in await CloneRepository(db).watchAll().first) {
    hits.add(_hit(SearchScope.cloning, Icons.donut_large_outlined, c.name,
        'Construction', c.notes, () => CloneEditScreen(construction: c)));
  }
  for (final p in await ProtocolRepository(db).watchAll().first) {
    hits.add(_hit(SearchScope.protocols, Icons.menu_book_outlined, p.name,
        'Protocol', p.summary, () => ProtocolEditScreen(protocol: p)));
  }
  for (final r in await ReportRepository(db).watchAll().first) {
    hits.add(_hit(SearchScope.reports, Icons.assessment_outlined, r.title,
        'Report', r.summary, () => ReportEditScreen(report: r)));
  }

  return hits;
}

/// Opens the global-search palette as a dim, dismissible overlay on the root
/// navigator (used from the title-bar search button, which has no Navigator of
/// its own).
PageRoute<void> _searchRoute() => PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      barrierDismissible: true,
      barrierLabel: 'Dismiss search',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, a, b) => const GlobalSearchScreen(),
      transitionsBuilder: (ctx, a, b, child) =>
          FadeTransition(opacity: a, child: child),
    );

/// Opens the palette via a navigator key (used from the title bar, which has no
/// Navigator of its own).
void openGlobalSearch(GlobalKey<NavigatorState> navigatorKey) {
  navigatorKey.currentState?.push(_searchRoute());
}

/// Opens the palette using the nearest Navigator (used from in-app screens such
/// as the mobile Dashboard).
void openGlobalSearchOn(BuildContext context) {
  Navigator.of(context).push(_searchRoute());
}

/// A spotlight-style search palette: a scope selector, a query field, and a
/// live list of matching entities that open on tap.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _controller = TextEditingController();
  SearchScope _scope = SearchScope.all;
  List<SearchHit> _all = const [];
  bool _loading = true;
  bool _started = false;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final db = AppDatabaseProvider.of(context);
    gatherSearchHits(db).then((hits) {
      if (!mounted) return;
      setState(() {
        _all = hits;
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<SearchHit> _filtered() {
    final q = _query.toLowerCase();
    // Nothing to show until the user either types or picks a specific scope.
    if (q.isEmpty && _scope == SearchScope.all) return const [];
    final list = _all
        .where((h) => _scope == SearchScope.all || h.scope == _scope)
        .where((h) => q.isEmpty || h.haystack.contains(q))
        .toList()
      ..sort((a, b) {
        final c = a.scope.index.compareTo(b.scope.index);
        return c != 0 ? c : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });
    return list.length > 80 ? list.sublist(0, 80) : list;
  }

  void _openHit(SearchHit h) {
    final nav = Navigator.of(context);
    nav.pop(); // close the palette first
    h.open(nav);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final results = _filtered();
    final topInset = (isDesktopWindow
            ? WindowTitleBar.height
            : MediaQuery.of(context).padding.top) +
        24;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Tap outside the palette to dismiss (the route dims behind it).
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: const SizedBox.expand(),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: topInset, left: 16, right: 16),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 640, maxHeight: 560),
                  child: Material(
                    type: MaterialType.transparency,
                    child: GlassSurface(
                      blur: 30,
                      opacity: 0.6,
                      sheen: true,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.6)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 10, 8),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    color: scheme.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    autofocus: true,
                                    textInputAction: TextInputAction.search,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Search your lab…',
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _query = v.trim()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _ScopeSelector(
                                  value: _scope,
                                  onChanged: (s) => setState(() => _scope = s),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Flexible(child: _body(context, results, scheme)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, List<SearchHit> results, ColorScheme scheme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Center(
            child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    if (results.isEmpty) {
      final msg = _query.isEmpty && _scope == SearchScope.all
          ? 'Type to search across projects, experiments, tasks, strains, '
              'reagents, cultures, primers, cloning, protocols and reports — '
              'or pick a scope to browse.'
          : 'No matches.';
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
        child: Text(msg, style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final h = results[i];
        return ListTile(
          dense: true,
          leading: Icon(h.icon, color: scheme.onSurfaceVariant),
          title: Text(h.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle:
              Text(h.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => _openHit(h),
        );
      },
    );
  }
}

/// Compact dropdown that picks the [SearchScope].
class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({required this.value, required this.onChanged});

  final SearchScope value;
  final ValueChanged<SearchScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<SearchScope>(
        value: value,
        isDense: true,
        borderRadius: BorderRadius.circular(14),
        items: [
          for (final s in SearchScope.values)
            DropdownMenuItem(value: s, child: Text(s.label)),
        ],
        onChanged: (s) {
          if (s != null) onChanged(s);
        },
      ),
    );
  }
}
