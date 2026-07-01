import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/culture_repository.dart';
import '../../data/database.dart';
import '../../data/strain_repository.dart';
import '../app_database_provider.dart';
import '../search_picker.dart';

/// Create or edit a culture. A culture is usually started from a strain, so the
/// strain can be pre-filled via [defaultStrainId].
///
/// In [embedded] mode the form renders without its own Scaffold/AppBar so it can
/// live inside a desktop master-detail pane: it shows a slim header with a Save
/// (and, when creating, Cancel) action and calls [onSaved]/[onCancel] instead of
/// popping a route.
class CultureEditScreen extends StatefulWidget {
  const CultureEditScreen({
    super.key,
    this.culture,
    this.defaultStrainId,
    this.embedded = false,
    this.onSaved,
    this.onCancel,
  });

  final Culture? culture;
  final String? defaultStrainId;

  /// Render as an embedded pane (no Scaffold/AppBar) rather than a full route.
  final bool embedded;

  /// Called after a successful save when [embedded] (instead of popping).
  final VoidCallback? onSaved;

  /// Called when the user cancels an embedded "new culture" form.
  final VoidCallback? onCancel;

  bool get isEditing => culture != null;

  @override
  State<CultureEditScreen> createState() => _CultureEditScreenState();
}

class _CultureEditScreenState extends State<CultureEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _medium;
  late final TextEditingController _vessel;
  late final TextEditingController _inoculum;
  late final TextEditingController _markers;
  late final TextEditingController _notes;
  late final TextEditingController _purpose;
  String? _strainId;
  List<Strain> _strains = const [];
  bool _prefilledOnce = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.culture;
    _name = TextEditingController(text: c?.name ?? '');
    _medium = TextEditingController(text: c?.medium ?? '');
    _vessel = TextEditingController(text: c?.vessel ?? '');
    _inoculum = TextEditingController(text: c?.inoculumAmount ?? '');
    _markers =
        TextEditingController(text: c?.selectionMarkers.join(', ') ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    _purpose = TextEditingController(text: c?.purpose ?? '');
    _strainId = c?.strainId ?? widget.defaultStrainId;
  }

  @override
  void dispose() {
    _name.dispose();
    _medium.dispose();
    _vessel.dispose();
    _inoculum.dispose();
    _markers.dispose();
    _notes.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Strain? _strainById(String? id) {
    for (final s in _strains) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// When a strain is chosen and the markers field is empty, suggest the
  /// strain's selection markers (still editable).
  void _maybePrefillMarkers() {
    if (_markers.text.trim().isNotEmpty) return;
    final s = _strainById(_strainId);
    if (s != null && s.selectionMarkers.isNotEmpty) {
      _markers.text = s.selectionMarkers.join(', ');
    }
  }

  List<String> _list(TextEditingController c) => c.text
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  Future<void> _save(CultureRepository repo) async {
    final navigator = widget.embedded ? null : Navigator.of(context);
    setState(() => _saving = true);
    try {
      final values = CulturesCompanion(
        name: Value(_name.text.trim()),
        strainId: Value(_strainId),
        medium: Value(_medium.text.trim()),
        vessel: Value(_vessel.text.trim()),
        inoculumAmount: Value(_inoculum.text.trim()),
        selectionMarkers: Value(_list(_markers)),
        notes: Value(_notes.text.trim()),
        purpose: Value(_purpose.text.trim()),
      );
      if (widget.culture == null) {
        await repo.create(values);
      } else {
        await repo.update(widget.culture!.id, values);
      }
      if (widget.embedded) {
        widget.onSaved?.call();
      } else {
        navigator!.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabaseProvider.of(context);
    final repo = CultureRepository(db);
    final scheme = Theme.of(context).colorScheme;
    final editing = widget.culture != null;
    final canSave = !_saving;
    final Widget body = FutureBuilder<List<Strain>>(
        future: StrainRepository(db).all(),
        builder: (context, snap) {
          _strains = snap.data ?? _strains;
          // For a brand-new culture pre-seeded with a strain, suggest its
          // markers once the strain list has loaded.
          if (snap.hasData && !_prefilledOnce) {
            _prefilledOnce = true;
            if (!editing && _strainId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(_maybePrefillMarkers);
              });
            }
          }
          // Drop a stale/unknown strain id so the dropdown stays valid.
          final value =
              _strains.any((s) => s.id == _strainId) ? _strainId : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Name / label',
                    hintText: 'e.g. 2419 in YPD #1'),
              ),
              const SizedBox(height: 16),
              SearchPickerField<Strain>(
                label: 'Strain',
                items: _strains,
                selectedId: value ?? '',
                idOf: (s) => s.id,
                labelOf: (s) => s.name,
                subtitleOf: (s) => [
                  if (s.serialNumber.isNotEmpty) '#${s.serialNumber}',
                  if (s.hostOrganism.isNotEmpty) s.hostOrganism,
                  if (s.plasmid.isNotEmpty) 'plasmid ${s.plasmid}',
                ].join(' · '),
                onChanged: (v) => setState(() {
                  _strainId = v.isEmpty ? null : v;
                  _maybePrefillMarkers();
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _markers,
                decoration: const InputDecoration(
                    labelText: 'Selection markers',
                    helperText:
                        'Comma-separated, e.g. Kanamycin, Ampicillin'),
              ),
              const SizedBox(height: 16),
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
                controller: _purpose,
                decoration: const InputDecoration(
                    labelText: 'Purpose',
                    hintText: 'e.g. overnight starter for miniprep'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              if (!widget.embedded) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: canSave ? () => _save(repo) : null,
                  icon: const Icon(Icons.check),
                  label: Text(_saving
                      ? 'Saving…'
                      : (editing ? 'Save' : 'Start culture')),
                ),
              ],
            ],
          );
        },
      );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _embeddedHeader(scheme, repo, canSave),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit culture' : 'New culture')),
      body: body,
    );
  }

  /// Slim toolbar shown above the form when [CultureEditScreen.embedded].
  Widget _embeddedHeader(
      ColorScheme scheme, CultureRepository repo, bool canSave) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEditing ? 'Culture' : 'New culture',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface),
            ),
          ),
          if (!widget.isEditing && widget.onCancel != null)
            TextButton(
                onPressed: _saving ? null : widget.onCancel,
                child: const Text('Cancel')),
          const SizedBox(width: 8),
          FilledButton(
              onPressed: canSave ? () => _save(repo) : null,
              child: Text(_saving ? 'Saving…' : 'Save')),
        ],
      ),
    );
  }
}
