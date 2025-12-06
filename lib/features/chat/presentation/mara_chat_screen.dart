import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/providers/chat_history_provider.dart';
import '../../../core/providers/chat_messages_provider.dart';
import '../../../core/providers/chat_topic_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/widgets/main_bottom_navigation.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/quick_actions.dart';

class MaraChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;

  const MaraChatScreen({super.key, this.conversationId});

  @override
  ConsumerState<MaraChatScreen> createState() => _MaraChatScreenState();
}

class _MaraChatScreenState extends ConsumerState<MaraChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentConversationId;
  bool _hasLoadedConversation = false;

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId;
    // Clear messages if starting a new conversation
    if (widget.conversationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatMessagesProvider.notifier).clearMessages();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load conversation if conversationId is provided and not already loaded
    if (_currentConversationId != null && !_hasLoadedConversation && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadConversation(_currentConversationId!);
      });
    }
  }

  void _loadConversation(String conversationId) {
    if (_hasLoadedConversation) return;

    final conversation =
        ref.read(chatHistoryProvider.notifier).getConversation(conversationId);
    if (conversation != null) {
      ref
          .read(chatMessagesProvider.notifier)
          .loadMessages(conversation.messages);
      if (conversation.topic != null) {
        ref.read(lastConversationTopicProvider.notifier).state =
            conversation.title;
      }
      _hasLoadedConversation = true;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    final messages = ref.read(chatMessagesProvider);
    final isFirstMessage = messages.isEmpty;

    // Add user message
    ref
        .read(chatMessagesProvider.notifier)
        .addMessage(ChatMessage(text: messageText, type: MessageType.user));

    // Save topic from first user message
    if (isFirstMessage) {
      // Extract topic: take first few words (up to 3-4 words) or first sentence
      final words = messageText.split(' ');
      final topic = words.length > 4
          ? words.take(4).join(' ') + '...'
          : messageText.length > 30
              ? messageText.substring(0, 30) + '...'
              : messageText;
      ref.read(lastConversationTopicProvider.notifier).state = topic;
    }

    if (text == null) {
      _messageController.clear();
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Add mocked Mara reply after a short delay
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(chatMessagesProvider.notifier).addMessage(
              ChatMessage(text: l10n.thanksForSharing, type: MessageType.bot),
            );

        // Update or create conversation in history
        final updatedMessages = ref.read(chatMessagesProvider);
        if (_currentConversationId != null) {
          // Update existing conversation
          ref
              .read(chatHistoryProvider.notifier)
              .updateConversation(_currentConversationId!, updatedMessages);
        } else if (updatedMessages.length >= 2) {
          // Create new conversation (at least user message + bot reply)
          final conversation = ref
              .read(chatHistoryProvider.notifier)
              .createConversation(updatedMessages);
          _currentConversationId = conversation.id;
        }

        // Scroll to bottom again
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = ref.watch(chatMessagesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const MaraLogo(width: 32, height: 32),
            const SizedBox(width: 12),
            Text(l10n.maraChat),
          ],
        ),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push('/chat-history');
            },
            tooltip: l10n.chatHistory,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: messages.isEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            l10n.whatsInYourHead,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ChatQuickActions(
                            onActionSelected: (message) {
                              _sendMessage(message);
                            },
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final showTimestamp = index == 0 ||
                            messages[index - 1]
                                    .timestamp
                                    .difference(message.timestamp)
                                    .inMinutes >
                                5;
                        return _MessageBubble(
                          message: message,
                          showTimestamp: showTimestamp,
                        );
                      },
                    ),
            ),
            // Input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.cardBackground : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: l10n.whatsInYourHead,
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : AppColors.textSecondary,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColors.languageButtonColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.languageButtonColor,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTimestamp;

  const _MessageBubble({
    required this.message,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  _formatTimestamp(message.timestamp, l10n),
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.languageButtonColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.languageButtonColor
                        : (isDark
                            ? AppColorsDark.permissionCardBackground
                            : AppColors.permissionCardBackground),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary),
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 40),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 40,
              right: isUser ? 0 : 0,
            ),
            child: Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
