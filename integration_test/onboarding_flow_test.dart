import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mara_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding Flow Integration Tests', () {
    testWidgets('Onboarding screens render without errors',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app started
      expect(find.byType(MaterialApp), findsOneWidget);

      // Note: Actual onboarding flow testing will be added when flows are stable
      // This verifies the app structure is correct
    });

    // TODO: Add onboarding flow tests:
    // - Language selection
    // - Welcome screens
    // - Personalization flow
  });
}
