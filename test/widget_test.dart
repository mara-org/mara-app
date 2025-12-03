// Basic Flutter widget tests for Mara app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mara_app/main.dart';

void main() {
  testWidgets('Mara app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MaraApp()));
    await tester.pump();

    // Fast-forward past the splash screen timer (2 seconds)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that the app builds without errors
    expect(find.byType(MaraApp), findsOneWidget);
  });
}
