import '../../../../core/models/chat_message.dart';
import '../../data/models/quota_state.dart';

/// State for chat screen.
///
/// Manages messages, loading state, errors, and quota information.
class ChatState {
  /// List of chat messages.
  final List<ChatMessage> messages;

  /// Whether a request is in progress.
  final bool isLoading;

  /// Error message (null if no error).
  final String? errorMessage;

  /// Current quota state.
  final QuotaState? quotaState;

  /// Whether high quality mode is enabled (paid only).
  final bool isHighQualityMode;

  /// Current conversation ID (null for new conversations).
  final String? conversationId;

  ChatState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
    this.quotaState,
    this.isHighQualityMode = false,
    this.conversationId,
  });

  /// Create initial state.
  factory ChatState.initial() {
    return ChatState(
      messages: [],
      isLoading: false,
      errorMessage: null,
      quotaState: QuotaState.initial(),
      isHighQualityMode: false,
      conversationId: null,
    );
  }

  /// Create copy with updated fields.
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    QuotaState? quotaState,
    bool? isHighQualityMode,
    String? conversationId,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      quotaState: quotaState ?? this.quotaState,
      isHighQualityMode: isHighQualityMode ?? this.isHighQualityMode,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  /// Check if user can send messages.
  bool get canSendMessage {
    if (isLoading) return false;
    if (quotaState == null) return true; // Unknown quota, allow
    return quotaState!.canSendMessage;
  }

  /// Check if user is on paid plan.
  bool get isPaid => quotaState?.isPaid ?? false;
}
