/// Domain entity for quota information.
///
/// Represents user's quota state in the domain layer.
class QuotaEntity {
  final int remainingMessages;
  final int remainingTokenBudget;
  final bool isPaid;
  final String? upgradeHint;

  QuotaEntity({
    required this.remainingMessages,
    required this.remainingTokenBudget,
    required this.isPaid,
    this.upgradeHint,
  });

  /// Check if user can send messages.
  bool get canSendMessage => remainingMessages > 0 && remainingTokenBudget > 0;
}
