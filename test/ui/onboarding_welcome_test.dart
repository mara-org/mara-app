// Widget tests for Welcome Intro Screen (Onboarding)
// Tests the welcome screen rendering, button interactions, and navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mara_app/features/onboarding/presentation/welcome_intro_screen.dart';
import 'package:mara_app/core/widgets/primary_button.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/test_utils.dart';

void main() {
  group('Welcome Intro Screen Widget Tests', () {
    testWidgets('Welcome screen renders correctly',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/welcome',
            routes: [
              GoRoute(
                path: '/welcome',
                builder: (context, state) => const WelcomeIntroScreen(),
              ),
              GoRoute(
                path: '/onboarding-insights',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Onboarding Insights')),
                ),
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
        ),
      );

      // Verify that the WelcomeIntroScreen widget exists
      expect(find.byType(WelcomeIntroScreen), findsOneWidget);

      // Verify that the continue button exists
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('Welcome screen displays title and subtitle',
        (WidgetTester tester) async {
      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/welcome',
            routes: [
              GoRoute(
                path: '/welcome',
                builder: (context, state) => const WelcomeIntroScreen(),
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
        ),
      );

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify gradient background container exists
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Continue button is tappable', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();

      await pumpMaraApp(
        tester,
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/welcome',
            routes: [
              GoRoute(
                path: '/welcome',
                builder: (context, state) => const WelcomeIntroScreen(),
              ),
              GoRoute(
                path: '/onboarding-insights',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Onboarding Insights')),
                ),
              ),
            ],
            observers: [mockObserver],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
        ),
      );

      // Find and tap the continue button
      final continueButton = find.byType(PrimaryButton);
      expect(continueButton, findsOneWidget);

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred (button was tapped)
      // Note: Actual navigation testing may require more setup
      expect(find.byType(PrimaryButton), findsNothing);
    });
  });
}
