import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/data/database.dart';
import 'package:labtrack/ui/app_database_provider.dart';
import 'package:labtrack/ui/projects/project_edit_screen.dart';

void main() {
  testWidgets('New project form renders its fields', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      MaterialApp(
        home: AppDatabaseProvider(
          database: db,
          child: const ProjectEditScreen(),
        ),
      ),
    );

    expect(find.text('New project'), findsOneWidget); // app bar title
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
