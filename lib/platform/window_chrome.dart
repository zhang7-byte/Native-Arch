import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('labtrack/window');

bool get _isWindowsDesktop =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// Colours the native Windows title bar (caption + text + button glyphs) to
/// match the app theme, so the system chrome blends into the warm-paper surface
/// instead of a hard white-to-content seam. No-op off Windows.
Future<void> applyWindowsTitleBar(Brightness brightness) async {
  if (!_isWindowsDesktop) return;
  final dark = brightness == Brightness.dark;
  // Warm-paper tokens (Section 9), passed as 0xRRGGBB.
  final caption = dark ? 0x1E1D1A : 0xFAF9F5;
  final text = dark ? 0xECEAE3 : 0x1A1915;
  try {
    await _channel.invokeMethod<void>('setTitleBar', {
      'caption': caption,
      'text': text,
      'dark': dark,
    });
  } catch (_) {
    // Older Windows (pre-11) doesn't support caption colouring — ignore.
  }
}

/// Re-applies the native title-bar colour whenever the resolved theme
/// brightness changes. Wrap the app content with this.
class WindowChromeSync extends StatefulWidget {
  const WindowChromeSync({super.key, required this.child});

  final Widget child;

  @override
  State<WindowChromeSync> createState() => _WindowChromeSyncState();
}

class _WindowChromeSyncState extends State<WindowChromeSync> {
  Brightness? _last;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    if (brightness != _last) {
      _last = brightness;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => applyWindowsTitleBar(brightness));
    }
    return widget.child;
  }
}
