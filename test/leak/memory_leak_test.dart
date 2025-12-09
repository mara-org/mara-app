import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mara_app/main.dart';

void main() {
  testWidgetsWithLeakTracking('MaraApp startup is leak-free', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaraApp()));
    await tester.pumpAndSettle();
  });
}
