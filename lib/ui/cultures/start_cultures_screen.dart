import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../app_database_provider.dart';

/// Starts one culture per selected strain, all sharing the same configuration
/// (medium, vessel, inoculation amount, notes). Selection markers default to
/// each strain's own markers unless an override is entered here.
class StartCulturesScreen extends StatefulWidget {
  const StartCulturesScreen({super.key, required this.strains});

  final List<Strain> strains;

  @override
  State<StartCulturesScreen> createState() => _StartCulturesScreenState();
}

class _StartCulturesScreenState extends State<StartCulturesScreen> {
  final _medium = TextEditingController();
  final _vessel = TextEditingController();
  final _inoculum = TextEditingController();
  final _markers = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _medium.dispose();
    _vessel.dispose();
    _inoculum.dispose();
    _markers.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<String> _list(String s) =>
      s.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  Future<void> _start() async {
    final repo = CultureRepository(AppDatabaseProvider.of(context));
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final medium = _medium.text.trim();
      final vessel = _vessel.text.trim();
      final inoculum = _inoculum.text.trim();
      final notes = _notes.text.trim();
      final override = _list(_markers.text);
      for (final s in widget.strains) {
        // Per-strain markers fall back to the strain's own when not overridden.
        final markers = override.isNotEmpty ? override : s.selectionMarkers;
        await repo.create(CulturesCompanion(
          name: Value(medium.isEmpty ? s.name : '${s.name} in $medium'),
          strainId: Value(s.id),
          medium: Value(medium),
          vessel: Value(vessel),
          inoculumAmount: Value(inoculum),
          selectionMarkers: Value(markers),
          notes: Value(notes),
        ));
      }
      messenger.showSnackBar(SnackBar(
          content: Text('Started ${widget.strains.length} culture(s).')));
      navigator.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.strains.length;
    return Scaffold(
      appBar: AppBar(title: Text('Start $n culture${n == 1 ? '' : 's'}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'One culture will be started for each selected strain, all with the '
            'configuration below.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in widget.strains) Chip(label: Text(s.name)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _medium,
            decoration: const InputDecoration(
                labelText: 'Medium', hintText: 'e.g. YPD, YNB+glucose'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _vessel,
            decoration: const InputDecoration(
                labelText: 'Vessel', hintText: 'e.g. 250 mL flask'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inoculum,
            decoration: const InputDecoration(
                labelText: 'Inoculation amount',
                hintText: 'e.g. 5 mL, 1:100, single colony'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _markers,
            decoration: const InputDecoration(
              labelText: 'Selection markers (override)',
              helperText:
                  "Optional. Leave empty to use each strain's own markers.",
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _start,
            icon: const Icon(Icons.check),
            label: Text('Start $n culture${n == 1 ? '' : 's'}'),
          ),
        ],
      ),
    );
  }
}
