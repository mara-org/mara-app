// Golden tests for Mara app
// Golden tests capture widget snapshots and detect visual regressions
// Uses golden_toolkit for enhanced golden testing capabilities
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mara_app/features/home/presentation/home_screen.dart';
import 'package:mara_app/l10n/app_localizations.dart';

void main() {
  group('Golden Tests', () {
    // TODO: Generate golden files first by running: flutter test --update-goldens
    // Then remove skip: true below
    testGoldens(
      'Home screen golden test',
      (WidgetTester tester) async {
        // Build the widget with localization delegates
        await tester.pumpWidgetBuilder(
          ProviderScope(
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
              home: HomeScreen(),
            ),
          ),
          surfaceSize: const Size(400, 800), // Standard mobile size
        );

        // Wait for the widget tree to settle
        await tester.pumpAndSettle();

        // Compare against golden file
        // Note: First run will fail - use 'flutter test --update-goldens' to generate golden files
        await screenMatchesGolden(tester, 'home_screen');
      },
      // Skipped until a baseline golden is added for the home screen
      skip: true,
    );

    // TODO: Add more golden tests:
    // - Test all screens (splash, auth, profile, settings, etc.)
    // - Test different screen sizes (tablet, desktop)
    // - Test dark mode (when implemented)
    // - Test different locales (English, Arabic)
    // - Test different states (loading, error, empty)
  });
}

// TODO: Setup instructions for golden testing:
// 1. Add golden_toolkit to dev_dependencies in pubspec.yaml:
//    dev_dependencies:
//      golden_toolkit: ^0.15.0
//
// 2. Create test/golden/ directory for golden files
//
// 3. Update test configuration to generate and compare golden files
//
// 4. Add golden files to version control (or use a separate golden file storage)
//
// 5. Run tests with: flutter test --update-goldens (to update golden files)
//    Run tests with: flutter test (to compare against golden files)
//
// Example with golden_toolkit:
// import 'package:golden_toolkit/golden_toolkit.dart';
//
// testGoldens('Home screen golden test', (WidgetTester tester) async {
//   await tester.pumpWidgetBuilder(HomeScreen());
//   await screenMatchesGolden(tester, 'home_screen');
// });
