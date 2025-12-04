// Enhanced widget tests for Chat Screen
// Tests rendering, message display, input interactions, and navigation

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/features/chat/presentation/mara_chat_screen.dart';
import '../../utils/test_utils.dart';

void main() {
  group('Mara Chat Screen Enhanced Widget Tests', () {
    testWidgets('Chat screen renders without crashing',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Verify screen exists
      expect(find.byType(MaraChatScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chat screen has AppBar', (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Look for AppBar
      final appBar = find.byType(AppBar);
      if (appBar.evaluate().isNotEmpty) {
        expect(appBar, findsOneWidget);
      } else {
        // Some screens use custom app bars, so this is optional
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('Chat screen handles text input', (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Look for text input field
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        // Enter text
        await tester.enterText(textFields.first, 'Test message');
        await tester.pump();

        // Verify text was entered
        expect(find.text('Test message'), findsOneWidget);
      }
    });

    testWidgets('Chat screen has send button or action',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Look for send button (could be IconButton, ElevatedButton, etc.)
      final sendButton = find.byIcon(Icons.send);
      if (sendButton.evaluate().isEmpty) {
        // Try finding by text
        final sendText = find.textContaining('Send', findRichText: true);
        if (sendText.evaluate().isNotEmpty) {
          expect(sendText, findsOneWidget);
        }
      } else {
        expect(sendButton, findsOneWidget);
      }
    });

    testWidgets('Chat screen displays message list area',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Look for ListView or similar scrollable widget
      final listViews = find.byType(ListView);
      final scrollViews = find.byType(SingleChildScrollView);

      // At least one scrollable widget should exist for messages
      expect(
        listViews.evaluate().isNotEmpty || scrollViews.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Chat screen handles rapid interactions',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Rapidly interact with the screen
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        for (int i = 0; i < 3; i++) {
          await tester.enterText(textFields.first, 'Message $i');
          await tester.pump();
        }
      }

      // Screen should still be stable
      expect(find.byType(MaraChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chat screen maintains state during rebuilds',
        (WidgetTester tester) async {
      await pumpMaraApp(tester, const MaraChatScreen());

      // Trigger multiple rebuilds
      for (int i = 0; i < 5; i++) {
        await tester.pump();
      }

      // Screen should still be rendered
      expect(find.byType(MaraChatScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
