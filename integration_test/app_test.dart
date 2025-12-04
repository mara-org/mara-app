import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mara_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app is running (check for any widget from the app)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App navigates to initial screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // App should show some initial content
      // Adjust this based on your app's initial screen
      expect(tester.takeException(), isNull);
    });
  });
}
