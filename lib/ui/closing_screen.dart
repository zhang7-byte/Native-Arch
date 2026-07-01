import 'package:flutter/material.dart';

/// A brief, on-brand goodbye shown while the app finishes shutting down. It
/// pops the LabTrack mark in and runs an indeterminate bar so the final moments
/// read as a graceful close rather than a frozen frame (the teardown work that
/// used to look like a freeze now happens behind this).
class ClosingScreen extends StatefulWidget {
  const ClosingScreen({super.key});

  @override
  State<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends State<ClosingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Center(
        child: AnimatedBuilder(
          animation: _intro,
          builder: (context, child) {
            final t = Curves.easeOutBack.transform(_intro.value);
            final fade = Curves.easeOut.transform(_intro.value);
            return Opacity(
              opacity: fade.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.86 + 0.14 * t, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.science_outlined,
                    size: 42, color: scheme.primary),
              ),
              const SizedBox(height: 22),
              Text(
                'labtrack',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Wrapping up your workspace…',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 132,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
