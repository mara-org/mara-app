import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../repositories/chat_repository.dart';
import '../../data/models/chat_request.dart';
import '../../data/models/chat_response.dart';

/// Use case for sending chat messages.
///
/// Encapsulates the business logic for chat operations.
class SendMessageUseCase {
  final ChatRepository _chatRepository;

  SendMessageUseCase(this._chatRepository);

  /// Send a chat message.
  ///
  /// Returns [ChatResponse] with assistant's reply.
  /// Throws [ApiException] on error.
  Future<ChatResponse> execute(ChatRequest request) async {
    // Validate message length (client-side guard)
    if (request.message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    if (request.message.length > 10000) {
      throw ArgumentError('Message is too long (max 10,000 characters)');
    }

    Logger.info(
      'Executing send message use case',
      feature: 'chat',
      screen: 'send_message_usecase',
      extra: {
        'message_length': request.message.length,
        'quality': request.quality,
      },
    );

    try {
      final response = await _chatRepository.sendMessage(request);

      Logger.info(
        'Message sent successfully',
        feature: 'chat',
        screen: 'send_message_usecase',
        extra: {
          'remaining_messages': response.metadata.remainingMessagesToday,
          'plan': response.metadata.plan,
        },
      );

      return response;
    } on ApiException catch (e) {
      Logger.error(
        'Send message use case error',
        feature: 'chat',
        screen: 'send_message_usecase',
        error: e,
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in send message use case',
        feature: 'chat',
        screen: 'send_message_usecase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
