import 'chat_message.dart';

/// Domain model representing a conversation/chat thread.
///
/// Contains business logic and validation for conversations.
class Conversation {
  final String id;
  final String title;
  final String preview;
  final DateTime timestamp;
  final List<ChatMessage> messages;
  final String? topic;

  Conversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.timestamp,
    required this.messages,
    this.topic,
  });

  /// Validates if the conversation is valid.
  ///
  /// Returns true if the conversation has a valid ID and title.
  bool get isValid {
    return id.isNotEmpty && title.trim().isNotEmpty;
  }

  /// Gets the number of messages in the conversation.
  int get messageCount => messages.length;

  /// Checks if the conversation has any messages.
  bool get hasMessages => messages.isNotEmpty;

  /// Gets the last message in the conversation.
  ///
  /// Returns null if there are no messages.
  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Gets the last message text for preview.
  ///
  /// Returns the preview text if available, otherwise the last message text.
  String get displayPreview {
    if (preview.isNotEmpty) return preview;
    final last = lastMessage;
    if (last == null) return 'No messages yet';
    return last.text;
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

  /// Validates the conversation title.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.length > 200) {
      return 'Title is too long (max 200 characters)';
    }
    return null;
  }

  /// Adds a message to the conversation.
  ///
  /// Returns a new conversation with the message added.
  Conversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      preview: message.text.length > 100
          ? '${message.text.substring(0, 100)}...'
          : message.text,
    );
  }

  /// Removes a message from the conversation by ID.
  ///
  /// Returns a new conversation with the message removed, or the same conversation if not found.
  Conversation removeMessage(String messageId) {
    final updatedMessages =
        messages.where((msg) => msg.id != messageId).toList();
    if (updatedMessages.length == messages.length) {
      return this; // Message not found
    }
    return copyWith(messages: updatedMessages);
  }

  Conversation copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? timestamp,
    List<ChatMessage>? messages,
    String? topic,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      timestamp: timestamp ?? this.timestamp,
      messages: messages ?? this.messages,
      topic: topic ?? this.topic,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Conversation(id: $id, title: $title, messageCount: $messageCount)';
}
