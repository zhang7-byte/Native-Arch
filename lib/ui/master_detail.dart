import 'package:flutter/material.dart';

/// Exposes the detail-pane navigator to the list pane so [openDetail] can open a
/// detail/edit screen in the right-hand pane (on wide screens) instead of
/// covering the list. Absent on narrow screens, where [openDetail] falls back to
/// a normal full-screen push.
class DetailPaneScope extends InheritedWidget {
  const DetailPaneScope({
    super.key,
    required this.navigatorKey,
    required super.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;

  static DetailPaneScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DetailPaneScope>();

  /// Shows [builder] in the detail pane, replacing whatever was there (so
  /// selecting a new list item swaps the pane rather than stacking on top).
  void open(WidgetBuilder builder) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: builder),
      (route) => route.isFirst,
    );
  }

  @override
  bool updateShouldNotify(DetailPaneScope oldWidget) =>
      navigatorKey != oldWidget.navigatorKey;
}

/// Opens a list item's detail/edit screen. On wide screens (inside a
/// [MasterDetailShell]) it appears in the right-hand pane; otherwise it pushes
/// full-screen. Drop-in replacement for
/// `Navigator.of(context).push(MaterialPageRoute(builder: builder))`.
void openDetail(BuildContext context, WidgetBuilder builder) {
  final pane = DetailPaneScope.maybeOf(context);
  if (pane != null) {
    pane.open(builder);
  } else {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }
}

/// Wraps a list screen so that, on large horizontal screens, its detail/edit
/// views open in a side-by-side right pane (a master-detail layout) instead of
/// covering the list. On phones / narrow windows it's a transparent passthrough:
/// the list fills the area and details push as full-screen routes, exactly as
/// before. The wrapped list screen is used unmodified — every app-bar action,
/// FAB, ⋮ menu and button is preserved.
class MasterDetailShell extends StatefulWidget {
  const MasterDetailShell({super.key, required this.list});

  /// The existing list screen (its own Scaffold, AppBar, FAB, etc.).
  final Widget list;

  @override
  State<MasterDetailShell> createState() => _MasterDetailShellState();
}

class _MasterDetailShellState extends State<MasterDetailShell> {
  final _paneKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Never split on phones (in any orientation); only genuinely large screens.
    final isPhone = MediaQuery.sizeOf(context).shortestSide < 600;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = !isPhone && constraints.maxWidth >= 760;
        if (!wide) return widget.list;
        final scheme = Theme.of(context).colorScheme;
        return DetailPaneScope(
          navigatorKey: _paneKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: widget.list),
              VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
              Expanded(flex: 6, child: _DetailPane(navigatorKey: _paneKey)),
            ],
          ),
        );
      },
    );
  }
}

/// The right pane: a self-contained nested [Navigator] whose first route is a
/// placeholder. [DetailPaneScope.open] pushes detail/edit screens onto it.
class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    // A nested Navigator must NOT share MaterialApp's HeroController (Flutter
    // forbids one HeroController across two Navigators, which would crash on
    // wide screens). The pane's screens don't need Hero flights, so give it an
    // empty hero scope.
    return HeroControllerScope.none(
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const _DetailPlaceholder()),
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ads_click,
                size: 40,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Select an item to view its details',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
