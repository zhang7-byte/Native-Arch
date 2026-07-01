import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/custom_event_repository.dart';
import '../../data/database.dart';
import '../../data/schedule.dart';
import '../../data/settings_repository.dart';
import '../../data/workspace_repository.dart';
import '../account/account_button.dart';
import '../app_database_provider.dart';
import '../cultures/culture_detail_screen.dart';
import '../experiments/experiment_detail_screen.dart';
import '../glass.dart';
import '../labels.dart';
import '../manuscripts/manuscript_detail_screen.dart';
import '../projects/project_detail_screen.dart';
import '../reagents/reagent_edit_screen.dart';
import '../tasks/task_edit_screen.dart';
import 'schedule_export_screen.dart';

/// Theme-independent colours per event kind (match the PDF).
const kScheduleColors = <ScheduleKind, Color>{
  ScheduleKind.task: Color(0xFF1E88E5),
  ScheduleKind.experiment: Color(0xFFC96442),
  ScheduleKind.projectStart: Color(0xFF43A047),
  ScheduleKind.projectTarget: Color(0xFFFB8C00),
  ScheduleKind.manuscript: Color(0xFF8E24AA),
  ScheduleKind.culture: Color(0xFF00897B),
  ScheduleKind.reagentExpiry: Color(0xFFE53935),
  ScheduleKind.birthday: Color(0xFFD81B60),
  ScheduleKind.personal: Color(0xFF5E35B1),
  ScheduleKind.holiday: Color(0xFF2E7D32),
};

IconData _kindIcon(ScheduleKind k) => switch (k) {
      ScheduleKind.task => Icons.checklist_outlined,
      ScheduleKind.experiment => Icons.biotech_outlined,
      ScheduleKind.projectStart => Icons.play_arrow_outlined,
      ScheduleKind.projectTarget => Icons.flag_outlined,
      ScheduleKind.manuscript => Icons.article_outlined,
      ScheduleKind.culture => Icons.bubble_chart_outlined,
      ScheduleKind.reagentExpiry => Icons.warning_amber_outlined,
      ScheduleKind.birthday => Icons.cake_outlined,
      ScheduleKind.personal => Icons.event_note_outlined,
      ScheduleKind.holiday => Icons.celebration_outlined,
    };

const _eventCategories = <(String, String)>[
  ('personal', 'Personal'),
  ('birthday', 'Birthday'),
  ('meeting', 'Meeting'),
  ('reminder', 'Reminder'),
  ('other', 'Other'),
];

/// A month calendar of everything dated in the workspace, with a per-day list
/// and PDF export.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _month; // first of the displayed month
  late DateTime _selected; // date-only
  Map<DateTime, List<ScheduleEvent>> _events = const {};
  List<Task> _tasks = const [];
  List<Reagent> _reagents = const [];
  List<CustomEvent> _customEvents = const [];
  bool _loading = true;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    final t = _today;
    _month = DateTime(t.year, t.month, 1);
    _selected = t;
    _load();
  }

  Future<void> _load() async {
    final db = AppDatabaseProvider.of(context);
    final ws = await currentWorkspaceId(db);
    List<T> scope<T>(List<T> rows, String Function(T) wsOf) =>
        ws == null ? rows : rows.where((x) => wsOf(x) == ws).toList();

    final tasks = scope(await db.select(db.tasks).get(), (t) => t.workspaceId);
    final experiments =
        scope(await db.select(db.experiments).get(), (e) => e.workspaceId);
    final projects =
        scope(await db.select(db.projects).get(), (p) => p.workspaceId);
    final manuscripts =
        scope(await db.select(db.manuscripts).get(), (m) => m.workspaceId);
    final cultures =
        scope(await db.select(db.cultures).get(), (c) => c.workspaceId);
    final reagents =
        scope(await db.select(db.reagents).get(), (r) => r.workspaceId);
    final customEvents = await CustomEventRepository(db).all();
    final region = (await SettingsRepository(db).get()).holidayRegion;

    // Year window for recurring custom events + holidays (academic events are
    // absolute and need no window).
    final years = [for (var i = -1; i <= 3; i++) _today.year + i];
    final events = [
      ...buildSchedule(
        tasks: tasks,
        experiments: experiments,
        projects: projects,
        manuscripts: manuscripts,
        cultures: cultures,
        reagents: reagents,
      ),
      ...customEventOccurrences(customEvents, years),
      ...holidayOccurrences(years, region),
    ];
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _reagents = reagents;
      _customEvents = customEvents;
      _events = groupByDay(events);
      _loading = false;
    });
  }

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta, 1));

  void _onEventTap(ScheduleEvent e) {
    switch (e.kind) {
      case ScheduleKind.birthday:
      case ScheduleKind.personal:
        final c = _byId(_customEvents, e.entityId, (x) => x.id);
        if (c != null) _addOrEditCustom(existing: c);
      case ScheduleKind.holiday:
        break; // holidays are read-only
      default:
        _navigate(e);
    }
  }

  Future<void> _navigate(ScheduleEvent e) async {
    Widget? screen;
    switch (e.kind) {
      case ScheduleKind.task:
        final t = _byId(_tasks, e.entityId, (x) => x.id);
        if (t != null) screen = TaskEditScreen(task: t);
      case ScheduleKind.experiment:
        screen = ExperimentDetailScreen(experimentId: e.entityId);
      case ScheduleKind.projectStart:
      case ScheduleKind.projectTarget:
        screen = ProjectDetailScreen(projectId: e.entityId);
      case ScheduleKind.manuscript:
        screen = ManuscriptDetailScreen(manuscriptId: e.entityId);
      case ScheduleKind.culture:
        screen = CultureDetailScreen(cultureId: e.entityId);
      case ScheduleKind.reagentExpiry:
        final r = _byId(_reagents, e.entityId, (x) => x.id);
        if (r != null) screen = ReagentEditScreen(reagent: r);
      case ScheduleKind.birthday:
      case ScheduleKind.personal:
      case ScheduleKind.holiday:
        return;
    }
    if (screen == null) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!));
    if (mounted) _load(); // reflect any edits made while away
  }

  /// Create or edit a personal calendar event (birthday/meeting/…).
  Future<void> _addOrEditCustom({CustomEvent? existing}) async {
    final db = AppDatabaseProvider.of(context);
    final repo = CustomEventRepository(db);
    final titleCtl = TextEditingController(text: existing?.title ?? '');
    final noteCtl = TextEditingController(text: existing?.note ?? '');
    var date = existing?.date ?? _selected;
    var category = existing?.category ?? 'personal';
    var repeat = existing?.repeatAnnually ?? false;

    final action = await showGlassDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'New event' : 'Edit event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleCtl,
                  autofocus: existing == null,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    for (final (value, label) in _eventCategories)
                      DropdownMenuItem(value: value, child: Text(label)),
                  ],
                  onChanged: (v) => setLocal(() => category = v ?? 'personal'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Date: ${formatDate(date)}')),
                    TextButton.icon(
                      icon: const Icon(Icons.event),
                      label: const Text('Pick'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(date.year - 5),
                          lastDate: DateTime(date.year + 10),
                        );
                        if (picked != null) setLocal(() => date = picked);
                      },
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: repeat,
                  onChanged: (v) => setLocal(() => repeat = v ?? false),
                  title: const Text('Repeats every year'),
                  subtitle: const Text('e.g. birthdays'),
                ),
                TextField(
                  controller: noteCtl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'delete'),
                child: const Text('Delete'),
              ),
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (action == 'save') {
      if (titleCtl.text.trim().isEmpty) return;
      final values = CustomEventsCompanion(
        title: Value(titleCtl.text.trim()),
        date: Value(date),
        category: Value(category),
        note: Value(noteCtl.text.trim()),
        repeatAnnually: Value(repeat),
      );
      if (existing == null) {
        await repo.create(values);
      } else {
        await repo.update(existing.id, values);
      }
    } else if (action == 'delete' && existing != null) {
      await repo.delete(existing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Event moved to the Trash. '
                'Restore it from Settings → Recently deleted.')));
      }
    } else {
      return;
    }
    if (mounted) _load();
  }

  static T? _byId<T>(List<T> list, String id, String Function(T) idOf) {
    for (final x in list) {
      if (idOf(x) == id) return x;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ScheduleExportScreen(month: _month))),
          ),
          const AccountButton(),
        ],
      ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addOrEditCustom(),
              icon: const Icon(Icons.add),
              label: const Text('Add event'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(scheme),
                _weekdayRow(scheme),
                _grid(scheme),
                const Divider(height: 1),
                Expanded(child: _dayPanel(scheme)),
              ],
            ),
    );
  }

  Widget _header(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous month',
                onPressed: () => _shiftMonth(-1)),
            Expanded(
              child: Center(
                child: Text('${monthName(_month.month)} ${_month.year}',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _month = DateTime(_today.year, _today.month, 1);
                _selected = _today;
              }),
              child: const Text('Today'),
            ),
            IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next month',
                onPressed: () => _shiftMonth(1)),
          ],
        ),
      );

  Widget _weekdayRow(ColorScheme scheme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            for (final wd in weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(wd,
                      style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      );

  Widget _grid(ColorScheme scheme) {
    final cells = monthCells(_month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        children: [
          for (var i = 0; i < cells.length; i += 7)
            Row(children: [
              for (final day in cells.sublist(i, i + 7)) _cell(day, scheme),
            ]),
        ],
      ),
    );
  }

  Widget _cell(DateTime day, ColorScheme scheme) {
    final inMonth = day.month == _month.month;
    final isToday = day == _today;
    final isSelected = day == _selected;
    final dayEvents = _events[day] ?? const <ScheduleEvent>[];
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selected = day),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 54,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary.withValues(alpha: 0.14) : null,
            border:
                isToday ? Border.all(color: scheme.primary, width: 1.5) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text('${day.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: inMonth
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                  )),
              const SizedBox(height: 3),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: [
                  for (final e in dayEvents.take(4))
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: kScheduleColors[e.kind],
                          shape: BoxShape.circle),
                    ),
                  if (dayEvents.length > 4)
                    Text('+${dayEvents.length - 4}',
                        style: TextStyle(
                            fontSize: 8, color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayPanel(ColorScheme scheme) {
    final dayEvents = _events[_selected] ?? const <ScheduleEvent>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Text(formatDate(_selected),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (dayEvents.isEmpty)
          Text('Nothing scheduled.',
              style: TextStyle(color: scheme.onSurfaceVariant))
        else
          for (final e in dayEvents)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_kindIcon(e.kind), color: kScheduleColors[e.kind]),
              title: Text(e.title),
              subtitle: Text(e.kind.label),
              trailing: e.kind == ScheduleKind.holiday
                  ? null
                  : const Icon(Icons.chevron_right, size: 18),
              onTap: () => _onEventTap(e),
            ),
      ],
    );
  }
}
