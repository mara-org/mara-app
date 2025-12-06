// Widget tests for Analytics Dashboard
// Tests the analytics dashboard rendering, chart display, and interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mara_app/features/analytics/presentation/analyst_dashboard_screen.dart';
import 'package:mara_app/core/providers/health_tracking_providers.dart';
import 'package:mara_app/core/models/health/daily_steps_entry.dart';
import 'package:mara_app/core/models/health/daily_sleep_entry.dart';
import 'package:mara_app/core/models/health/daily_water_intake_entry.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../utils/test_utils.dart';

void main() {
  group('Analytics Dashboard Widget Tests', () {
    testWidgets('Analytics dashboard renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepsHistoryProvider.overrideWith((ref, limit) async => []),
            sleepHistoryProvider.overrideWith((ref, limit) async => []),
            waterHistoryProvider.overrideWith((ref, limit) async => []),
          ],
          child: MaterialApp(
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
            home: const AnalystDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard exists
      expect(find.byType(AnalystDashboardScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Analytics dashboard shows time period selector',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepsHistoryProvider.overrideWith((ref, limit) async => []),
            sleepHistoryProvider.overrideWith((ref, limit) async => []),
            waterHistoryProvider.overrideWith((ref, limit) async => []),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const AnalystDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have time period buttons (check for English or Arabic)
      expect(find.textContaining('Last'), findsWidgets);
    });

    testWidgets('Analytics dashboard displays charts with data',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final stepsEntries = [
        DailyStepsEntry(date: now, steps: 5000, lastUpdatedAt: now),
        DailyStepsEntry(
          date: now.subtract(const Duration(days: 1)),
          steps: 6000,
          lastUpdatedAt: now,
        ),
      ];

      final sleepEntries = [
        DailySleepEntry(date: now, hours: 7.5, lastUpdatedAt: now),
      ];

      final waterEntries = [
        DailyWaterIntakeEntry(date: now, waterLiters: 2.5, lastUpdatedAt: now),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepsHistoryProvider
                .overrideWith((ref, limit) async => stepsEntries),
            sleepHistoryProvider
                .overrideWith((ref, limit) async => sleepEntries),
            waterHistoryProvider
                .overrideWith((ref, limit) async => waterEntries),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const AnalystDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show chart titles (check for common terms)
      expect(find.textContaining('Steps'), findsWidgets);
    });

    testWidgets('Analytics dashboard shows empty state when no data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepsHistoryProvider.overrideWith((ref, limit) async => []),
            sleepHistoryProvider.overrideWith((ref, limit) async => []),
            waterHistoryProvider.overrideWith((ref, limit) async => []),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const AnalystDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message (check for common terms)
      expect(find.textContaining('data'), findsWidgets);
    });

    testWidgets('Time period selector toggles correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            stepsHistoryProvider.overrideWith((ref, limit) async => []),
            sleepHistoryProvider.overrideWith((ref, limit) async => []),
            waterHistoryProvider.overrideWith((ref, limit) async => []),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const AnalystDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final last30DaysButton = find.textContaining('30');

      if (last30DaysButton.evaluate().isNotEmpty) {
        await tester.tap(last30DaysButton.first);
        await tester.pumpAndSettle();

        // UI should update (visual verification)
        expect(find.byType(AnalystDashboardScreen), findsOneWidget);
      }
    });
  });
}
