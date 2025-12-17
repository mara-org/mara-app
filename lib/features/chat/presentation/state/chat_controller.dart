import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/chat_message.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/chat_request.dart';
import '../../data/models/quota_state.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_state.dart';

/// Controller for chat screen state management.
///
/// Uses Riverpod StateNotifier to manage chat state.
class ChatController extends StateNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  static const _uuid = Uuid();

  ChatController(this._sendMessageUseCase) : super(ChatState.initial());

  /// Send a message to the chat.
  ///
  /// Shows optimistic UI, sends request, updates state with response.
  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;
    if (!state.canSendMessage) return;

    // Optimistic UI: Add user message immediately
    final userMessage = ChatMessage(
      text: messageText.trim(),
      type: MessageType.user,
      id: _uuid.v4(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      // Create request
      final request = ChatRequest(
        message: messageText.trim(),
        conversationId: state.conversationId,
        quality: state.isHighQualityMode ? 'high' : 'standard',
        requestId: _uuid.v4(),
      );

      // Send to backend
      final response = await _sendMessageUseCase.execute(request);

      // Add assistant response
      final assistantMessage = ChatMessage(
        text: response.text,
        type: MessageType.bot,
        id: _uuid.v4(),
      );

      // Update quota state
      final quotaState = QuotaState.fromMetadata(response.metadata);

      // Update conversation ID if provided
      final conversationId = state.conversationId ?? request.conversationId;

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        quotaState: quotaState,
        conversationId: conversationId,
      );

      Logger.info(
        'Message sent and response received',
        feature: 'chat',
        screen: 'chat_controller',
        extra: {
          'remaining_messages': quotaState.remainingMessages,
          'remaining_tokens': quotaState.remainingTokenBudget,
        },
      );
    } on ForbiddenException catch (e) {
      // Quota exhausted or plan restriction
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );

      // Update quota state if available
      final currentQuota = state.quotaState;
      if (currentQuota != null) {
        state = state.copyWith(
          quotaState: currentQuota.copyWith(
            remainingMessages: 0,
            remainingTokenBudget: 0,
          ),
        );
      }
    } on RateLimitException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } on UnauthorizedException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please sign in to continue',
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      Logger.error(
        'Unexpected error sending message',
        feature: 'chat',
        screen: 'chat_controller',
        error: e,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Toggle high quality mode (paid only).
  ///
  /// Throws if user is not on paid plan.
  void toggleHighQualityMode() {
    if (!state.isPaid) {
      throw StateError('High quality mode is only available for paid users');
    }

    state = state.copyWith(
      isHighQualityMode: !state.isHighQualityMode,
    );
  }

  /// Set conversation ID.
  void setConversationId(String? conversationId) {
    state = state.copyWith(conversationId: conversationId);
  }

  /// Clear messages and reset state.
  void clearMessages() {
    state = ChatState.initial();
  }

  /// Load messages from conversation.
  void loadMessages(List<ChatMessage> messages) {
    state = state.copyWith(messages: List.from(messages));
  }
}

