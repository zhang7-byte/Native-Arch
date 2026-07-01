import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/image_repository.dart';
import '../app_database_provider.dart';
import 'annotation.dart';

const _palette = <int>[
  0xFFE53935, // red
  0xFFFB8C00, // orange
  0xFFFDD835, // yellow
  0xFF43A047, // green
  0xFF1E88E5, // blue
  0xFF000000, // black
  0xFFFFFFFF, // white
];

/// Draw markup (arrows, boxes, ovals, text labels) over an attached image. Saves
/// the annotations back onto the image (re-editable next time).
class AnnotateScreen extends StatefulWidget {
  const AnnotateScreen({super.key, required this.imageId});

  final String imageId;

  @override
  State<AnnotateScreen> createState() => _AnnotateScreenState();
}

class _AnnotateScreenState extends State<AnnotateScreen> {
  Uint8List? _bytes;
  double _aspect = 1;
  List<ImageAnnotation> _ann = [];
  String _tool = 'arrow';
  int _color = 0xFFE53935;
  int? _selected;
  ImageAnnotation? _draft;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ImageRepository(AppDatabaseProvider.of(context));
    final bytes = await repo.bytesFor(widget.imageId);
    final img = await repo.watchById(widget.imageId).first;
    if (bytes != null) {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _aspect = frame.image.width / frame.image.height;
      frame.image.dispose();
    }
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _ann = List.of(img?.annotations ?? const <ImageAnnotation>[]);
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final repo = ImageRepository(AppDatabaseProvider.of(context));
    final navigator = Navigator.of(context);
    await repo.updateAnnotations(widget.imageId, _ann);
    navigator.pop();
  }

  int? _hitTest(Offset n) {
    for (var i = _ann.length - 1; i >= 0; i--) {
      final a = _ann[i];
      final r = Rect.fromLTRB(math.min(a.x1, a.x2), math.min(a.y1, a.y2),
              math.max(a.x1, a.x2), math.max(a.y1, a.y2))
          .inflate(0.03);
      if (r.contains(n)) return i;
    }
    return null;
  }

  Future<String?> _askText({String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Label text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annotate'),
        actions: [
          TextButton(onPressed: _loaded ? _save : null, child: const Text('Save')),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _bytes == null
              ? const Center(child: Text('Image is not downloaded yet.'))
              : Column(
                  children: [
                    Expanded(child: _canvas()),
                    _toolbar(),
                  ],
                ),
    );
  }

  Widget _canvas() {
    return LayoutBuilder(
      builder: (ctx, c) {
        double pw = c.maxWidth;
        double ph = pw / _aspect;
        if (ph > c.maxHeight) {
          ph = c.maxHeight;
          pw = ph * _aspect;
        }
        final size = Size(pw, ph);
        Offset norm(Offset local) => Offset(
            (local.dx / size.width).clamp(0.0, 1.0),
            (local.dy / size.height).clamp(0.0, 1.0));
        return Center(
          child: SizedBox(
            width: pw,
            height: ph,
            child: GestureDetector(
              onPanStart: (d) {
                if (_tool == 'text') return;
                final n = norm(d.localPosition);
                setState(() {
                  _selected = null;
                  _draft = ImageAnnotation(
                      type: _tool,
                      x1: n.dx,
                      y1: n.dy,
                      x2: n.dx,
                      y2: n.dy,
                      color: _color);
                });
              },
              onPanUpdate: (d) {
                if (_draft == null) return;
                final n = norm(d.localPosition);
                setState(() => _draft = _draft!.copyWith(x2: n.dx, y2: n.dy));
              },
              onPanEnd: (_) {
                final dd = _draft;
                if (dd == null) return;
                final dist = (dd.x2 - dd.x1).abs() + (dd.y2 - dd.y1).abs();
                setState(() {
                  if (dist > 0.02) _ann.add(dd);
                  _draft = null;
                });
              },
              onTapUp: (d) async {
                final n = norm(d.localPosition);
                if (_tool == 'text') {
                  final text = await _askText();
                  if (text != null && text.trim().isNotEmpty) {
                    setState(() => _ann.add(ImageAnnotation(
                        type: 'text',
                        x1: n.dx,
                        y1: n.dy,
                        x2: n.dx,
                        y2: n.dy,
                        text: text.trim(),
                        color: _color)));
                  }
                } else {
                  setState(() => _selected = _hitTest(n));
                }
              },
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Image.memory(_bytes!, fit: BoxFit.fill)),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: AnnotationPainter([..._ann, ?_draft],
                          selected: _selected),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toolbar() {
    final scheme = Theme.of(context).colorScheme;
    Widget toolBtn(String tool, IconData icon, String tip) => IconButton(
          tooltip: tip,
          icon: Icon(icon),
          isSelected: _tool == tool,
          style: IconButton.styleFrom(
            backgroundColor:
                _tool == tool ? scheme.secondaryContainer : null,
          ),
          onPressed: () => setState(() => _tool = tool),
        );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                toolBtn('arrow', Icons.north_east, 'Arrow'),
                toolBtn('rect', Icons.crop_square, 'Box'),
                toolBtn('oval', Icons.circle_outlined, 'Oval'),
                toolBtn('text', Icons.title, 'Text label'),
                const Spacer(),
                IconButton(
                  tooltip: 'Delete selected',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selected == null
                      ? null
                      : () => setState(() {
                            _ann.removeAt(_selected!);
                            _selected = null;
                          }),
                ),
                IconButton(
                  tooltip: 'Undo',
                  icon: const Icon(Icons.undo),
                  onPressed: _ann.isEmpty
                      ? null
                      : () => setState(() {
                            _ann.removeLast();
                            _selected = null;
                          }),
                ),
                IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(Icons.layers_clear_outlined),
                  onPressed: _ann.isEmpty
                      ? null
                      : () => setState(() {
                            _ann.clear();
                            _selected = null;
                          }),
                ),
              ],
            ),
            Row(
              children: [
                for (final c in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == c
                              ? scheme.onSurface
                              : scheme.outlineVariant,
                          width: _color == c ? 3 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
