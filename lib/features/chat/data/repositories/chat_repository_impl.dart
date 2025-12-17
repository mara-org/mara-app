import '../../../core/network/api_exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../domain/entities/quota_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';
import '../models/quota_state.dart';

/// Implementation of [ChatRepository].
///
/// Coordinates between remote data source and domain layer.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  QuotaState? _cachedQuotaState;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    try {
      Logger.info(
        'Sending chat message via repository',
        feature: 'chat',
        screen: 'chat_repository',
        extra: {
          'has_conversation_id': request.conversationId != null,
          'quality': request.quality,
        },
      );

      final response = await _remoteDataSource.sendMessage(request);

      // Update cached quota state
      _cachedQuotaState = QuotaState.fromMetadata(response.metadata);

      Logger.info(
        'Chat message sent successfully',
        feature: 'chat',
        screen: 'chat_repository',
        extra: {
          'remaining_messages': response.metadata.remainingMessagesToday,
          'remaining_tokens': response.metadata.remainingTokenBudgetToday,
          'plan': response.metadata.plan,
        },
      );

      return response;
    } on ApiException catch (e) {
      Logger.error(
        'Chat repository error',
        feature: 'chat',
        screen: 'chat_repository',
        error: e,
        extra: {'status_code': e.statusCode},
      );
      rethrow;
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error in chat repository',
        feature: 'chat',
        screen: 'chat_repository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<QuotaEntity?> getQuotaState() async {
    if (_cachedQuotaState == null) {
      return null;
    }

    return QuotaEntity(
      remainingMessages: _cachedQuotaState!.remainingMessages,
      remainingTokenBudget: _cachedQuotaState!.remainingTokenBudget,
      isPaid: _cachedQuotaState!.isPaid,
      upgradeHint: _cachedQuotaState!.upgradeHint,
    );
  }
}

