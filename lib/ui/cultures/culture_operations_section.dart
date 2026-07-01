import 'package:flutter/material.dart';

import '../../data/culture_event_repository.dart';
import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../app_database_provider.dart';
import '../glass.dart';
import '../labels.dart';
import 'culture_labels.dart';

/// Controllers for one logged operation (so several can be recorded at once).
class _OpEntry {
  final agent = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  void dispose() {
    agent.dispose();
    amount.dispose();
    note.dispose();
  }
}

/// Controllers for one sub-culture when splitting.
class _SplitEntry {
  _SplitEntry({String name = '', String medium = '', String vessel = ''})
      : name = TextEditingController(text: name),
        medium = TextEditingController(text: medium),
        vessel = TextEditingController(text: vessel);
  final TextEditingController name;
  final TextEditingController medium;
  final TextEditingController vessel;
  final amount = TextEditingController();
  final annotation = TextEditingController();
  void dispose() {
    name.dispose();
    medium.dispose();
    vessel.dispose();
    amount.dispose();
    annotation.dispose();
  }
}

/// The operations log on a culture detail screen: record sampling, reagent
/// additions, induction, measurements (several at once), a split (into one or
/// more sub-cultures), or a free note — and list everything logged, newest
/// first.
class CultureOperationsSection extends StatefulWidget {
  const CultureOperationsSection({super.key, required this.culture});

  final Culture culture;

  @override
  State<CultureOperationsSection> createState() =>
      _CultureOperationsSectionState();
}

class _CultureOperationsSectionState extends State<CultureOperationsSection> {
  AppDatabase get _db => AppDatabaseProvider.of(context);
  CultureEventRepository get _events => CultureEventRepository(_db);

  String _when(DateTime d) =>
      '${formatDate(d)}  ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  Future<DateTime?> _pickWhen(BuildContext ctx, DateTime initial) async {
    final d = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null || !ctx.mounted) return null;
    final t = await showTimePicker(
        context: ctx, initialTime: TimeOfDay.fromDateTime(initial));
    return DateTime(d.year, d.month, d.day, t?.hour ?? initial.hour,
        t?.minute ?? initial.minute);
  }

  Widget _pickRow(String label, DateTime when, VoidCallback onPick) => Row(
        children: [
          Expanded(child: Text('$label ${_when(when)}')),
          TextButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Pick'),
              onPressed: onPick),
        ],
      );

  /// Record one or more operations of [type] at the same time (split has its
  /// own flow).
  Future<void> _record(String type) async {
    final hasAgent =
        type == 'reagent' || type == 'induction' || type == 'measurement';
    final hasAmount = type != 'note';
    final allowMulti = type != 'note';
    final entries = <_OpEntry>[_OpEntry()];
    var when = DateTime.now();

    final agentLabel = switch (type) {
      'reagent' => 'Reagent',
      'induction' => 'Inducer',
      'measurement' => 'Measurement (e.g. OD600, GFP, glucose)',
      _ => '',
    };
    final amountLabel = switch (type) {
      'sampling' => 'Amount taken (e.g. 500 µL)',
      'reagent' => 'Amount / concentration (e.g. 10 µg/mL)',
      'induction' => 'Amount / concentration (e.g. 0.5 mM)',
      'measurement' => 'Value (e.g. 0.82, 1200 a.u., 5 g/L)',
      _ => '',
    };

    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final scheme = Theme.of(ctx).colorScheme;
          Widget entryCard(int i) {
            final e = entries[i];
            final multi = entries.length > 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: multi ? const EdgeInsets.all(10) : EdgeInsets.zero,
              decoration: multi
                  ? BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(10))
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (multi)
                    Row(
                      children: [
                        Text('#${i + 1}',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              setLocal(() => entries.removeAt(i).dispose()),
                        ),
                      ],
                    ),
                  if (hasAgent) ...[
                    TextField(
                        controller: e.agent,
                        autofocus: i == 0,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: agentLabel)),
                    const SizedBox(height: 10),
                  ],
                  if (hasAmount) ...[
                    TextField(
                        controller: e.amount,
                        autofocus: i == 0 && !hasAgent,
                        decoration: InputDecoration(labelText: amountLabel)),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                      controller: e.note,
                      minLines: 1,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Note')),
                ],
              ),
            );
          }

          return AlertDialog(
            title: Text(cultureOpLabel(type)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < entries.length; i++) entryCard(i),
                  if (allowMulti)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add another'),
                        onPressed: () =>
                            setLocal(() => entries.add(_OpEntry())),
                      ),
                    ),
                  const SizedBox(height: 4),
                  _pickRow('When:', when, () async {
                    final picked = await _pickWhen(ctx, when);
                    if (picked != null) setLocal(() => when = picked);
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Record')),
            ],
          );
        },
      ),
    );

    if (ok == true) {
      for (final e in entries) {
        final agent = e.agent.text.trim();
        final amount = e.amount.text.trim();
        final note = e.note.text.trim();
        if (agent.isEmpty && amount.isEmpty && note.isEmpty) continue;
        await _events.add(
          cultureId: widget.culture.id,
          happenedAt: when,
          type: type,
          agent: agent,
          amount: amount,
          note: note,
        );
      }
    }
    for (final e in entries) {
      e.dispose();
    }
  }

  /// Split this culture into one or more new active sub-cultures.
  Future<void> _split() async {
    final base = widget.culture.name.isEmpty ? 'Culture' : widget.culture.name;
    _SplitEntry newEntry(int n) => _SplitEntry(
        name: '$base (split $n)',
        medium: widget.culture.medium,
        vessel: widget.culture.vessel);
    final children = <_SplitEntry>[newEntry(1)];
    var when = DateTime.now();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final scheme = Theme.of(ctx).colorScheme;
          Widget childCard(int i) {
            final ch = children[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('Sub-culture ${i + 1}',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      const Spacer(),
                      if (children.length > 1)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              setLocal(() => children.removeAt(i).dispose()),
                        ),
                    ],
                  ),
                  TextField(
                      controller: ch.name,
                      decoration:
                          const InputDecoration(labelText: 'Name')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                            controller: ch.medium,
                            decoration:
                                const InputDecoration(labelText: 'Medium')),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                            controller: ch.vessel,
                            decoration:
                                const InputDecoration(labelText: 'Vessel')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: ch.amount,
                      decoration: const InputDecoration(
                          labelText: 'Amount taken (e.g. 5 mL)')),
                  const SizedBox(height: 10),
                  TextField(
                      controller: ch.annotation,
                      minLines: 1,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          const InputDecoration(labelText: 'Annotation')),
                ],
              ),
            );
          }

          return AlertDialog(
            title: const Text('Split culture'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Creates new active cultures from this one, recording each '
                    "sub-culture's mother and the original inoculation time.",
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < children.length; i++) childCard(i),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add sub-culture'),
                      onPressed: () => setLocal(
                          () => children.add(newEntry(children.length + 1))),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _pickRow('Split at:', when, () async {
                    final picked = await _pickWhen(ctx, when);
                    if (picked != null) setLocal(() => when = picked);
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Split')),
            ],
          );
        },
      ),
    );

    if (ok == true) {
      final specs = <CultureSplitChild>[];
      for (var i = 0; i < children.length; i++) {
        final ch = children[i];
        final name = ch.name.text.trim().isEmpty
            ? '$base (split ${i + 1})'
            : ch.name.text.trim();
        specs.add(CultureSplitChild(
            name: name,
            medium: ch.medium.text.trim(),
            vessel: ch.vessel.text.trim(),
            amount: ch.amount.text.trim(),
            annotation: ch.annotation.text.trim()));
      }
      await CultureRepository(_db).split(
        parent: widget.culture,
        splitTime: when,
        children: specs,
      );
      messenger.showSnackBar(SnackBar(
          content: Text(specs.length == 1
              ? 'Created "${specs.first.name}" from the split.'
              : 'Created ${specs.length} sub-cultures from the split.')));
    }
    for (final ch in children) {
      ch.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Operations log',
                style: Theme.of(context).textTheme.titleMedium),
            PopupMenuButton<String>(
              tooltip: 'Record operation',
              icon: const Icon(Icons.add),
              onSelected: (t) => t == 'split' ? _split() : _record(t),
              itemBuilder: (ctx) => [
                for (final t in cultureOpTypes)
                  PopupMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(cultureOpIcon(t),
                            size: 18, color: cultureOpColor(t, scheme)),
                        const SizedBox(width: 10),
                        Text(cultureOpLabel(t)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        StreamBuilder<List<CultureEvent>>(
          stream: _events.watchForCulture(widget.culture.id),
          builder: (context, snap) {
            final items = snap.data ?? const <CultureEvent>[];
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No operations logged yet.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              );
            }
            return Column(
              children: [
                for (final e in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(cultureOpIcon(e.type),
                        color: cultureOpColor(e.type, scheme)),
                    title: Text(cultureOpSummary(
                        type: e.type,
                        agent: e.agent,
                        amount: e.amount,
                        note: e.note)),
                    subtitle: Text([
                      _when(e.happenedAt),
                      if (e.note.isNotEmpty &&
                          e.type != 'note' &&
                          e.type != 'split')
                        e.note,
                    ].join('  ·  ')),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _events.delete(e.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
