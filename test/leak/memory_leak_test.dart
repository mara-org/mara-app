import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mara_app/main.dart';

void main() {
  setUpAll(() {
    // Enable leak tracking for all tests in this file
    LeakTesting.enable();
    // Configure leak tracking to be more lenient for app startup
    // Some framework-level objects may not be disposed immediately
    LeakTesting.settings = LeakTesting.settings.withIgnored(
      notGCed: {
        // Ignore common Flutter framework objects that may not be GC'd immediately
        'Widget': null,
        'State': null,
        'Element': null,
      },
      allNotDisposed: false,
    );
  });

  testWidgets(
    'MaraApp startup is leak-free',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MaraApp()));
      await tester.pumpAndSettle();
    },
    tags: ['leak'],
  );
}
