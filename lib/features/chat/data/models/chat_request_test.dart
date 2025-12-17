import 'package:flutter_test/flutter_test.dart';
import 'chat_request.dart';

void main() {
  group('ChatRequest', () {
    test('should create request with required fields', () {
      final request = ChatRequest(message: 'Hello');

      expect(request.message, 'Hello');
      expect(request.conversationId, isNull);
      expect(request.quality, 'standard');
      expect(request.requestId, isNull);
    });

    test('should create request with all fields', () {
      final request = ChatRequest(
        message: 'Hello',
        conversationId: 'conv-123',
        quality: 'high',
        requestId: 'req-456',
      );

      expect(request.message, 'Hello');
      expect(request.conversationId, 'conv-123');
      expect(request.quality, 'high');
      expect(request.requestId, 'req-456');
    });

    test('should convert to JSON correctly', () {
      final request = ChatRequest(
        message: 'Hello',
        conversationId: 'conv-123',
        quality: 'high',
        requestId: 'req-456',
      );

      final json = request.toJson();

      expect(json['message'], 'Hello');
      expect(json['conversation_id'], 'conv-123');
      expect(json['quality'], 'high');
      expect(json['request_id'], 'req-456');
    });

    test('should convert to JSON without optional fields', () {
      final request = ChatRequest(message: 'Hello');

      final json = request.toJson();

      expect(json['message'], 'Hello');
      expect(json.containsKey('conversation_id'), false);
      expect(json.containsKey('request_id'), false);
    });

    test('should create copy with updated fields', () {
      final original = ChatRequest(message: 'Hello');
      final updated = original.copyWith(
        message: 'Hi',
        quality: 'high',
      );

      expect(updated.message, 'Hi');
      expect(updated.quality, 'high');
      expect(updated.conversationId, isNull);
    });
  });
}

