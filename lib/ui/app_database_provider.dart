import 'package:flutter/widgets.dart';

import '../data/database.dart';

/// Exposes the long-lived [AppDatabase] to the widget tree. Screens read it with
/// `AppDatabaseProvider.of(context)`.
class AppDatabaseProvider extends InheritedWidget {
  const AppDatabaseProvider({
    super.key,
    required this.database,
    required super.child,
  });

  final AppDatabase database;

  static AppDatabase of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppDatabaseProvider>();
    assert(provider != null, 'No AppDatabaseProvider found in the widget tree');
    return provider!.database;
  }

  @override
  bool updateShouldNotify(AppDatabaseProvider oldWidget) =>
      database != oldWidget.database;
}
