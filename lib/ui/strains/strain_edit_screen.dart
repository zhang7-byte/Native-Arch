import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/strain_repository.dart';
import '../app_database_provider.dart';

/// Create (when [strain] is null) or edit a strain.
///
/// In [embedded] mode the form renders without its own Scaffold/AppBar so it can
/// live inside a desktop master-detail pane: it shows a slim header with a Save
/// (and, when creating, Cancel) action and calls [onSaved]/[onCancel] instead of
/// popping a route.
class StrainEditScreen extends StatefulWidget {
  const StrainEditScreen({
    super.key,
    this.strain,
    this.embedded = false,
    this.onSaved,
    this.onCancel,
  });

  final Strain? strain;

  /// Render as an embedded pane (no Scaffold/AppBar) rather than a full route.
  final bool embedded;

  /// Called after a successful save when [embedded] (instead of popping).
  final VoidCallback? onSaved;

  /// Called when the user cancels an embedded "new strain" form.
  final VoidCallback? onCancel;

  bool get isEditing => strain != null;

  @override
  State<StrainEditScreen> createState() => _StrainEditScreenState();
}

class _StrainEditScreenState extends State<StrainEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.strain;
    _c = {
      'name': TextEditingController(text: s?.name ?? ''),
      'serial': TextEditingController(text: s?.serialNumber ?? ''),
      'host': TextEditingController(text: s?.hostOrganism ?? ''),
      'genotype': TextEditingController(text: s?.genotype ?? ''),
      'plasmid': TextEditingController(text: s?.plasmid ?? ''),
      'construct': TextEditingController(text: s?.constructNotes ?? ''),
      'markers':
          TextEditingController(text: s?.selectionMarkers.join(', ') ?? ''),
      'freezer': TextEditingController(text: s?.freezerLocation ?? ''),
      'notes': TextEditingController(text: s?.notes ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String k) => _c[k]!.text.trim();

  List<String> _list(String k) => _c[k]!
      .text
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = StrainRepository(AppDatabaseProvider.of(context));
    final navigator = widget.embedded ? null : Navigator.of(context);
    setState(() => _saving = true);
    try {
      final companion = StrainsCompanion(
        name: Value(_t('name')),
        serialNumber: Value(_t('serial')),
        hostOrganism: Value(_t('host')),
        genotype: Value(_t('genotype')),
        plasmid: Value(_t('plasmid')),
        constructNotes: Value(_t('construct')),
        selectionMarkers: Value(_list('markers')),
        freezerLocation: Value(_t('freezer')),
        notes: Value(_t('notes')),
      );
      if (widget.isEditing) {
        await repo.update(widget.strain!.id, companion);
      } else {
        await repo.create(StrainsCompanion.insert(
          name: _t('name'),
          serialNumber: Value(_t('serial')),
          hostOrganism: Value(_t('host')),
          genotype: Value(_t('genotype')),
          plasmid: Value(_t('plasmid')),
          constructNotes: Value(_t('construct')),
          selectionMarkers: Value(_list('markers')),
          freezerLocation: Value(_t('freezer')),
          notes: Value(_t('notes')),
        ));
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

  Widget _field(String key, String label, {int maxLines = 1, String? helper}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _c[key],
        minLines: maxLines > 1 ? 2 : 1,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label, helperText: helper),
        validator: key == 'name'
            ? (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving;
    final Widget body = Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field('name', 'Name'),
          _field('serial', 'Serial number'),
          _field('host', 'Host organism'),
          _field('genotype', 'Genotype'),
          _field('plasmid', 'Plasmid'),
          _field('construct', 'Construct notes', maxLines: 4),
          _field('markers', 'Selection markers',
              helper: 'Comma-separated, e.g. Kanamycin, Ampicillin'),
          _field('freezer', 'Freezer location'),
          _field('notes', 'Notes', maxLines: 4),
        ],
      ),
    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _embeddedHeader(scheme, canSave),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit strain' : 'New strain'),
        actions: [
          TextButton(
              onPressed: canSave ? _save : null, child: const Text('Save')),
        ],
      ),
      body: body,
    );
  }

  /// Slim toolbar shown above the form when [StrainEditScreen.embedded].
  Widget _embeddedHeader(ColorScheme scheme, bool canSave) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEditing ? 'Strain' : 'New strain',
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
              onPressed: canSave ? _save : null,
              child: Text(_saving ? 'Saving…' : 'Save')),
        ],
      ),
    );
  }
}
