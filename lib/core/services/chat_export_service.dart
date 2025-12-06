import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/conversation.dart';
import '../utils/logger.dart';

/// Service for exporting chat conversations locally.
class ChatExportService {
  /// Export a single conversation to a file.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> exportConversation(Conversation conversation) async {
    try {
      final directory = await _getExportDirectory();
      if (directory == null) {
        return false;
      }

      final fileName =
          'mara_conversation_${conversation.id}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      final content = _formatConversationForExport(conversation);
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Mara Conversation Export');

      Logger.info(
        'ChatExportService: Exported conversation ${conversation.id}',
        feature: 'chat_export',
        screen: 'chat_export_service',
      );

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'ChatExportService: Error exporting conversation',
        error: e,
        stackTrace: stackTrace,
        feature: 'chat_export',
        screen: 'chat_export_service',
      );
      return false;
    }
  }

  /// Export all conversations to a file.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> exportAllConversations(List<Conversation> conversations) async {
    try {
      if (conversations.isEmpty) {
        return false;
      }

      final directory = await _getExportDirectory();
      if (directory == null) {
        return false;
      }

      final fileName =
          'mara_all_conversations_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      final buffer = StringBuffer();
      buffer.writeln('MARA CHAT CONVERSATIONS EXPORT');
      buffer.writeln('Export Date: ${DateTime.now().toIso8601String()}');
      buffer.writeln('Total Conversations: ${conversations.length}');
      buffer.writeln('');
      buffer.writeln('=' * 60);
      buffer.writeln('');

      for (var i = 0; i < conversations.length; i++) {
        final conversation = conversations[i];
        buffer.writeln(_formatConversationForExport(conversation));
        if (i < conversations.length - 1) {
          buffer.writeln('');
          buffer.writeln('=' * 60);
          buffer.writeln('');
        }
      }

      await file.writeAsString(buffer.toString());

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Mara All Conversations Export');

      Logger.info(
        'ChatExportService: Exported ${conversations.length} conversations',
        feature: 'chat_export',
        screen: 'chat_export_service',
      );

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'ChatExportService: Error exporting all conversations',
        error: e,
        stackTrace: stackTrace,
        feature: 'chat_export',
        screen: 'chat_export_service',
      );
      return false;
    }
  }

  String _formatConversationForExport(Conversation conversation) {
    final buffer = StringBuffer();
    buffer.writeln('CONVERSATION: ${conversation.title}');
    buffer.writeln('Date: ${conversation.timestamp.toIso8601String()}');
    if (conversation.topic != null) {
      buffer.writeln('Topic: ${conversation.topic}');
    }
    buffer.writeln('Messages: ${conversation.messageCount}');
    buffer.writeln('');
    buffer.writeln('-' * 40);
    buffer.writeln('');

    for (final message in conversation.messages) {
      final sender = message.type.toString().split('.').last.toUpperCase();
      final timestamp = message.timestamp.toIso8601String();
      buffer.writeln('[$timestamp] $sender:');
      buffer.writeln(message.text);
      buffer.writeln('');
    }

    return buffer.toString();
  }

  Future<Directory?> _getExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        return directory;
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        return Directory('${directory.path}/exports')..createSync(recursive: true);
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error(
        'ChatExportService: Error getting export directory',
        error: e,
        stackTrace: stackTrace,
        feature: 'chat_export',
        screen: 'chat_export_service',
      );
      return null;
    }
  }
}
