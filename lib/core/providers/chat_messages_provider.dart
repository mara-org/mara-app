import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }

  void loadMessages(List<ChatMessage> messages) {
    state = List.from(messages);
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
      (ref) => ChatMessagesNotifier(),
    );
