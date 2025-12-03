// Widget tests for Splash Screen
// Tests the splash screen rendering and navigation behavior

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mara_app/features/splash/presentation/splash_screen.dart';
import 'package:mara_app/core/widgets/mara_logo.dart';
import 'package:mara_app/l10n/app_localizations.dart';

void main() {
  group('Splash Screen Widget Tests', () {
    testWidgets('Splash screen renders correctly', (WidgetTester tester) async {
      // Build the splash screen with GoRouter setup
      // SplashScreen uses context.go() which requires GoRouter
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/splash',
              routes: [
                GoRoute(
                  path: '/splash',
                  builder: (context, state) => const SplashScreen(),
                ),
                GoRoute(
                  path: '/language-selector',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Language Selector')),
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
        ),
      );

      // Wait for initial frame
      await tester.pump();

      // Verify that the SplashScreen widget exists
      expect(find.byType(SplashScreen), findsOneWidget);

      // Verify that the Mara logo is displayed
      expect(find.byType(MaraLogo), findsOneWidget);

      // Wait for the timer to complete (2 seconds) to avoid pending timer error
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // TODO: Add more specific assertions:
      // - Verify gradient background
      // - Verify logo positioning
      // - Test navigation after timer
      // - Test different screen sizes
    });

    testWidgets('Splash screen has correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/splash',
              routes: [
                GoRoute(
                  path: '/splash',
                  builder: (context, state) => const SplashScreen(),
                ),
                GoRoute(
                  path: '/language-selector',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Language Selector')),
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
        ),
      );
      await tester.pump();

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify SafeArea exists
      expect(find.byType(SafeArea), findsOneWidget);

      // Wait for the timer to complete (2 seconds) to avoid pending timer error
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // TODO: Add more structure tests:
      // - Verify Container with gradient
      // - Verify logo is centered
      // - Test responsive layout
    });

    // TODO: Add more widget tests:
    // - Test navigation timing (2 seconds)
    // - Test navigation destination
    // - Test error handling
    // - Test different locales
    // - Test dark mode (when implemented)
  });
}
