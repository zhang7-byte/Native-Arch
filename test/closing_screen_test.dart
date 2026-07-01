import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labtrack/ui/closing_screen.dart';

void main() {
  testWidgets('closing screen shows the brand mark + a message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClosingScreen()));
    // A couple of frames into the intro (do NOT pumpAndSettle — the progress
    // bar animates indefinitely).
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('labtrack'), findsOneWidget);
    expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
