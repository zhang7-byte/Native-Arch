import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/reagent_repository.dart';
import '../app_database_provider.dart';
import '../labels.dart';

/// Create (when [reagent] is null) or edit a reagent or buffer.
///
/// In [embedded] mode the form renders without its own Scaffold/AppBar so it can
/// live inside a desktop master-detail pane: it shows a slim header with a Save
/// (and, when creating, Cancel) action and calls [onSaved]/[onCancel] instead of
/// popping a route.
class ReagentEditScreen extends StatefulWidget {
  const ReagentEditScreen({
    super.key,
    this.reagent,
    this.initialKind,
    this.embedded = false,
    this.onSaved,
    this.onCancel,
  });

  final Reagent? reagent;

  /// Default kind for a NEW entry: 'reagent' (default) or 'buffer'.
  final String? initialKind;

  /// Render as an embedded pane (no Scaffold/AppBar) rather than a full route.
  final bool embedded;

  /// Called after a successful save when [embedded] (instead of popping).
  final VoidCallback? onSaved;

  /// Called when the user cancels an embedded "new reagent" form.
  final VoidCallback? onCancel;

  bool get isEditing => reagent != null;

  @override
  State<ReagentEditScreen> createState() => _ReagentEditScreenState();
}

class _ReagentEditScreenState extends State<ReagentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  DateTime? _expiry;
  bool _saving = false;
  late String _kind;

  @override
  void initState() {
    super.initState();
    final r = widget.reagent;
    _c = {
      'name': TextEditingController(text: r?.name ?? ''),
      'supplier': TextEditingController(text: r?.supplier ?? ''),
      'catalog': TextEditingController(text: r?.catalogNo ?? ''),
      'lot': TextEditingController(text: r?.lot ?? ''),
      'location': TextEditingController(text: r?.location ?? ''),
      'quantity': TextEditingController(text: r?.quantity ?? ''),
      'recipe': TextEditingController(text: r?.recipe ?? ''),
      'notes': TextEditingController(text: r?.notes ?? ''),
    };
    _expiry = r?.expiryDate;
    _kind = r?.kind ?? widget.initialKind ?? 'reagent';
  }

  bool get _isBuffer => _kind == 'buffer';

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String k) => _c[k]!.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ReagentRepository(AppDatabaseProvider.of(context));
    final navigator = widget.embedded ? null : Navigator.of(context);
    setState(() => _saving = true);
    try {
      if (widget.isEditing) {
        await repo.update(
          widget.reagent!.id,
          ReagentsCompanion(
            name: Value(_t('name')),
            kind: Value(_kind),
            supplier: Value(_isBuffer ? '' : _t('supplier')),
            catalogNo: Value(_isBuffer ? '' : _t('catalog')),
            lot: Value(_isBuffer ? '' : _t('lot')),
            location: Value(_t('location')),
            expiryDate: Value(_expiry),
            quantity: Value(_t('quantity')),
            recipe: Value(_t('recipe')),
            notes: Value(_t('notes')),
          ),
        );
      } else {
        await repo.create(ReagentsCompanion.insert(
          name: _t('name'),
          kind: Value(_kind),
          supplier: Value(_isBuffer ? '' : _t('supplier')),
          catalogNo: Value(_isBuffer ? '' : _t('catalog')),
          lot: Value(_isBuffer ? '' : _t('lot')),
          location: Value(_t('location')),
          expiryDate: Value(_expiry),
          quantity: Value(_t('quantity')),
          recipe: Value(_t('recipe')),
          notes: Value(_t('notes')),
        ));
      }
      if (widget.embedded) {
        widget.onSaved?.call();
      } else {
        if (mounted) navigator!.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _c[key],
        minLines: maxLines > 1 ? 2 : 1,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        validator: key == 'name'
            ? (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noun = _isBuffer ? 'buffer' : 'reagent';
    final scheme = Theme.of(context).colorScheme;
    final canSave = !_saving;
    final Widget body = Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('name', 'Name'),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'reagent',
                      label: Text('Reagent'),
                      icon: Icon(Icons.science_outlined)),
                  ButtonSegment(
                      value: 'buffer',
                      label: Text('Buffer'),
                      icon: Icon(Icons.opacity_outlined)),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
            ),
            _field('recipe', _isBuffer ? 'Recipe' : 'Recipe / composition',
                maxLines: 5),
            if (!_isBuffer) ...[
              _field('supplier', 'Supplier'),
              _field('catalog', 'Catalog no.'),
              _field('lot', 'Lot'),
            ],
            _field('location', 'Location'),
            _field('quantity', 'Quantity'),
            Row(
              children: [
                Expanded(child: Text('Expiry date: ${formatDate(_expiry)}')),
                if (_expiry != null)
                  IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                      onPressed: () => setState(() => _expiry = null)),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiry ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _expiry = picked);
                  },
                  icon: const Icon(Icons.event),
                  label: const Text('Pick'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
        title: Text(widget.isEditing ? 'Edit $noun' : 'New $noun'),
        actions: [
          TextButton(
              onPressed: canSave ? _save : null, child: const Text('Save')),
        ],
      ),
      body: body,
    );
  }

  /// Slim toolbar shown above the form when [ReagentEditScreen.embedded].
  Widget _embeddedHeader(ColorScheme scheme, bool canSave) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEditing ? 'Reagent' : 'New reagent',
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
