import 'chat_message.dart';

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
}
