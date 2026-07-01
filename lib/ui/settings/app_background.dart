import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/database.dart';

/// Minimum frosted-surface fill opacity. Even at the most transparent setting,
/// the content surface keeps enough tint for text to stay readable over a busy
/// background.
const kMinSurfaceOpacity = 0.55;
const kMaxSurfaceBlur = 50.0;

/// True when [s] selects a custom app background (so the content sits on a
/// frosted surface instead of the normal flat one).
bool hasCustomBackground(AppSetting s) => s.bgMode != 'none';

Uint8List? decodeBgImage(String b64) {
  if (b64.isEmpty) return null;
  try {
    return base64Decode(b64);
  } catch (_) {
    return null;
  }
}

/// Lays the entire app on ONE frosted-glass content surface over the user's
/// background: a single [BackdropFilter] blurs the background, and a theme-tinted
/// semi-transparent fill (with a legibility floor) backs every screen. Scaffolds,
/// the sidebar, cards and list sections all sit on this single surface — no
/// per-row blur. A no-op when no background is set (normal flat Section 9
/// surface).
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.setting, required this.child});

  final AppSetting setting;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hasCustomBackground(setting)) return child;
    final scheme = Theme.of(context).colorScheme;

    Widget background;
    switch (setting.bgMode) {
      case 'gradient':
        background = DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(setting.bgColorA), Color(setting.bgColorB)],
            ),
          ),
        );
      case 'image':
        final bytes = decodeBgImage(setting.bgImage);
        background = bytes == null
            ? ColoredBox(color: Color(setting.bgColorA))
            : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
      case 'color':
      default:
        background = ColoredBox(color: Color(setting.bgColorA));
    }

    final dim = setting.bgDim.clamp(0.0, 1.0);
    final opacity = setting.surfaceOpacity.clamp(kMinSurfaceOpacity, 1.0);
    final blur = setting.surfaceBlur.clamp(0.0, kMaxSurfaceBlur);

    return Stack(
      fit: StackFit.expand,
      children: [
        background,
        // Dim the background image itself (separate from the surface).
        if (dim > 0)
          ColoredBox(color: scheme.surface.withValues(alpha: dim)),
        // The single frosted content surface: one BackdropFilter softens the
        // background; the tinted fill (>= legibility floor) backs all content.
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: scheme.surface.withValues(alpha: opacity),
            child: child,
          ),
        ),
      ],
    );
  }
}
