// Golden tests for Welcome Intro Screen
// Visual regression tests that capture widget snapshots

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mara_app/features/onboarding/presentation/welcome_intro_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Welcome Screen Golden Tests', () {
    testGoldens('Welcome screen - light mode', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
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
          theme: ThemeData.light(),
        ),
        surfaceSize: const Size(375, 812), // iPhone 11 Pro size
      );

      await screenMatchesGolden(tester, 'welcome_screen_light');
    });

    testGoldens('Welcome screen - dark mode', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
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
          theme: ThemeData.dark(),
        ),
        surfaceSize: const Size(375, 812), // iPhone 11 Pro size
      );

      await screenMatchesGolden(tester, 'welcome_screen_dark');
    });
  });
}
