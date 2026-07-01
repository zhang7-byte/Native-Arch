import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/database.dart';

/// Draws a list of [ImageAnnotation]s over the image rect of [size]. Coordinates
/// are normalised (0..1) so the same painter works at preview size, full size,
/// and the image's native size (for the PDF flatten).
class AnnotationPainter extends CustomPainter {
  AnnotationPainter(this.annotations, {this.selected});

  final List<ImageAnnotation> annotations;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 500;
    for (var i = 0; i < annotations.length; i++) {
      final a = annotations[i];
      final p1 = Offset(a.x1 * size.width, a.y1 * size.height);
      final p2 = Offset(a.x2 * size.width, a.y2 * size.height);
      final color = Color(a.color);
      final sw = (a.strokeWidth * scale).clamp(1.0, 30.0);
      final paint = Paint()
        ..color = color
        ..strokeWidth = sw
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      switch (a.type) {
        case 'rect':
          canvas.drawRect(Rect.fromPoints(p1, p2), paint);
        case 'oval':
          canvas.drawOval(Rect.fromPoints(p1, p2), paint);
        case 'text':
          _text(canvas, p1, a.text, color, size, scale);
        case 'arrow':
        default:
          _arrow(canvas, p1, p2, paint, sw);
      }
      if (i == selected) {
        final r = Rect.fromPoints(p1, p2).inflate(8 * scale);
        canvas.drawRect(
            r,
            Paint()
              ..color = color
              ..strokeWidth = 1.5 * scale
              ..style = PaintingStyle.stroke);
      }
    }
  }

  void _arrow(Canvas canvas, Offset p1, Offset p2, Paint paint, double sw) {
    canvas.drawLine(p1, p2, paint);
    final angle = (p2 - p1).direction;
    final headLen = 6 + sw * 2.5;
    for (final da in [math.pi - 0.5, math.pi + 0.5]) {
      canvas.drawLine(
          p2, p2 + Offset(math.cos(angle + da), math.sin(angle + da)) * headLen,
          paint);
    }
  }

  void _text(
      Canvas canvas, Offset p, String text, Color color, Size size, double scale) {
    if (text.isEmpty) return;
    final fontSize = (14 * scale).clamp(10.0, 60.0);
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.7);
    final rect = Rect.fromLTWH(p.dx, p.dy, tp.width + 8, tp.height + 4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.72));
    tp.paint(canvas, p + const Offset(4, 2));
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter old) =>
      old.annotations != annotations || old.selected != selected;
}

/// An image with its annotation overlay drawn on top, sized to the image's
/// aspect ratio (so the overlay lines up exactly — no letterboxing).
class AnnotatedImage extends StatefulWidget {
  const AnnotatedImage(
      {super.key, required this.bytes, required this.annotations});

  final Uint8List bytes;
  final List<ImageAnnotation> annotations;

  @override
  State<AnnotatedImage> createState() => _AnnotatedImageState();
}

class _AnnotatedImageState extends State<AnnotatedImage> {
  double? _aspect;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(AnnotatedImage old) {
    super.didUpdateWidget(old);
    if (old.bytes != widget.bytes) _decode();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => _aspect = frame.image.width / frame.image.height);
      }
      frame.image.dispose();
    } catch (_) {/* keep null → fallback */}
  }

  @override
  Widget build(BuildContext context) {
    final a = _aspect;
    if (a == null || a <= 0) {
      return Image.memory(widget.bytes, fit: BoxFit.contain);
    }
    return AspectRatio(
      aspectRatio: a,
      child: Stack(
        children: [
          Positioned.fill(child: Image.memory(widget.bytes, fit: BoxFit.fill)),
          if (widget.annotations.isNotEmpty)
            Positioned.fill(
                child: CustomPaint(painter: AnnotationPainter(widget.annotations))),
        ],
      ),
    );
  }
}

/// Flattens [annotations] onto [bytes] and returns the composited PNG, at the
/// image's native resolution. Returns null when there's nothing to draw or
/// rendering isn't available (so callers fall back to the original bytes).
Future<Uint8List?> renderAnnotatedImagePng(
    Uint8List bytes, List<ImageAnnotation> annotations) async {
  if (annotations.isEmpty) return null;
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());
    AnnotationPainter(annotations)
        .paint(canvas, Size(image.width.toDouble(), image.height.toDouble()));
    final picture = recorder.endRecording();
    final out = picture.toImageSync(image.width, image.height);
    final png = await out.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    out.dispose();
    picture.dispose();
    return png?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
