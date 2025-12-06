// Example widget test for Mara app
// This demonstrates how to test UI components and screens
// TODO: Add more widget tests for all screens and components

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mara_app/core/storage/local_cache.dart';
import 'package:mara_app/core/providers/health_tracking_providers.dart';
import 'package:mara_app/core/providers/steps_provider.dart';
import 'package:mara_app/core/providers/chat_topic_provider.dart';
import 'package:mara_app/core/providers/user_profile_provider.dart';
import 'package:mara_app/core/di/dependency_injection.dart';
import 'package:mara_app/core/services/health_data_service.dart';
import 'package:mara_app/features/home/presentation/home_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    // Initialize SharedPreferences with mock values for all tests
    SharedPreferences.setMockInitialValues({});
    await LocalCache.init();
  });

  group('Home Screen Widget Tests', () {
    testWidgets('Home screen renders correctly', (WidgetTester tester) async {
      // Build the app with ProviderScope and localization delegates
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
            healthDataServiceProvider.overrideWith((ref) => HealthDataService()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('ar'),
            ],
            home: HomeScreen(),
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

      // TODO: Add more specific assertions based on HomeScreen implementation
      // Example assertions you might add:
      // - expect(find.text('Welcome'), findsOneWidget);
      // - expect(find.byType(SomeButton), findsOneWidget);
      // - expect(find.byIcon(Icons.home), findsOneWidget);
    });

    // TODO: Add more widget tests:
    // - Test user interactions (taps, scrolls, etc.)
    // - Test state changes
    // - Test error states
    // - Test loading states
    // - Test navigation
  });
}
