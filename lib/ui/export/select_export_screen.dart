import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../export/pdf_export.dart';
import 'pdf_preview_screen.dart';

/// Pick multiple [items] with checkboxes (with search), then export the selection
/// to one PDF. With exactly one item it uses [buildSingle] (a detailed page);
/// with several it uses [buildTable] (one row per item) — see
/// [buildStrainsTablePdf] / [buildCulturesTablePdf]. Reused by the Strains and
/// Cultures lists.
class SelectExportScreen<T> extends StatefulWidget {
  const SelectExportScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.items,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    required this.buildSingle,
    required this.buildTable,
  });

  final String title;
  final String fileName;
  final List<T> items;
  final String Function(T) idOf;
  final String Function(T) titleOf;
  final String Function(T) subtitleOf;
  final Future<Uint8List> Function(T item, PdfFonts fonts) buildSingle;
  final Future<Uint8List> Function(List<T> items, PdfFonts fonts) buildTable;

  @override
  State<SelectExportScreen<T>> createState() => _SelectExportScreenState<T>();
}

class _SelectExportScreenState<T> extends State<SelectExportScreen<T>> {
  final Set<String> _selected = {};
  String _query = '';

  bool _matches(T it) {
    if (_query.isEmpty) return true;
    final hay =
        '${widget.titleOf(it)} ${widget.subtitleOf(it)}'.toLowerCase();
    return hay.contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = widget.items;
    final visible = items.where(_matches).toList();
    final allVisibleSelected = visible.isNotEmpty &&
        visible.every((it) => _selected.contains(widget.idOf(it)));
    // Selections persist across searches, so you can filter, select a batch,
    // filter again, and export everything chosen.
    final selected =
        items.where((it) => _selected.contains(widget.idOf(it))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selected.isEmpty
            ? widget.title
            : '${widget.title} · ${_selected.length} selected'),
        actions: [
          TextButton(
            onPressed: visible.isEmpty
                ? null
                : () => setState(() {
                      final ids = visible.map(widget.idOf);
                      if (allVisibleSelected) {
                        _selected.removeAll(ids);
                      } else {
                        _selected.addAll(ids);
                      }
                    }),
            child: Text(allVisibleSelected ? 'Clear shown' : 'Select shown'),
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text('Nothing to export.',
                  style: TextStyle(color: scheme.onSurfaceVariant)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: SearchBar(
                    hintText: 'Search',
                    leading: const Icon(Icons.search),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text('No matches for "$_query".',
                              style:
                                  TextStyle(color: scheme.onSurfaceVariant)))
                      : ListView.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, i) {
                            final it = visible[i];
                            final sub = widget.subtitleOf(it);
                            return CheckboxListTile(
                              value: _selected.contains(widget.idOf(it)),
                              onChanged: (v) => setState(() => v == true
                                  ? _selected.add(widget.idOf(it))
                                  : _selected.remove(widget.idOf(it))),
                              title: Text(widget.titleOf(it)),
                              subtitle: sub.isEmpty ? null : Text(sub),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: selected.isEmpty
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PdfPreviewScreen(
                        title: widget.title,
                        fileName: widget.fileName,
                        builder: (fonts) => selected.length == 1
                            ? widget.buildSingle(selected.first, fonts)
                            : widget.buildTable(selected, fonts),
                      ),
                    )),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(selected.isEmpty
                ? 'Export'
                : selected.length == 1
                    ? 'Export 1 (detailed)'
                    : 'Export ${selected.length} (table)'),
          ),
        ),
      ),
    );
  }
}
