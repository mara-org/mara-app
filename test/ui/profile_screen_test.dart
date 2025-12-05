// Widget tests for Profile Screen
// Tests the profile screen rendering and user information display

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mara_app/core/di/dependency_injection.dart';
import 'package:mara_app/core/providers/email_provider.dart';
import 'package:mara_app/core/providers/subscription_provider.dart';
import 'package:mara_app/core/providers/user_profile_provider.dart';
import 'package:mara_app/core/services/app_review_service.dart';
import 'package:mara_app/core/services/share_app_service.dart';
import 'package:mara_app/features/profile/presentation/profile_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:mara_app/l10n/app_localizations_en.dart';
import 'package:mara_app/shared/system/system_providers.dart';

// Custom asset bundle that returns empty data for missing assets
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    try {
      return await rootBundle.load(key);
    } catch (e) {
      // Return empty data for missing assets
      return ByteData(0);
    }
  }
}

void main() {
  // Suppress asset loading errors in tests
  setUpAll(() {
    // Suppress image loading errors for missing assets during tests
    FlutterError.onError = (FlutterErrorDetails details) {
      // Only suppress asset loading errors, let other errors through
      final errorString = details.exception.toString();
      final stackString = details.stack?.toString() ?? '';
      if (errorString.contains('Unable to load asset') ||
          errorString.contains('asset does not exist') ||
          errorString.contains('EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE') ||
          stackString.contains('AssetBundleImageProvider') ||
          stackString.contains('Image.asset') ||
          stackString.contains('_loadAsync')) {
        // Silently ignore asset loading errors in tests
        return;
      }
      // Re-throw all other errors
      FlutterError.presentError(details);
    };
  });

  tearDownAll(() {
    // Restore default error handling
    FlutterError.onError = FlutterError.presentError;
  });
  group('Profile Screen Widget Tests', () {
    testWidgets('Profile screen renders correctly',
        (WidgetTester tester) async {
      // Build the profile screen with ProviderScope and GoRouter
      // ProfileScreen requires GoRouter for context.go() calls
      // Mock providers to avoid platform-specific failures
      // Use runZonedGuarded to catch assertion errors from missing assets
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock email provider (avoid SharedPreferences access)
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              // Mock subscription provider
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              // Mock user profile provider
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              // Mock system info providers (avoid platform-specific calls)
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              // Mock app review service
              appReviewServiceProvider
                  .overrideWith((ref) => MockAppReviewService()),
              // Mock share app service
              shareAppServiceProvider
                  .overrideWith((ref) => MockShareAppService()),
            ],
            child: DefaultAssetBundle(
              bundle: TestAssetBundle(),
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
          ),
        );

        // Wait for the widget tree to settle (with longer timeout for async providers)
        // Multiple pump cycles ensure async providers complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

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
      }, (error, stack) {
        // Suppress asset loading assertion errors
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        // Re-throw other errors
        throw error;
      });
    });

    testWidgets('Profile screen has correct structure',
        (WidgetTester tester) async {
      // Use runZonedGuarded to catch assertion errors from missing assets
      await runZonedGuarded(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock providers to avoid platform-specific failures
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              // Mock app review service
              appReviewServiceProvider
                  .overrideWith((ref) => MockAppReviewService()),
              // Mock share app service
              shareAppServiceProvider
                  .overrideWith((ref) => MockShareAppService()),
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
        // Wait for the widget tree to settle (with longer timeout for async providers)
        // Multiple pump cycles ensure async providers complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Verify basic structure
        expect(find.byType(Scaffold), findsOneWidget);

        // TODO: Add more structure tests:
        // - Verify AppBar exists
        // - Verify scrollable content
        // - Verify section widgets exist
        // - Test responsive layout
      }, (error, stack) {
        // Suppress asset loading assertion errors
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        // Re-throw other errors
        throw error;
      });
    });

    testWidgets('Profile screen shows Rate App menu item',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        final mockAppReviewService = MockAppReviewService();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              appReviewServiceProvider
                  .overrideWith((ref) => mockAppReviewService),
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

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Verify Rate App menu item exists
        // Use the English localization directly for testing
        final l10n = AppLocalizationsEn();
        expect(find.text(l10n.profileRateAppTitle), findsOneWidget);
        expect(find.text(l10n.profileRateAppSubtitle), findsOneWidget);
      }, (error, stack) {
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        throw error;
      });
    });

    testWidgets('Tapping Rate App calls openStoreListing',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        final mockAppReviewService = MockAppReviewService();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              appReviewServiceProvider
                  .overrideWith((ref) => mockAppReviewService),
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

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Find and tap the Rate App menu item
        // Use the English localization directly for testing
        final l10n = AppLocalizationsEn();
        final rateAppFinder = find.text(l10n.profileRateAppTitle);
        expect(rateAppFinder, findsOneWidget);

        await tester.tap(rateAppFinder);
        await tester.pump(); // Allow tap to process
        await tester
            .pump(const Duration(milliseconds: 100)); // Allow async operation
        await tester.pump(
            const Duration(milliseconds: 100)); // Allow callback to execute

        // Verify that openStoreListing was called
        expect(mockAppReviewService.openStoreListingCalled, isTrue,
            reason:
                'openStoreListing should be called when Rate App is tapped');
      }, (error, stack) {
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        throw error;
      });
    });

    testWidgets('Profile screen shows Share App menu item',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        final mockShareAppService = MockShareAppService();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              appReviewServiceProvider
                  .overrideWith((ref) => MockAppReviewService()),
              shareAppServiceProvider
                  .overrideWith((ref) => mockShareAppService),
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

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Verify Share App menu item exists
        // Use the English localization directly for testing
        final l10n = AppLocalizationsEn();
        expect(find.text(l10n.profileShareAppTitle), findsOneWidget);
        expect(find.text(l10n.profileShareAppSubtitle), findsOneWidget);
      }, (error, stack) {
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        throw error;
      });
    });

    testWidgets('Tapping Share App calls shareApp',
        (WidgetTester tester) async {
      await runZonedGuarded(() async {
        final mockShareAppService = MockShareAppService();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              emailProvider.overrideWith((ref) => _MockEmailNotifier()),
              subscriptionProvider
                  .overrideWith((ref) => SubscriptionNotifier()),
              userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
              appVersionProvider
                  .overrideWith((ref) => Future.value('1.0.0 (1)')),
              deviceInfoProvider
                  .overrideWith((ref) => Future.value('Test Device')),
              appReviewServiceProvider
                  .overrideWith((ref) => MockAppReviewService()),
              shareAppServiceProvider
                  .overrideWith((ref) => mockShareAppService),
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

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Find and tap the Share App menu item
        // Use the English localization directly for testing
        final l10n = AppLocalizationsEn();
        final shareAppFinder = find.text(l10n.profileShareAppTitle);
        expect(shareAppFinder, findsOneWidget);

        await tester.tap(shareAppFinder);
        await tester.pump(); // Allow tap to process
        await tester
            .pump(const Duration(milliseconds: 100)); // Allow async operation
        await tester.pump(
            const Duration(milliseconds: 100)); // Allow callback to execute

        // Verify that shareApp was called
        expect(mockShareAppService.shareAppCalled, isTrue,
            reason: 'shareApp should be called when Share App is tapped');
      }, (error, stack) {
        if (error is AssertionError &&
            error.toString().contains('Unable to load asset')) {
          return;
        }
        throw error;
      });
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

// Mock AppReviewService for testing
class MockAppReviewService implements IAppReviewService {
  bool isReviewAvailableCalled = false;
  bool openStoreListingCalled = false;
  bool isReviewAvailableResult = true;

  @override
  Future<bool> isReviewAvailable() async {
    isReviewAvailableCalled = true;
    return isReviewAvailableResult;
  }

  @override
  Future<void> openStoreListing() async {
    openStoreListingCalled = true;
  }
}

// Mock ShareAppService for testing
class MockShareAppService implements IShareAppService {
  bool shareAppCalled = false;

  @override
  Future<void> shareApp(AppLocalizations l10n) async {
    shareAppCalled = true;
  }
}
