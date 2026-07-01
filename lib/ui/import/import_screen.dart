import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/csv_import.dart';
import '../app_database_provider.dart';

/// CSV import flow for strains or reagents:
/// pick file → map columns → preview/validate → confirm → summary.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, required this.entity});

  final ImportEntity entity;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

enum _Step { pick, map, preview, done }

class _ImportScreenState extends State<ImportScreen> {
  _Step _step = _Step.pick;
  ParsedCsv? _csv;
  Map<String, int> _mapping = {};
  ImportSummary? _summary;
  String? _error;
  bool _busy = false;
  // Default: import every row as a new entry (don't collapse rows that share a
  // match key with an existing entry into an update).
  bool _addAsNew = true;

  String get _noun => switch (widget.entity) {
        ImportEntity.strain => 'strains',
        ImportEntity.reagent => 'reagents',
        ImportEntity.primer => 'primers',
        ImportEntity.protocol => 'protocols',
      };

  List<ImportField> get _fields => fieldsFor(widget.entity);

  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null) {
        setState(() => _busy = false);
        return; // cancelled
      }
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        setState(() {
          _error = 'Could not read the file.';
          _busy = false;
        });
        return;
      }
      final csv = parseCsv(utf8.decode(bytes, allowMalformed: true));
      if (csv.headers.isEmpty || csv.rows.isEmpty) {
        setState(() {
          _error = 'The file has a header but no data rows.';
          _busy = false;
        });
        return;
      }
      setState(() {
        _csv = csv;
        _mapping = autoMapping(csv.headers, widget.entity);
        _step = _Step.map;
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to read CSV: $e';
        _busy = false;
      });
    }
  }

  bool get _requiredMapped =>
      _fields.where((f) => f.required).every((f) => _mapping.containsKey(f.key));

  Future<void> _import() async {
    setState(() => _busy = true);
    final summary = await runImport(
        AppDatabaseProvider.of(context), widget.entity, _csv!, _mapping,
        addAsNew: _addAsNew);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _step = _Step.done;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import $_noun from CSV')),
      body: switch (_step) {
        _Step.pick => _pickStep(),
        _Step.map => _mapStep(),
        _Step.preview => _previewStep(),
        _Step.done => _doneStep(),
      },
    );
  }

  Widget _pickStep() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 48),
              const SizedBox(height: 12),
              Text('Import $_noun from a CSV file',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'The first row must be column headers. You\'ll map columns to '
                'fields next. By default every row is added as a new $_noun '
                'entry; on the preview step you can switch to updating existing '
                '$_noun (matched on ${matchKeyLabel(widget.entity)}) instead.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.file_open),
                label: const Text('Choose CSV file'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapStep() {
    final headers = _csv!.headers;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Map columns', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('${_csv!.rows.length} data row(s) · ${headers.length} column(s)',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              for (final f in _fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: f.label),
                          if (f.required)
                            const TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red)),
                        ])),
                      ),
                      Expanded(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: _mapping[f.key],
                          hint: const Text('— not mapped —'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('— not mapped —')),
                            for (var i = 0; i < headers.length; i++)
                              DropdownMenuItem(
                                  value: i, child: Text(headers[i])),
                          ],
                          onChanged: (v) => setState(() {
                            if (v == null) {
                              _mapping.remove(f.key);
                            } else {
                              _mapping[f.key] = v;
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text('Dates should be YYYY-MM-DD.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12)),
            ],
          ),
        ),
        _bottomBar(
          onBack: () => setState(() => _step = _Step.pick),
          next: 'Preview',
          onNext: _requiredMapped
              ? () => setState(() => _step = _Step.preview)
              : null,
        ),
      ],
    );
  }

  Widget _previewStep() {
    final rows = _csv!.rows;
    final mappedFields = _fields.where((f) => _mapping.containsKey(f.key)).toList();
    final problemsByRow = [
      for (final r in rows) rowProblems(widget.entity, r, _mapping)
    ];
    final validCount = problemsByRow.where((p) => p.isEmpty).length;
    final skipCount = rows.length - validCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$validCount to import · $skipCount with problems will be skipped',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _addAsNew,
                onChanged:
                    _busy ? null : (v) => setState(() => _addAsNew = v),
                title: const Text('Add every row as a new entry'),
                subtitle: Text(_addAsNew
                    ? 'All rows are inserted, even if one with the same '
                        '${matchKeyLabel(widget.entity)} already exists.'
                    : 'Rows matching an existing '
                        '${matchKeyLabel(widget.entity)} update it in place '
                        'instead of adding a duplicate.'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  const DataColumn(label: Text('Status')),
                  for (final f in mappedFields) DataColumn(label: Text(f.label)),
                ],
                rows: [
                  for (var i = 0; i < rows.length; i++)
                    DataRow(cells: [
                      DataCell(problemsByRow[i].isEmpty
                          ? const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 20)
                          : Tooltip(
                              message: problemsByRow[i].join('\n'),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(problemsByRow[i].join('; '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                                ),
                              ]),
                            )),
                      for (final f in mappedFields)
                        DataCell(Text(cell(rows[i], _mapping, f.key) ?? '')),
                    ]),
                ],
              ),
            ),
          ),
        ),
        _bottomBar(
          onBack: () => setState(() => _step = _Step.map),
          next: _busy ? 'Importing…' : 'Import $validCount',
          onNext: (_busy || validCount == 0) ? null : _import,
        ),
      ],
    );
  }

  Widget _doneStep() {
    final s = _summary!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.task_alt, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text('Import complete',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('${s.inserted} inserted · ${s.updated} updated · ${s.skipped} skipped',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    _step = _Step.pick;
                    _csv = null;
                    _mapping = {};
                    _summary = null;
                    _error = null;
                  }),
                  child: const Text('Import another'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar({
    required VoidCallback onBack,
    required String next,
    required VoidCallback? onNext,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            TextButton(onPressed: onBack, child: const Text('Back')),
            const Spacer(),
            FilledButton(onPressed: onNext, child: Text(next)),
          ],
        ),
      ),
    );
  }
}
