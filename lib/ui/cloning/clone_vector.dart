import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/database.dart';

/// Fixed palette (theme-independent) so the diagram looks identical on screen
/// and in the exported PDF. Index 0 is the backbone.
const _segmentColors = <Color>[
  Color(0xFFC96442), // terracotta — backbone
  Color(0xFF4C8C7D),
  Color(0xFF8A6FB0),
  Color(0xFFCB8A3E),
  Color(0xFF5B82B0),
  Color(0xFFB05B7A),
  Color(0xFF6FA05B),
];

const _ink = Color(0xFF1A1915);
const _muted = Color(0xFF6B6A63);

/// Parses a free-text size ("1.2 kb", "1200", "800 bp") into base pairs.
double? parseBp(String s) {
  final m = RegExp(r'([\d.]+)\s*(kb|kbp|k|bp|b)?', caseSensitive: false)
      .firstMatch(s.trim());
  if (m == null) return null;
  final n = double.tryParse(m.group(1)!);
  if (n == null) return null;
  final unit = (m.group(2) ?? '').toLowerCase();
  return unit.startsWith('k') ? n * 1000 : n;
}

class _Seg {
  _Seg({
    required this.label,
    required this.detail,
    required this.color,
    required this.length,
    required this.stroke,
    this.isBackbone = false,
  });
  final String label;
  final String detail; // second label line
  final Color color;
  final double length;
  final double stroke;
  final bool isBackbone;
  double start = 0;
  double sweep = 0;
}

/// Draws a simple circular plasmid map of the assembled vector: the backbone
/// (emphasised — thicker, with its restriction/cut sites marked) plus each
/// fragment as a labelled arc sized by its length (with a minimum so small
/// fragments stay visible). Fragment labels show size + primers. Used both as the
/// live on-screen preview and rasterised to a PNG for the PDF.
class CloneVectorPainter extends CustomPainter {
  CloneVectorPainter(this.construction, {this.primerNames = const {}});

  final CloneConstruction construction;
  final Map<String, String> primerNames;

  static const _backboneFallbackBp = 3000.0;
  static const _fragmentFallbackBp = 1500.0;

  List<_Seg> _segments(double baseStroke) {
    String primer(String id) =>
        id.isEmpty ? '' : (primerNames[id] ?? '?');
    final c = construction;
    final segs = <_Seg>[
      _Seg(
        label: c.backboneName.isEmpty ? 'Backbone' : c.backboneName,
        detail: 'Backbone',
        color: _segmentColors[0],
        length: _backboneFallbackBp,
        stroke: baseStroke * 1.6, // emphasis
        isBackbone: true,
      ),
    ];
    for (var i = 0; i < c.fragments.length; i++) {
      final f = c.fragments[i];
      final fwd = primer(f.fwdPrimerId);
      final rev = primer(f.revPrimerId);
      final primers = (fwd.isNotEmpty || rev.isNotEmpty)
          ? '${fwd.isEmpty ? '?' : fwd} → ${rev.isEmpty ? '?' : rev}'
          : '';
      final detail = [
        if (f.sizeBp.isNotEmpty) f.sizeBp,
        if (primers.isNotEmpty) primers,
      ].join('  ·  ');
      segs.add(_Seg(
        label: f.name.isEmpty ? 'Fragment ${i + 1}' : f.name,
        detail: detail,
        color: _segmentColors[(i + 1) % _segmentColors.length],
        length: parseBp(f.sizeBp) ?? _fragmentFallbackBp,
        stroke: baseStroke,
      ));
    }
    return segs;
  }

  void _layout(List<_Seg> segs) {
    final n = segs.length;
    const gap = 0.05;
    final avail = 2 * math.pi - gap * n;
    final frags = segs.where((s) => !s.isBackbone).toList();
    if (frags.isEmpty) {
      segs.first.sweep = avail;
    } else {
      const backboneShare = 0.34; // emphasised, fixed prominent slice
      final backboneSweep = avail * backboneShare;
      final fragAvail = avail - backboneSweep;
      // Floor so the smallest fragment stays visible.
      final minFrag = math.min(20 * math.pi / 180, fragAvail / frags.length * 0.6);
      final remaining = fragAvail - minFrag * frags.length;
      final totalLen = frags.fold(0.0, (a, s) => a + s.length);
      for (final s in segs) {
        if (s.isBackbone) {
          s.sweep = backboneSweep;
        } else {
          s.sweep = minFrag +
              (totalLen > 0 ? s.length / totalLen : 1 / frags.length) *
                  remaining;
        }
      }
    }
    var start = -math.pi / 2; // 12 o'clock
    for (final s in segs) {
      s.start = start;
      start += s.sweep + gap;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dim = math.min(size.width, size.height);
    final baseStroke = dim * 0.072;
    final radius = dim * 0.24;
    final center = Offset(size.width / 2, size.height / 2);
    final segs = _segments(baseStroke);
    _layout(segs);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    for (final s in segs) {
      arc
        ..color = s.color
        ..strokeWidth = s.stroke;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), s.start,
          s.sweep, false, arc);
      _drawLabel(canvas, center, radius + s.stroke / 2 + 9, s.start + s.sweep / 2,
          s.label, s.detail);
    }

    // Restriction / cut sites at the backbone's two ends.
    final bb = segs.firstWhere((s) => s.isBackbone);
    final enzymes = construction.enzymes
        .split(RegExp(r'[,/]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    _drawCutSite(canvas, center, radius, bb.stroke, bb.start,
        enzymes.isNotEmpty ? enzymes.first : null);
    _drawCutSite(canvas, center, radius, bb.stroke, bb.start + bb.sweep,
        enzymes.length > 1 ? enzymes[1] : null);

    _drawCenter(canvas, center, segs.length - 1);
  }

  Offset _at(Offset c, double r, double a) =>
      Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));

  void _drawCutSite(Canvas canvas, Offset center, double radius, double stroke,
      double angle, String? enzyme) {
    final inner = _at(center, radius - stroke / 2 - 2, angle);
    final outer = _at(center, radius + stroke / 2 + 5, angle);
    canvas.drawLine(
        inner, outer, Paint()..color = _ink..strokeWidth = 2);
    if (enzyme != null) {
      final tp = TextPainter(
        text: TextSpan(
            text: enzyme,
            style: const TextStyle(
                fontSize: 9, color: _ink, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      final cos = math.cos(angle);
      final p = _at(center, radius + stroke / 2 + 9, angle);
      final dx = cos < -0.3 ? -tp.width : (cos > 0.3 ? 0.0 : -tp.width / 2);
      tp.paint(canvas, p + Offset(dx, -tp.height / 2));
    }
  }

  void _drawLabel(Canvas canvas, Offset center, double r, double angle,
      String name, String detail) {
    final nameTp = TextPainter(
      text: TextSpan(
          text: name,
          style: const TextStyle(
              fontSize: 11, color: _ink, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 108);
    final detailTp = detail.isEmpty
        ? null
        : (TextPainter(
            text: TextSpan(
                text: detail, style: const TextStyle(fontSize: 9, color: _muted)),
            textDirection: TextDirection.ltr,
            maxLines: 2,
            ellipsis: '…',
          )..layout(maxWidth: 108));

    final cos = math.cos(angle), sin = math.sin(angle);
    final anchor = _at(center, r, angle);
    final blockH = nameTp.height + (detailTp != null ? detailTp.height + 1 : 0);
    final top = anchor.dy - blockH / 2 + sin * 3;

    double dx(double w) =>
        cos < -0.3 ? -w : (cos > 0.3 ? 0.0 : -w / 2);
    nameTp.paint(canvas, Offset(anchor.dx + dx(nameTp.width), top));
    if (detailTp != null) {
      detailTp.paint(canvas,
          Offset(anchor.dx + dx(detailTp.width), top + nameTp.height + 1));
    }
  }

  void _drawCenter(Canvas canvas, Offset center, int fragmentCount) {
    final c = construction;
    final name = TextPainter(
      text: TextSpan(
          text: c.name.isEmpty ? 'Vector' : c.name,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: _ink)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: 130);
    final sub = TextPainter(
      text: TextSpan(
          text: '$fragmentCount fragment${fragmentCount == 1 ? '' : 's'}',
          style: const TextStyle(fontSize: 10, color: _muted)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 130);
    name.paint(canvas, center + Offset(-name.width / 2, -name.height - 1));
    sub.paint(canvas, center + Offset(-sub.width / 2, 3));
  }

  @override
  bool shouldRepaint(covariant CloneVectorPainter oldDelegate) => true;
}

/// Rasterises the vector diagram to PNG bytes (white background) for embedding in
/// the PDF. Returns null if rendering isn't available (e.g. in a non-widget test
/// with no engine), so the PDF can fall back to its text legend.
Future<Uint8List?> renderCloneVectorPng(CloneConstruction c,
    {Map<String, String> primerNames = const {}, double size = 660}) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size),
        Paint()..color = const Color(0xFFFFFFFF));
    CloneVectorPainter(c, primerNames: primerNames)
        .paint(canvas, Size(size, size));
    final picture = recorder.endRecording();
    // toImageSync (not toImage): synchronous, so it can't hang where there's no
    // frame scheduler (it throws instead, which we catch).
    final image = picture.toImageSync(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return bytes?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
