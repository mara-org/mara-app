import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/retry_policy.dart';
import '../../../core/utils/logger.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Remote data source for chat operations.
///
/// Handles all communication with the backend chat API.
abstract class ChatRemoteDataSource {
  /// Send a chat message to the backend.
  ///
  /// Returns [ChatResponse] with assistant's reply and quota information.
  /// Throws [ApiException] on error.
  Future<ChatResponse> sendMessage(ChatRequest request);
}

/// Implementation of [ChatRemoteDataSource] using Dio HTTP client.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;
  final RetryPolicy _retryPolicy;
  static const _uuid = Uuid();

  ChatRemoteDataSourceImpl(
    this._apiClient, [
    RetryPolicy? retryPolicy,
  ]) : _retryPolicy = retryPolicy ?? RetryPolicy();

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    // Generate request ID if not provided
    final requestId = request.requestId ?? _uuid.v4();

    // Create request with request ID
    final requestWithId = request.copyWith(requestId: requestId);

    Logger.info(
      'Sending chat message',
      feature: 'chat',
      screen: 'chat_remote_datasource',
      extra: {
        'request_id': requestId,
        'has_conversation_id': request.conversationId != null,
        'quality': request.quality,
      },
    );

    int attemptCount = 0;

    while (true) {
      try {
        final response = await _apiClient.dio.post(
          ApiConfig.chatEndpoint,
          data: requestWithId.toJson(),
          options: Options(
            headers: {
              ApiConfig.requestIdHeader: requestId,
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final chatResponse = ChatResponse.fromJson(response.data);

          Logger.info(
            'Chat message sent successfully',
            feature: 'chat',
            screen: 'chat_remote_datasource',
            extra: {
              'request_id': requestId,
              'remaining_messages': chatResponse.metadata.remainingMessagesToday,
              'remaining_tokens': chatResponse.metadata.remainingTokenBudgetToday,
              'plan': chatResponse.metadata.plan,
            },
          );

          return chatResponse;
        } else {
          throw UnknownApiException(
            'Unexpected status code: ${response.statusCode}',
          );
        }
      } on DioException catch (e) {
        final apiException = mapDioException(e);

        // Check if we should retry
        if (_retryPolicy.shouldRetry(e, attemptCount)) {
          attemptCount++;
          final delay = _retryPolicy.getRetryDelay(attemptCount - 1);

          Logger.warning(
            'Retrying chat request',
            feature: 'chat',
            screen: 'chat_remote_datasource',
            extra: {
              'request_id': requestId,
              'attempt': attemptCount,
              'delay_ms': delay.inMilliseconds,
            },
          );

          await Future.delayed(delay);
          continue;
        }

        // Don't retry - throw the exception
        Logger.error(
          'Chat request failed',
          feature: 'chat',
          screen: 'chat_remote_datasource',
          error: apiException,
          extra: {
            'request_id': requestId,
            'status_code': apiException.statusCode,
          },
        );

        rethrow;
      } catch (e) {
        if (e is ApiException) rethrow;

        Logger.error(
          'Unexpected error sending chat message',
          feature: 'chat',
          screen: 'chat_remote_datasource',
          error: e,
          extra: {'request_id': requestId},
        );

        throw UnknownApiException('Failed to send chat message: $e');
      }
    }
  }
}

