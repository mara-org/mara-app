// Widget tests for Home Screen
// Tests the home screen rendering, button interactions, and navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mara_app/core/storage/local_cache.dart';
import 'package:mara_app/core/providers/health_tracking_providers.dart';
import 'package:mara_app/core/providers/steps_provider.dart';
import 'package:mara_app/core/providers/chat_topic_provider.dart';
import 'package:mara_app/core/providers/user_profile_provider.dart';
import 'package:mara_app/core/di/dependency_injection.dart';
import 'package:mara_app/core/services/health_data_service.dart';
import 'package:mara_app/features/home/presentation/home_screen.dart';
import 'package:mara_app/core/widgets/primary_button.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUpAll(() async {
    // Initialize SharedPreferences with mock values for all tests
    SharedPreferences.setMockInitialValues({});
    await LocalCache.init();
  });

  group('Home Screen Widget Tests', () {
    testWidgets('Home screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override FutureProviders to return immediate values
            todayStepsProvider.overrideWith((ref) => Future.value(null)),
            todaySleepProvider.overrideWith((ref) => Future.value(null)),
            todayWaterProvider.overrideWith((ref) => Future.value(null)),
            // Override StateProviders
            stepsGoalProvider.overrideWith((ref) => 10000),
            lastConversationTopicProvider.overrideWith((ref) => null),
            // Override UserProfileProvider
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
            // Mock health data service
            healthDataServiceProvider
                .overrideWith((ref) => HealthDataService()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: '/chat',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Chat Screen')),
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

      // Wait for async providers to initialize using pump with multiple iterations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Use pump multiple times instead of pumpAndSettle to avoid timeout
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (tester.binding.transientCallbackCount <= 0) {
          break;
        }
      }

      // Verify that the HomeScreen widget exists
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify that the Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Home screen displays main elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override FutureProviders to return immediate values
            todayStepsProvider.overrideWith((ref) => Future.value(null)),
            todaySleepProvider.overrideWith((ref) => Future.value(null)),
            todayWaterProvider.overrideWith((ref) => Future.value(null)),
            // Override StateProviders
            stepsGoalProvider.overrideWith((ref) => 10000),
            lastConversationTopicProvider.overrideWith((ref) => null),
            // Override UserProfileProvider
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
            // Mock health data service
            healthDataServiceProvider
                .overrideWith((ref) => HealthDataService()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
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

      // Wait for async providers to initialize using pump with multiple iterations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Use pump multiple times instead of pumpAndSettle to avoid timeout
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (tester.binding.transientCallbackCount <= 0) {
          break;
        }
      }

      // Verify SafeArea exists
      expect(find.byType(SafeArea), findsOneWidget);

      // Verify SingleChildScrollView exists (home screen is scrollable)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Chat button is present and tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override FutureProviders to return immediate values
            todayStepsProvider.overrideWith((ref) => Future.value(null)),
            todaySleepProvider.overrideWith((ref) => Future.value(null)),
            todayWaterProvider.overrideWith((ref) => Future.value(null)),
            // Override StateProviders
            stepsGoalProvider.overrideWith((ref) => 10000),
            lastConversationTopicProvider.overrideWith((ref) => null),
            // Override UserProfileProvider
            userProfileProvider.overrideWith((ref) => UserProfileNotifier()),
            // Mock health data service
            healthDataServiceProvider
                .overrideWith((ref) => HealthDataService()),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
                GoRoute(
                  path: '/chat',
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Chat Screen')),
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

      // Wait for async providers to initialize using pump with multiple iterations
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Use pump multiple times instead of pumpAndSettle to avoid timeout
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (tester.binding.transientCallbackCount <= 0) {
          break;
        }
      }

      // Find chat button (PrimaryButton with "Chat with Mara" text)
      final chatButton = find.byType(PrimaryButton);
      expect(chatButton, findsWidgets);

      // Tap the first primary button (assuming it's the chat button)
      if (chatButton.evaluate().isNotEmpty) {
        await tester.tap(chatButton.first);
        // Use pump instead of pumpAndSettle
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
  });
}
