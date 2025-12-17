import '../entities/quota_entity.dart';
import '../../data/models/chat_request.dart';
import '../../data/models/chat_response.dart';

/// Repository interface for chat operations.
///
/// This defines the contract for chat operations in the domain layer.
abstract class ChatRepository {
  /// Send a chat message and get assistant's response.
  ///
  /// Returns [ChatResponse] with assistant's reply and updated quota.
  /// Throws [ApiException] on error.
  Future<ChatResponse> sendMessage(ChatRequest request);

  /// Get current quota state.
  ///
  /// Returns [QuotaEntity] with current quota information.
  /// Returns null if quota information is not available.
  Future<QuotaEntity?> getQuotaState();
}

