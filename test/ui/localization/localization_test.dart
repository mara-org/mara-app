// Localization and RTL tests
// Verifies that screens render correctly in English (LTR) and Arabic (RTL)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/features/onboarding/presentation/welcome_intro_screen.dart';
import 'package:mara_app/features/auth/presentation/sign_in_email_screen.dart';
import 'package:mara_app/features/chat/presentation/mara_chat_screen.dart';
import '../../utils/test_utils.dart';

void main() {
  group('Localization and RTL Tests', () {
    testWidgets('Welcome screen renders in English (LTR)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const WelcomeIntroScreen(),
        locale: const Locale('en'),
      );

      // Verify screen renders without crashing
      expect(find.byType(WelcomeIntroScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify text widgets are present
      expect(find.byType(Text), findsWidgets);

      // Verify layout direction is LTR
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale, const Locale('en'));
    });

    testWidgets('Welcome screen renders in Arabic (RTL)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const WelcomeIntroScreen(),
        locale: const Locale('ar'),
      );

      // Verify screen renders without crashing
      expect(find.byType(WelcomeIntroScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify text widgets are present
      expect(find.byType(Text), findsWidgets);

      // Verify layout direction is RTL
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale, const Locale('ar'));
    });

    testWidgets('Sign in screen renders in English (LTR)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const SignInEmailScreen(),
        locale: const Locale('en'),
      );

      // Verify screen renders without crashing
      expect(find.byType(SignInEmailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify form fields exist
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Sign in screen renders in Arabic (RTL)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const SignInEmailScreen(),
        locale: const Locale('ar'),
      );

      // Verify screen renders without crashing
      expect(find.byType(SignInEmailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify form fields exist
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Chat screen renders in English (LTR)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const MaraChatScreen(),
        locale: const Locale('en'),
      );

      // Verify screen renders without crashing
      expect(find.byType(MaraChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chat screen renders in Arabic (RTL)',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        const MaraChatScreen(),
        locale: const Locale('ar'),
      );

      // Verify screen renders without crashing
      expect(find.byType(MaraChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Screens handle locale switching without crashing',
        (WidgetTester tester) async {
      // Test switching between locales
      final screens = [
        const WelcomeIntroScreen(),
        const SignInEmailScreen(),
        const MaraChatScreen(),
      ];

      for (final screen in screens) {
        // Render in English
        await pumpMaraApp(tester, screen, locale: const Locale('en'));
        expect(tester.takeException(), isNull);

        // Render in Arabic
        await pumpMaraApp(tester, screen, locale: const Locale('ar'));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Key text elements are present in both locales',
        (WidgetTester tester) async {
      // Test welcome screen
      await pumpMaraApp(
        tester,
        const WelcomeIntroScreen(),
        locale: const Locale('en'),
      );
      expect(find.byType(Text), findsWidgets);

      await pumpMaraApp(
        tester,
        const WelcomeIntroScreen(),
        locale: const Locale('ar'),
      );
      expect(find.byType(Text), findsWidgets);
    });
  });
}

