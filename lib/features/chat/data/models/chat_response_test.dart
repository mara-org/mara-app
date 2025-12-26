import 'package:flutter_test/flutter_test.dart';
import 'chat_response.dart';

void main() {
  group('ChatResponse', () {
    test('should parse from JSON correctly', () {
      final json = {
        'text': 'Hello, how can I help?',
        'metadata': {
          'model_used': 'gpt-4',
          'tokens_in': 10,
          'tokens_out': 20,
          'remaining_messages_today': 5,
          'remaining_token_budget_today': 1000,
          'plan': 'paid',
          'upgrade_hint': null,
          'request_id': 'req-123',
        },
      };

      final response = ChatResponse.fromJson(json);

      expect(response.text, 'Hello, how can I help?');
      expect(response.metadata.modelUsed, 'gpt-4');
      expect(response.metadata.tokensIn, 10);
      expect(response.metadata.tokensOut, 20);
      expect(response.metadata.remainingMessagesToday, 5);
      expect(response.metadata.remainingTokenBudgetToday, 1000);
      expect(response.metadata.plan, 'paid');
      expect(response.metadata.upgradeHint, isNull);
      expect(response.metadata.requestId, 'req-123');
    });

    test('should handle missing optional fields', () {
      final json = {
        'text': 'Hello',
        'metadata': {
          'model_used': 'gpt-4',
          'tokens_in': 10,
          'tokens_out': 20,
          'remaining_messages_today': 5,
          'remaining_token_budget_today': 1000,
          'plan': 'free',
          'request_id': 'req-123',
        },
      };

      final response = ChatResponse.fromJson(json);

      expect(response.text, 'Hello');
      expect(response.metadata.upgradeHint, isNull);
    });

    test('should handle empty metadata', () {
      final json = {
        'text': 'Hello',
        'metadata': {},
      };

      final response = ChatResponse.fromJson(json);

      expect(response.text, 'Hello');
      expect(response.metadata.modelUsed, 'unknown');
      expect(response.metadata.tokensIn, 0);
      expect(response.metadata.plan, 'free');
    });

    test('should check if user is paid', () {
      final paidMetadata = ChatMetadata(
        modelUsed: 'gpt-4',
        tokensIn: 10,
        tokensOut: 20,
        remainingMessagesToday: 5,
        remainingTokenBudgetToday: 1000,
        plan: 'paid',
        requestId: 'req-123',
      );

      final freeMetadata = paidMetadata.copyWith(plan: 'free');

      expect(paidMetadata.isPaid, true);
      expect(freeMetadata.isPaid, false);
    });

    test('should check remaining quota', () {
      final metadata = ChatMetadata(
        modelUsed: 'gpt-4',
        tokensIn: 10,
        tokensOut: 20,
        remainingMessagesToday: 5,
        remainingTokenBudgetToday: 1000,
        plan: 'free',
        requestId: 'req-123',
      );

      expect(metadata.hasRemainingMessages, true);
      expect(metadata.hasRemainingTokenBudget, true);

      final exhaustedMetadata = metadata.copyWith(
        remainingMessagesToday: 0,
        remainingTokenBudgetToday: 0,
      );

      expect(exhaustedMetadata.hasRemainingMessages, false);
      expect(exhaustedMetadata.hasRemainingTokenBudget, false);
    });
  });
}
