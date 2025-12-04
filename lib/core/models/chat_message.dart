/// Type of chat message.
enum MessageType {
  /// Message sent by the user.
  user,

  /// Message sent by the bot/assistant.
  bot,
}

/// Domain model representing a chat message.
///
/// Contains business logic and validation for chat messages.
class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final String? id;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.id,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Validates if the message is valid.
  ///
  /// Returns true if the message text is not empty and within length limits.
  bool get isValid {
    return text.trim().isNotEmpty && text.length <= 10000; // Max 10k characters
  }

  /// Gets a display-friendly timestamp.
  ///
  /// Returns a formatted string representation of the timestamp.
  String get displayTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Checks if the message is from the user.
  bool get isFromUser => type == MessageType.user;

  /// Checks if the message is from the bot.
  bool get isFromBot => type == MessageType.bot;

  /// Validates the message text.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.length > 10000) {
      return 'Message is too long (max 10,000 characters)';
    }
    return null;
  }

  /// Creates a copy of this message with updated fields.
  ChatMessage copyWith({
    String? text,
    MessageType? type,
    DateTime? timestamp,
    String? id,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ type.hashCode;

  @override
  String toString() =>
      'ChatMessage(id: $id, type: $type, text: ${text.length > 50 ? "${text.substring(0, 50)}..." : text})';
}
