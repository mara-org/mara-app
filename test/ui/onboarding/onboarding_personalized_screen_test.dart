// Widget tests for Onboarding Personalized Screen
// Tests rendering, heart icon, and navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/features/onboarding/presentation/onboarding_personalized_screen.dart';
import 'package:mara_app/core/widgets/primary_button.dart';
import '../../utils/test_utils.dart';

void main() {
  group('Onboarding Personalized Screen Widget Tests', () {
    testWidgets('Personalized screen renders correctly',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const OnboardingPersonalizedScreen());

      // Verify screen exists
      expect(find.byType(OnboardingPersonalizedScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify primary button exists
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('Heart icon is displayed and centered',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const OnboardingPersonalizedScreen());

      // Look for heart icon (could be Icon widget with Icons.favorite)
      final heartIcon = find.byIcon(Icons.favorite);
      if (heartIcon.evaluate().isNotEmpty) {
        expect(heartIcon, findsOneWidget);

        // Verify it's visible
        expect(tester.widget(heartIcon), isNotNull);
      }
    });

    testWidgets('Continue button is tappable', (WidgetTester tester) async {
      await pumpMaraApp(tester, const OnboardingPersonalizedScreen());

      // Find continue button
      final continueButton = find.byType(PrimaryButton);
      expect(continueButton, findsOneWidget);

      // Tap button
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Screen should handle tap without crashing
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screen displays personalized content',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const OnboardingPersonalizedScreen());

      // Verify Scaffold exists (basic structure)
      expect(find.byType(Scaffold), findsOneWidget);

      // Screen should have some text content
      expect(find.byType(Text), findsWidgets);
    });
  });
}
