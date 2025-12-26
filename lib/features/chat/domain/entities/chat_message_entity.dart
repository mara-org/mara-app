/// Domain entity for chat messages.
///
/// This is the domain layer representation, independent of data sources.
class ChatMessageEntity {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final String? id;

  ChatMessageEntity({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.id,
  });

  /// Create from data model.
  factory ChatMessageEntity.fromDataModel(
    dynamic dataModel, {
    required bool isFromUser,
  }) {
    return ChatMessageEntity(
      text: dataModel.text as String,
      isFromUser: isFromUser,
      timestamp: dataModel.timestamp as DateTime? ?? DateTime.now(),
      id: dataModel.id as String?,
    );
  }
}
