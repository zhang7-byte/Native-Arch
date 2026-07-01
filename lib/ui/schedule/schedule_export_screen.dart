import 'package:flutter/material.dart';

import '../../data/custom_event_repository.dart';
import '../../data/database.dart';
import '../../data/experiment_repository.dart';
import '../../data/holidays.dart';
import '../../data/project_repository.dart';
import '../../data/schedule.dart';
import '../../data/settings_repository.dart';
import '../../export/pdf_export.dart';
import '../app_database_provider.dart';
import '../export/pdf_preview_screen.dart';
import '../labels.dart';

/// Pick which projects/experiments and non-academic events to include before
/// exporting the schedule. Leaving the project list unchecked exports the whole
/// month's calendar; personal events + holidays start included and can be
/// unchecked.
class ScheduleExportScreen extends StatefulWidget {
  const ScheduleExportScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<ScheduleExportScreen> createState() => _ScheduleExportScreenState();
}

class _ScheduleExportScreenState extends State<ScheduleExportScreen> {
  final Set<String> _selProjects = {};
  final Set<String> _selExperiments = {};
  final Set<String> _selCustom = {};
  bool _includeHolidays = true;
  String _holidayRegion = 'none';
  List<Project> _projects = const [];
  List<Experiment> _experiments = const [];
  List<CustomEvent> _customEvents = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = AppDatabaseProvider.of(context);
    final projects = await ProjectRepository(db).watchAll().first;
    final experiments = await ExperimentRepository(db).watchAll().first;
    final customEvents = await CustomEventRepository(db).all();
    final region = (await SettingsRepository(db).get()).holidayRegion;
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _experiments = experiments;
      _customEvents = customEvents;
      _holidayRegion = region;
      // Default: everything non-academic is included; uncheck to drop.
      _selCustom.addAll(customEvents.map((e) => e.id));
      _includeHolidays = region != 'none';
      _loading = false;
    });
  }

  void _export() {
    final db = AppDatabaseProvider.of(context);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PdfPreviewScreen(
        title: 'Schedule PDF',
        fileName: 'labtrack-schedule.pdf',
        builder: (fonts) => buildSchedulePdf(
          db,
          widget.month,
          fonts,
          projectIds: _selProjects.toList(),
          experimentIds: _selExperiments.toList(),
          customEventIds: _selCustom.toList(),
          includeHolidays: _includeHolidays,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export schedule'),
        actions: [
          IconButton(
            tooltip: 'Export to PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _loading ? null : _export,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('${monthName(widget.month.month)} ${widget.month.year}',
                    style: text.titleLarge),
                const SizedBox(height: 12),
                _heading('Projects & experiments', scheme),
                Text(
                  'Leave unchecked to export the whole month. Pick projects/'
                  'experiments to focus the calendar on them and append their '
                  'details. Selecting a project includes its experiments; tick '
                  'specific experiments to narrow it.',
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 8),
                if (_projects.isEmpty)
                  Text('No projects in this workspace.',
                      style: TextStyle(color: scheme.onSurfaceVariant))
                else
                  for (final p in _projects) _projectTile(p),
                const SizedBox(height: 20),
                _heading('Personal events', scheme),
                if (_customEvents.isEmpty)
                  Text('No personal events.',
                      style: TextStyle(color: scheme.onSurfaceVariant))
                else ...[
                  _selectAllRow(),
                  for (final e in _customEvents) _customTile(e),
                ],
                const SizedBox(height: 20),
                _heading('Holidays', scheme),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _includeHolidays && _holidayRegion != 'none',
                  onChanged: _holidayRegion == 'none'
                      ? null
                      : (v) => setState(() => _includeHolidays = v ?? false),
                  title: const Text('Include public holidays'),
                  subtitle: Text(_holidayRegion == 'none'
                      ? 'Choose a region in Settings → Schedule first.'
                      : holidayRegionLabel(_holidayRegion)),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
    );
  }

  Widget _heading(String label, ColorScheme scheme) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: scheme.onSurface)),
      );

  Widget _selectAllRow() {
    final allOn = _selCustom.length == _customEvents.length;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => setState(() {
          if (allOn) {
            _selCustom.clear();
          } else {
            _selCustom
              ..clear()
              ..addAll(_customEvents.map((e) => e.id));
          }
        }),
        child: Text(allOn ? 'Clear all' : 'Select all'),
      ),
    );
  }

  Widget _customTile(CustomEvent e) => CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        value: _selCustom.contains(e.id),
        onChanged: (v) => setState(() =>
            v == true ? _selCustom.add(e.id) : _selCustom.remove(e.id)),
        title: Text(e.title),
        subtitle: Text(e.repeatAnnually
            ? 'Every year · ${formatDate(e.date)}'
            : formatDate(e.date)),
      );

  Widget _projectTile(Project p) {
    final exps = _experiments.where((e) => e.projectId == p.id).toList();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      leading: Checkbox(
        value: _selProjects.contains(p.id),
        onChanged: (v) => setState(() =>
            v == true ? _selProjects.add(p.id) : _selProjects.remove(p.id)),
      ),
      title: Text(p.title),
      subtitle: exps.isEmpty ? const Text('No experiments') : null,
      children: [
        for (final e in exps)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            value: _selExperiments.contains(e.id),
            onChanged: (v) => setState(() => v == true
                ? _selExperiments.add(e.id)
                : _selExperiments.remove(e.id)),
            title: Text(e.title),
          ),
      ],
    );
  }
}
