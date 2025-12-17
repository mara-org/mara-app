import 'package:flutter_test/flutter_test.dart';
import 'chat_response.dart';
import 'quota_state.dart';

void main() {
  group('QuotaState', () {
    test('should create from metadata', () {
      final metadata = ChatMetadata(
        modelUsed: 'gpt-4',
        tokensIn: 10,
        tokensOut: 20,
        remainingMessagesToday: 5,
        remainingTokenBudgetToday: 1000,
        plan: 'paid',
        upgradeHint: 'Upgrade for more',
        requestId: 'req-123',
      );

      final quotaState = QuotaState.fromMetadata(metadata);

      expect(quotaState.remainingMessages, 5);
      expect(quotaState.remainingTokenBudget, 1000);
      expect(quotaState.plan, 'paid');
      expect(quotaState.upgradeHint, 'Upgrade for more');
      expect(quotaState.isPaid, true);
      expect(quotaState.canSendMessage, true);
    });

    test('should create initial state', () {
      final quotaState = QuotaState.initial();

      expect(quotaState.remainingMessages, 0);
      expect(quotaState.remainingTokenBudget, 0);
      expect(quotaState.plan, 'free');
      expect(quotaState.isPaid, false);
      expect(quotaState.canSendMessage, false);
    });

    test('should check if quota is exhausted', () {
      final quotaState = QuotaState(
        remainingMessages: 0,
        remainingTokenBudget: 0,
        plan: 'free',
      );

      expect(quotaState.isMessageQuotaExhausted, true);
      expect(quotaState.isTokenQuotaExhausted, true);
      expect(quotaState.canSendMessage, false);
    });

    test('should create copy with updated fields', () {
      final original = QuotaState(
        remainingMessages: 5,
        remainingTokenBudget: 1000,
        plan: 'free',
      );

      final updated = original.copyWith(
        remainingMessages: 3,
        plan: 'paid',
      );

      expect(updated.remainingMessages, 3);
      expect(updated.remainingTokenBudget, 1000);
      expect(updated.plan, 'paid');
      expect(original.remainingMessages, 5); // Original unchanged
    });
  });
}

