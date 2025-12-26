import 'chat_response.dart';

/// Quota state model for tracking user's usage limits.
///
/// Used to display quota information in the UI.
class QuotaState {
  /// Remaining messages for today.
  final int remainingMessages;

  /// Remaining token budget for today.
  final int remainingTokenBudget;

  /// User's plan: "free" or "paid".
  final String plan;

  /// Upgrade hint message (null if not applicable).
  final String? upgradeHint;

  /// Whether user has exhausted their message quota.
  final bool isMessageQuotaExhausted;

  /// Whether user has exhausted their token budget.
  final bool isTokenQuotaExhausted;

  QuotaState({
    required this.remainingMessages,
    required this.remainingTokenBudget,
    required this.plan,
    this.upgradeHint,
    bool? isMessageQuotaExhausted,
    bool? isTokenQuotaExhausted,
  })  : isMessageQuotaExhausted =
            isMessageQuotaExhausted ?? (remainingMessages <= 0),
        isTokenQuotaExhausted =
            isTokenQuotaExhausted ?? (remainingTokenBudget <= 0);

  /// Create from ChatMetadata.
  factory QuotaState.fromMetadata(ChatMetadata metadata) {
    return QuotaState(
      remainingMessages: metadata.remainingMessagesToday,
      remainingTokenBudget: metadata.remainingTokenBudgetToday,
      plan: metadata.plan,
      upgradeHint: metadata.upgradeHint,
    );
  }

  /// Create initial state (unknown quota).
  factory QuotaState.initial() {
    return QuotaState(
      remainingMessages: 0,
      remainingTokenBudget: 0,
      plan: 'free',
    );
  }

  /// Create copy with updated fields.
  QuotaState copyWith({
    int? remainingMessages,
    int? remainingTokenBudget,
    String? plan,
    String? upgradeHint,
    bool? isMessageQuotaExhausted,
    bool? isTokenQuotaExhausted,
  }) {
    return QuotaState(
      remainingMessages: remainingMessages ?? this.remainingMessages,
      remainingTokenBudget: remainingTokenBudget ?? this.remainingTokenBudget,
      plan: plan ?? this.plan,
      upgradeHint: upgradeHint ?? this.upgradeHint,
      isMessageQuotaExhausted:
          isMessageQuotaExhausted ?? this.isMessageQuotaExhausted,
      isTokenQuotaExhausted:
          isTokenQuotaExhausted ?? this.isTokenQuotaExhausted,
    );
  }

  /// Check if user can send messages.
  bool get canSendMessage => !isMessageQuotaExhausted && !isTokenQuotaExhausted;

  /// Check if user is on paid plan.
  bool get isPaid => plan == 'paid';
}
