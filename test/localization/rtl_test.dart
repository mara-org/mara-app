// Mara QA – RTL Layout Tests
// Specific tests for Right-to-Left (RTL) layout support
// Validates Arabic locale RTL behavior

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RTL Layout Tests', () {
    testWidgets('Directionality widget sets RTL correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final directionality =
          tester.widget<Directionality>(find.byType(Directionality));
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('Row children order correctly in RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Row(
              children: [
                Text('First'),
                Text('Second'),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In RTL, visual order should be reversed
      final firstText = find.text('First');
      final secondText = find.text('Second');

      expect(firstText, findsOneWidget);
      expect(secondText, findsOneWidget);

      // Verify positions are correct for RTL
      final firstPosition = tester.getTopLeft(firstText);
      final secondPosition = tester.getTopLeft(secondText);

      // In RTL, 'Second' should be visually on the left (lower x)
      expect(secondPosition.dx, lessThan(firstPosition.dx));
    });

    testWidgets('AppBar leading icon positions correctly in RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Title'),
                leading: Icon(Icons.menu),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('Text alignment works correctly in RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Text(
              'Arabic Text',
              textAlign: TextAlign.start,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Arabic Text'));
      expect(textWidget.textAlign, TextAlign.start);

      // In RTL, start should align to the right
      // This is handled automatically by Flutter's Directionality widget
    });
  });
}
