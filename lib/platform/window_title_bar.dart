import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../sync/sync_controller.dart';
import '../ui/account/sync_scope.dart';
import '../ui/glass.dart';
import '../ui/search/global_search.dart';

/// True on the desktop targets that get a custom title bar.
bool get isDesktopWindow =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS);

/// A custom title bar matching the Section 9 design language. Drawn on the
/// `--bg-sidebar` tone so it reads as continuous with the app below — no hard
/// seam. The whole bar (except the caption buttons) drags the window and
/// double-clicks to maximise/restore. On Windows/Linux it draws minimise,
/// maximise/restore and close buttons; on macOS it leaves room for the native
/// traffic lights instead. A no-op on web/mobile.
///
/// The bar is always painted as the topmost layer (see main.dart) so its logo
/// and caption buttons stay perfectly sharp — never sampled into the frosted
/// `BackdropFilter` below. With a custom background its own fill is transparent
/// so the frosted surface shows through continuously; otherwise it paints the
/// solid `--bg-sidebar` tone.
class WindowTitleBar extends StatefulWidget {
  const WindowTitleBar(
      {super.key, this.customBg = false, this.onMinimize, this.navigatorKey});

  /// When true a custom app background is active, so the bar stays transparent
  /// and lets the frosted surface behind it show through.
  final bool customBg;

  /// Overrides what the minimise button does (e.g. minimise to the system tray).
  /// Defaults to a normal window minimise.
  final VoidCallback? onMinimize;

  /// Root navigator key, used to show the pull-confirm dialog and sync snackbars
  /// from the title bar (which sits above the Navigator and has no Navigator of
  /// its own). When null, the cloud push/pull buttons are not shown.
  final GlobalKey<NavigatorState>? navigatorKey;

  static const double height = 40;

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar> with WindowListener {
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    if (isDesktopWindow) {
      windowManager.addListener(this);
      windowManager.isMaximized().then((v) {
        if (mounted) setState(() => _maximized = v);
      });
    }
  }

  @override
  void dispose() {
    if (isDesktopWindow) windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  Future<void> _toggleMaximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDesktopWindow) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;

    return Container(
      height: WindowTitleBar.height,
      // Transparent over a custom background (frosted surface shows through);
      // solid --bg-sidebar otherwise.
      color: widget.customBg ? Colors.transparent : scheme.surfaceContainerLowest,
      child: Stack(
        children: [
          // Full-width drag region behind everything; double-click maximises.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _toggleMaximize,
              child: const DragToMoveArea(child: SizedBox.expand()),
            ),
          ),
          // Name (left, passes pointers through to the drag area) + caption
          // buttons (right, receive their own taps).
          Row(
            children: [
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(left: isMac ? 76 : 14, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_outlined,
                          size: 16, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text('labtrack',
                          style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              // The bar sits above the Navigator (no Material
                              // ancestor), so without this the Text inherits
                              // Flutter's yellow "unstyled text" underline.
                              decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Global search palette (search across data or a chosen scope).
              if (widget.navigatorKey != null)
                _SearchButton(navigatorKey: widget.navigatorKey!),
              const Spacer(),
              // Cloud sync push/pull, shown when signed in — placed in front of
              // the window caption buttons.
              if (widget.navigatorKey != null)
                _SyncActions(navigatorKey: widget.navigatorKey!),
              if (!isMac) ...[
                _CaptionButton(
                    icon: Icons.remove,
                    onPressed:
                        widget.onMinimize ?? () => windowManager.minimize()),
                _CaptionButton(
                    icon: _maximized
                        ? Icons.filter_none
                        : Icons.crop_square_outlined,
                    onPressed: _toggleMaximize),
                _CaptionButton(
                    icon: Icons.close,
                    isClose: true,
                    onPressed: () => windowManager.close()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CaptionButton extends StatefulWidget {
  const _CaptionButton(
      {required this.icon, required this.onPressed, this.isClose = false});

  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final closeHover = widget.isClose && _hover;
    final bg = closeHover
        ? const Color(0xFFC42B1C) // Windows close-hover red
        : (_hover ? Theme.of(context).hoverColor : Colors.transparent);
    final fg = closeHover ? Colors.white : scheme.onSurfaceVariant;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: WindowTitleBar.height,
          color: bg,
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 15, color: fg),
        ),
      ),
    );
  }
}

/// A compact search "pill" in the title bar that opens the global-search
/// palette (a spotlight-style overlay) on the root navigator.
class _SearchButton extends StatefulWidget {
  const _SearchButton({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => openGlobalSearch(widget.navigatorKey),
        child: Container(
          height: 26,
          constraints: const BoxConstraints(maxWidth: 280, minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest
                .withValues(alpha: _hover ? 0.9 : 0.55),
            borderRadius: BorderRadius.circular(13),
            border:
                Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 15, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Search',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                        decoration: TextDecoration.none)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cloud sync push/pull actions for the title bar. Reactive to [SyncScope]:
/// hidden when signed out, a spinner while syncing, two buttons otherwise.
class _SyncActions extends StatelessWidget {
  const _SyncActions({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  Future<void> _push(SyncController sync) async {
    if (sync.isSyncing) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final ok = await showGlassDialog<bool>(
      context: ctx,
      builder: (c) => GlassAlertDialog(
        title: const Text('Push to cloud?'),
        content: const Text(
            'This uploads this device\'s data to the cloud, overwriting the '
            'cloud copy. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Push')),
        ],
      ),
    );
    if (ok != true) return;
    await sync.push();
    _report(sync, 'Pushed to cloud');
  }

  Future<void> _pull(SyncController sync) async {
    if (sync.isSyncing) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    final ok = await showGlassDialog<bool>(
      context: ctx,
      builder: (c) => GlassAlertDialog(
        title: const Text('Pull from cloud?'),
        content: const Text(
            'This replaces ALL data on this device with the cloud copy. A local '
            'backup of the current data is saved first. Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Pull')),
        ],
      ),
    );
    if (ok != true) return;
    await sync.pull();
    _report(sync, 'Pulled from cloud');
  }

  void _report(SyncController sync, String okMessage) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(SnackBar(
      content:
          Text(sync.error != null ? 'Sync failed: ${sync.error}' : okMessage),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sync = SyncScope.of(context);
    // Only relevant once the user is signed in to the cloud.
    if (!sync.isSignedIn) return const SizedBox.shrink();
    if (sync.isSyncing) {
      return const SizedBox(
        width: 46,
        height: WindowTitleBar.height,
        child: Center(
          child: SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BarActionButton(
            icon: Icons.cloud_upload_outlined, onPressed: () => _push(sync)),
        _BarActionButton(
            icon: Icons.cloud_download_outlined, onPressed: () => _pull(sync)),
        const SizedBox(width: 6),
      ],
    );
  }
}

/// An app-action button styled for the title bar (distinct from the window
/// caption buttons): narrower, with an accent-on-hover icon.
class _BarActionButton extends StatefulWidget {
  const _BarActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_BarActionButton> createState() => _BarActionButtonState();
}

class _BarActionButtonState extends State<_BarActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 40,
          height: WindowTitleBar.height,
          color: _hover ? Theme.of(context).hoverColor : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(widget.icon,
              size: 16,
              color: _hover ? scheme.primary : scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
