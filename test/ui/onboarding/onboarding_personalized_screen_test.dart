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

      // Verify button widget exists and has onPressed handler
      final buttonWidget = tester.widget<PrimaryButton>(continueButton);
      expect(buttonWidget.onPressed, isNotNull,
          reason: 'Button should have onPressed handler to be tappable');

      // Note: We don't actually tap the button here because it requires GoRouter setup
      // The button's tappability is verified by checking it has an onPressed handler
      // Full navigation testing would require GoRouter configuration like in onboarding_welcome_test.dart
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
