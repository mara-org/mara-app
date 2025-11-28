import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';

class ChatHistoryNotifier extends StateNotifier<List<Conversation>> {
  ChatHistoryNotifier() : super([]);

  static const _uuid = Uuid();

  /// Create a new conversation from messages
  Conversation createConversation(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      throw ArgumentError('Messages list cannot be empty');
    }

    // Get first user message as title
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.type == MessageType.user,
      orElse: () => messages.first,
    );

    // Generate title from first user message
    final title = _generateTitle(firstUserMessage.text);

    // Get last message as preview
    final lastMessage = messages.last;
    final preview = lastMessage.text.length > 60
        ? '${lastMessage.text.substring(0, 60)}...'
        : lastMessage.text;

    // Extract topic from first user message
    final topic = _extractTopic(firstUserMessage.text);

    // Get timestamp from first message
    final timestamp = messages.first.timestamp;

    final conversation = Conversation(
      id: _uuid.v4(),
      title: title,
      preview: preview,
      timestamp: timestamp,
      messages: List.from(messages),
      topic: topic,
    );

    // Add to state
    state = [conversation, ...state];

    return conversation;
  }

  /// Update an existing conversation with new messages
  void updateConversation(String conversationId, List<ChatMessage> messages) {
    if (messages.isEmpty) return;

    state = state.map((conv) {
      if (conv.id == conversationId) {
        final lastMessage = messages.last;
        final preview = lastMessage.text.length > 60
            ? '${lastMessage.text.substring(0, 60)}...'
            : lastMessage.text;

        return conv.copyWith(
          messages: List.from(messages),
          preview: preview,
        );
      }
      return conv;
    }).toList();
  }

  /// Delete a conversation
  void deleteConversation(String conversationId) {
    state = state.where((conv) => conv.id != conversationId).toList();
  }

  /// Get a conversation by ID
  Conversation? getConversation(String conversationId) {
    try {
      return state.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  /// Generate a title from the first user message
  String _generateTitle(String firstMessage) {
    final words = firstMessage.split(' ');
    if (words.length > 4) {
      return '${words.take(4).join(' ')}...';
    } else if (firstMessage.length > 30) {
      return '${firstMessage.substring(0, 30)}...';
    }
    return firstMessage;
  }

  /// Extract topic from message text for icon classification
  String? _extractTopic(String text) {
    final lowerText = text.toLowerCase();
    
    // Health symptoms
    if (lowerText.contains(RegExp(r'\b(cough|fever|headache|pain|ache|symptom|sick|ill|nause|dizzy|tired|fatigue)\b'))) {
      return 'symptoms';
    }
    
    // Hydration
    if (lowerText.contains(RegExp(r'\b(water|hydrat|drink|thirst|dehydrat)\b'))) {
      return 'hydration';
    }
    
    // Sleep
    if (lowerText.contains(RegExp(r'\b(sleep|insomnia|rest|tired|awake|dream|night)\b'))) {
      return 'sleep';
    }
    
    // Exercise/Fitness
    if (lowerText.contains(RegExp(r'\b(exercise|workout|run|walk|steps|fitness|gym|sport)\b'))) {
      return 'exercise';
    }
    
    // Heart/Cardiovascular
    if (lowerText.contains(RegExp(r'\b(heart|cardiac|pulse|blood pressure|bp|cardiovascular)\b'))) {
      return 'heart';
    }
    
    // Nutrition/Diet
    if (lowerText.contains(RegExp(r'\b(food|eat|diet|nutrition|meal|calorie|weight)\b'))) {
      return 'nutrition';
    }
    
    return null;
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<Conversation>>(
  (ref) => ChatHistoryNotifier(),
);


