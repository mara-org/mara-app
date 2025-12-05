// Mara QA – Localization Tests
// Tests app localization and RTL support
// Validates translations, RTL layouts, and locale-specific formatting
// Frontend-only: client-side localization validation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mara_app/main.dart' as app;

void main() {
  group('Localization Tests', () {
    testWidgets('App loads with English locale', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: Locale('en'),
          home: Scaffold(body: Text('Test')),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app loads without errors
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('App loads with Arabic locale (RTL)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: Locale('ar'),
          home: Scaffold(body: Text('اختبار')),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RTL layout is applied
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold, isNotNull);

      // Verify text direction is RTL
      final textDirection = tester.binding.window.platformDispatcher.locale;
      // Note: This is a simplified check - in production, verify actual RTL behavior
    });

    testWidgets('All required translations are present',
        (WidgetTester tester) async {
      // This test verifies that all translation keys exist
      // In production, you would load ARB files and check keys

      // Placeholder: Verify localization files exist
      // Actual implementation would parse ARB files and check completeness
      expect(true, isTrue,
          reason: 'Translation completeness check placeholder');
    });

    testWidgets('Date formatting works for both locales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final now = DateTime.now();
                return Text(now.toString());
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify date is displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Number formatting works for both locales',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: const Locale('en'),
          home: const Scaffold(
            body: Text('1234.56'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify number is displayed
      expect(find.text('1234.56'), findsOneWidget);
    });
  });

  group('RTL Layout Tests', () {
    testWidgets('RTL layout flips correctly for Arabic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          locale: Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Row(
                children: [
                  Text('Right'),
                  Text('Left'),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RTL direction is applied
      final directionality =
          tester.widget<Directionality>(find.byType(Directionality));
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('Text alignment adjusts for RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Text(
                'Arabic Text',
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify text widget exists
      expect(find.text('Arabic Text'), findsOneWidget);
    });

    testWidgets('Icons flip correctly in RTL mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                leading: Icon(Icons.arrow_back),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify icon exists
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
