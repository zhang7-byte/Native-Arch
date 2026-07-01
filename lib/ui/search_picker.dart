import 'package:flutter/material.dart';

/// A dropdown-style form field that opens a SEARCHABLE picker — for choosing one
/// item (a strain, a primer, …) from a large list where a plain dropdown is
/// unusable. Shows the selected item's label (or a placeholder) and a search
/// affordance; tapping opens a full-screen search list. [selectedId] '' = none.
class SearchPickerField<T> extends StatelessWidget {
  const SearchPickerField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedId,
    required this.idOf,
    required this.labelOf,
    required this.onChanged,
    this.subtitleOf,
    this.noneLabel = '— none —',
  });

  final String label;
  final List<T> items;
  final String selectedId;
  final String Function(T) idOf;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final ValueChanged<String> onChanged;
  final String noneLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    T? current;
    for (final it in items) {
      if (idOf(it) == selectedId) {
        current = it;
        break;
      }
    }
    final isNone = current == null;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final picked = await showSearchPicker<T>(
          context,
          title: label,
          items: items,
          idOf: idOf,
          labelOf: labelOf,
          subtitleOf: subtitleOf,
          selectedId: selectedId,
          noneLabel: noneLabel,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isNone ? noneLabel : labelOf(current as T),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: isNone ? scheme.onSurfaceVariant : null),
              ),
            ),
            Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Full-screen searchable single-select. Returns the chosen id ('' for the
/// "none" option), or null if cancelled.
Future<String?> showSearchPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) idOf,
  required String Function(T) labelOf,
  String Function(T)? subtitleOf,
  String selectedId = '',
  String noneLabel = '— none —',
}) {
  return Navigator.of(context).push<String>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => _SearchPickerScreen<T>(
      title: title,
      items: items,
      idOf: idOf,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      selectedId: selectedId,
      noneLabel: noneLabel,
    ),
  ));
}

class _SearchPickerScreen<T> extends StatefulWidget {
  const _SearchPickerScreen({
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    required this.subtitleOf,
    required this.selectedId,
    required this.noneLabel,
  });
  final String title;
  final List<T> items;
  final String Function(T) idOf;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final String selectedId;
  final String noneLabel;

  @override
  State<_SearchPickerScreen<T>> createState() => _SearchPickerScreenState<T>();
}

class _SearchPickerScreenState<T> extends State<_SearchPickerScreen<T>> {
  String _query = '';

  bool _matches(T it) {
    if (_query.isEmpty) return true;
    final hay =
        '${widget.labelOf(it)} ${widget.subtitleOf?.call(it) ?? ''}'
            .toLowerCase();
    return hay.contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = widget.items.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search',
              leading: const Icon(Icons.search),
              autoFocus: true,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              // +1 for the always-available "none" option at the top.
              itemCount: visible.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ListTile(
                    title: Text(widget.noneLabel,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    selected: widget.selectedId.isEmpty,
                    onTap: () => Navigator.pop(context, ''),
                  );
                }
                final it = visible[i - 1];
                final sub = widget.subtitleOf?.call(it) ?? '';
                final selected = widget.idOf(it) == widget.selectedId;
                return ListTile(
                  title: Text(widget.labelOf(it)),
                  subtitle: sub.isEmpty ? null : Text(sub),
                  selected: selected,
                  trailing: selected
                      ? Icon(Icons.check, color: scheme.primary)
                      : null,
                  onTap: () => Navigator.pop(context, widget.idOf(it)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen searchable MULTI-select. Returns the chosen ids, or null if
/// cancelled.
Future<Set<String>?> showMultiSearchPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) idOf,
  required String Function(T) labelOf,
  required Set<String> selected,
  String Function(T)? subtitleOf,
}) {
  return Navigator.of(context).push<Set<String>>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => _MultiSearchPickerScreen<T>(
      title: title,
      items: items,
      idOf: idOf,
      labelOf: labelOf,
      subtitleOf: subtitleOf,
      initial: selected,
    ),
  ));
}

class _MultiSearchPickerScreen<T> extends StatefulWidget {
  const _MultiSearchPickerScreen({
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    required this.subtitleOf,
    required this.initial,
  });
  final String title;
  final List<T> items;
  final String Function(T) idOf;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final Set<String> initial;

  @override
  State<_MultiSearchPickerScreen<T>> createState() =>
      _MultiSearchPickerScreenState<T>();
}

class _MultiSearchPickerScreenState<T>
    extends State<_MultiSearchPickerScreen<T>> {
  late final Set<String> _selected = {...widget.initial};
  String _query = '';

  bool _matches(T it) {
    if (_query.isEmpty) return true;
    final hay =
        '${widget.labelOf(it)} ${widget.subtitleOf?.call(it) ?? ''}'
            .toLowerCase();
    return hay.contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = widget.items.where(_matches).toList();
    final allVisibleSelected = visible.isNotEmpty &&
        visible.every((it) => _selected.contains(widget.idOf(it)));
    return Scaffold(
      appBar: AppBar(
        title: Text(_selected.isEmpty
            ? widget.title
            : '${widget.title} · ${_selected.length}'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SearchBar(
              hintText: 'Search',
              leading: const Icon(Icons.search),
              autoFocus: true,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text('No matches for "$_query".',
                        style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final it = visible[i];
                      final sub = widget.subtitleOf?.call(it) ?? '';
                      return CheckboxListTile(
                        value: _selected.contains(widget.idOf(it)),
                        onChanged: (v) => setState(() => v == true
                            ? _selected.add(widget.idOf(it))
                            : _selected.remove(widget.idOf(it))),
                        title: Text(widget.labelOf(it)),
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
          child: FilledButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: Text('Done (${_selected.length})'),
          ),
        ),
      ),
    );
  }
}
