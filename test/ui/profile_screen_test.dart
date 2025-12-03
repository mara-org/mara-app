// Widget tests for Profile Screen
// Tests the profile screen rendering and user information display

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mara_app/core/providers/email_provider.dart';
import 'package:mara_app/core/providers/subscription_provider.dart';
import 'package:mara_app/core/providers/user_profile_provider.dart';
import 'package:mara_app/features/profile/presentation/profile_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:mara_app/shared/system/system_providers.dart';

void main() {
  group('Profile Screen Widget Tests', () {
    testWidgets('Profile screen renders correctly',
        (WidgetTester tester) async {
      // Build the profile screen with ProviderScope and GoRouter
      // ProfileScreen requires GoRouter for context.go() calls
      // Mock providers to avoid platform-specific failures
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock email provider (avoid SharedPreferences access)
            emailProvider.overrideWith((ref) => _MockEmailNotifier()),
            // Mock subscription provider
            subscriptionProvider.overrideWith((ref) => SubscriptionNotifier()),
            // Mock user profile provider
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
            // Mock system info providers (avoid platform-specific calls)
            appVersionProvider.overrideWith((ref) => Future.value('1.0.0 (1)')),
            deviceInfoProvider
                .overrideWith((ref) => Future.value('Test Device')),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/profile',
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Home')),
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

      // Wait for the widget tree to settle
      await tester.pumpAndSettle();

      // Verify that the ProfileScreen widget exists
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // TODO: Add more specific assertions based on ProfileScreen implementation:
      // - Verify user email display
      // - Verify health profile section exists
      // - Verify app settings section exists
      // - Verify logout button exists
      // - Test navigation to edit screens
      // - Test settings interactions
    });

    testWidgets('Profile screen has correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock providers to avoid platform-specific failures
            emailProvider.overrideWith((ref) => _MockEmailNotifier()),
            subscriptionProvider.overrideWith((ref) => SubscriptionNotifier()),
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
            appVersionProvider.overrideWith((ref) => Future.value('1.0.0 (1)')),
            deviceInfoProvider
                .overrideWith((ref) => Future.value('Test Device')),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/profile',
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
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
      await tester.pumpAndSettle();

      // Verify basic structure
      expect(find.byType(Scaffold), findsOneWidget);

      // TODO: Add more structure tests:
      // - Verify AppBar exists
      // - Verify scrollable content
      // - Verify section widgets exist
      // - Test responsive layout
    });

    // TODO: Add more widget tests:
    // - Test user interactions (tapping edit buttons, settings)
    // - Test state changes (profile updated)
    // - Test error states
    // - Test loading states
    // - Test navigation to different screens
    // - Test different user profiles
    // - Test empty state
  });
}

// Mock EmailNotifier that doesn't access SharedPreferences
class _MockEmailNotifier extends EmailNotifier {
  _MockEmailNotifier() : super() {
    state = 'test@example.com';
  }
}
