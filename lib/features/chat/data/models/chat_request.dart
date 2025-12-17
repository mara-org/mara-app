/// Chat request model for backend API.
///
/// Represents a single chat message request to the backend.
class ChatRequest {
  /// The user's message text.
  final String message;

  /// Conversation ID (optional, for continuing conversations).
  final String? conversationId;

  /// Quality mode: "standard" or "high" (paid only).
  final String quality;

  /// Request ID for tracking (optional, generated client-side).
  final String? requestId;

  ChatRequest({
    required this.message,
    this.conversationId,
    this.quality = 'standard',
    this.requestId,
  });

  /// Convert to JSON for API request.
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      'quality': quality,
      if (requestId != null) 'request_id': requestId,
    };
  }

  /// Create a copy with updated fields.
  ChatRequest copyWith({
    String? message,
    String? conversationId,
    String? quality,
    String? requestId,
  }) {
    return ChatRequest(
      message: message ?? this.message,
      conversationId: conversationId ?? this.conversationId,
      quality: quality ?? this.quality,
      requestId: requestId ?? this.requestId,
    );
  }
}

