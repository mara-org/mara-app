import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for storing the last conversation topic
final lastConversationTopicProvider = StateProvider<String?>((ref) => null);

/// Provider to check if there are any previous conversations
final hasPreviousConversationsProvider = Provider<bool>((ref) {
  final topic = ref.watch(lastConversationTopicProvider);
  return topic != null && topic.isNotEmpty;
});

