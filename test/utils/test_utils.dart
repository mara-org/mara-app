// Test utilities for Mara app widget tests
// Provides common test helpers, mocks, and utilities

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/l10n/app_localizations.dart';

/// Wraps a widget with necessary providers and localization for testing
Widget createTestWidget(Widget child) {
  return ProviderScope(
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
      home: child,
    ),
  );
}

/// Standard function to pump Mara app widget for testing
/// This is the recommended way to set up widgets in tests
Future<void> pumpMaraApp(
  WidgetTester tester,
  Widget widget, {
  Locale? locale,
}) async {
  final testWidget = locale != null
      ? createTestWidgetWithLocale(widget, locale)
      : createTestWidget(widget);
  await tester.pumpWidget(testWidget);
  await tester.pumpAndSettle();
}

/// Creates a test widget with custom locale
Widget createTestWidgetWithLocale(Widget child, Locale locale) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
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
      home: child,
    ),
  );
}

/// Mock Navigator for testing navigation
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
}

/// Helper to wait for async operations in tests
Future<void> waitForAsync(WidgetTester tester, {Duration? timeout}) async {
  await tester.pumpAndSettle(timeout ?? const Duration(seconds: 5));
}

/// Helper to find widgets by text (case-insensitive)
Finder findTextByPattern(String pattern) {
  return find.textContaining(pattern, findRichText: true);
}

/// Helper to find widgets by type and verify count
void expectWidgetCount<T>(WidgetTester tester, int count) {
  expect(find.byType(T), findsNWidgets(count));
}

/// Helper to verify widget is visible
void expectWidgetVisible(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  expect(tester.widget(finder), isNotNull);
}

/// Helper to verify widget is not visible
void expectWidgetNotVisible(WidgetTester tester, Finder finder) {
  expect(finder, findsNothing);
}

/// Mock provider helper for testing
/// Note: Provider is sealed in Riverpod, so we can't extend it directly
/// Instead, create providers inline in tests using Provider<T>((ref) => value)
/// Example:
///   final mockProvider = Provider<String>((ref) => 'test value');

/// TODO: Add more test utilities:
/// - Mock HTTP client for API testing
/// - Mock shared preferences
/// - Mock device info
/// - Mock crash reporter
/// - Test data factories
/// - Screenshot helpers
/// - Performance testing helpers
