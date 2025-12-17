/// Chat response model from backend API.
///
/// Represents the complete response from POST /v1/chat endpoint.
class ChatResponse {
  /// The assistant's response text.
  final String text;

  /// Response metadata.
  final ChatMetadata metadata;

  ChatResponse({
    required this.text,
    required this.metadata,
  });

  /// Parse from JSON response.
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      text: json['text'] as String? ?? '',
      metadata: ChatMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Convert to JSON (for testing/caching).
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'metadata': metadata.toJson(),
    };
  }
}

/// Chat response metadata.
///
/// Contains quota information, model details, and upgrade hints.
class ChatMetadata {
  /// Model used for this response.
  final String modelUsed;

  /// Input tokens consumed.
  final int tokensIn;

  /// Output tokens generated.
  final int tokensOut;

  /// Remaining messages for today.
  final int remainingMessagesToday;

  /// Remaining token budget for today.
  final int remainingTokenBudgetToday;

  /// User's plan: "free" or "paid".
  final String plan;

  /// Upgrade hint message (null if not applicable).
  final String? upgradeHint;

  /// Request ID for tracking.
  final String requestId;

  ChatMetadata({
    required this.modelUsed,
    required this.tokensIn,
    required this.tokensOut,
    required this.remainingMessagesToday,
    required this.remainingTokenBudgetToday,
    required this.plan,
    this.upgradeHint,
    required this.requestId,
  });

  /// Parse from JSON.
  factory ChatMetadata.fromJson(Map<String, dynamic> json) {
    return ChatMetadata(
      modelUsed: json['model_used'] as String? ?? 'unknown',
      tokensIn: (json['tokens_in'] as num?)?.toInt() ?? 0,
      tokensOut: (json['tokens_out'] as num?)?.toInt() ?? 0,
      remainingMessagesToday:
          (json['remaining_messages_today'] as num?)?.toInt() ?? 0,
      remainingTokenBudgetToday:
          (json['remaining_token_budget_today'] as num?)?.toInt() ?? 0,
      plan: json['plan'] as String? ?? 'free',
      upgradeHint: json['upgrade_hint'] as String?,
      requestId: json['request_id'] as String? ?? '',
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'model_used': modelUsed,
      'tokens_in': tokensIn,
      'tokens_out': tokensOut,
      'remaining_messages_today': remainingMessagesToday,
      'remaining_token_budget_today': remainingTokenBudgetToday,
      'plan': plan,
      if (upgradeHint != null) 'upgrade_hint': upgradeHint,
      'request_id': requestId,
    };
  }

  /// Check if user is on paid plan.
  bool get isPaid => plan == 'paid';

  /// Check if user has remaining messages.
  bool get hasRemainingMessages => remainingMessagesToday > 0;

  /// Check if user has remaining token budget.
  bool get hasRemainingTokenBudget => remainingTokenBudgetToday > 0;
}

