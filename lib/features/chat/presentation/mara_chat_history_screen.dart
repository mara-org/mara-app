import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/conversation.dart';
import '../../../core/providers/chat_history_provider.dart';
import '../../../core/services/chat_export_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';

class MaraChatHistoryScreen extends ConsumerStatefulWidget {
  const MaraChatHistoryScreen({super.key});

  @override
  ConsumerState<MaraChatHistoryScreen> createState() =>
      _MaraChatHistoryScreenState();
}

class _MaraChatHistoryScreenState extends ConsumerState<MaraChatHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatExportService _exportService = ChatExportService();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> _filterConversations(
      List<Conversation> conversations, String query) {
    if (query.isEmpty) return conversations;

    final lowerQuery = query.toLowerCase();
    return conversations.where((conv) {
      return conv.title.toLowerCase().contains(lowerQuery) ||
          conv.preview.toLowerCase().contains(lowerQuery) ||
          (conv.topic?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<void> _exportAllConversations(
      BuildContext context, List<Conversation> conversations) async {
    if (conversations.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(l10n.exporting)),
    );

    final success = await _exportService.exportAllConversations(conversations);

    if (mounted) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(success ? l10n.exportSuccess : l10n.exportError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allConversations = ref.watch(chatHistoryProvider);
    final filteredConversations =
        _filterConversations(allConversations, _searchQuery);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n.searchConversations,
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity( 0.7)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(l10n.chatHistory),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSearching && allConversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              tooltip: l10n.searchChatHistory,
            ),
          if (!_isSearching && allConversations.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'export_all') {
                  await _exportAllConversations(context, allConversations);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'export_all',
                  child: Row(
                    children: [
                      const Icon(Icons.download),
                      const SizedBox(width: 8),
                      Text(l10n.exportAllConversations),
                    ],
                  ),
                ),
              ],
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: filteredConversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: (isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary)
                        .withOpacity( 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? l10n.noConversationsYet
                        : l10n.noResultsFound,
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = filteredConversations[index];
                return _ConversationCard(
                  conversation: conversation,
                  locale: locale,
                  isDark: isDark,
                  onTap: () {
                    // Navigate to chat with conversation ID
                    final uri = Uri(
                      path: '/chat',
                      queryParameters: {'id': conversation.id},
                    );
                    context.go(uri.toString());
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, ref, conversation, l10n);
                  },
                  onExport: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(l10n.exporting)),
                    );

                    final success =
                        await _exportService.exportConversation(conversation);

                    if (mounted) {
                      scaffoldMessenger.hideCurrentSnackBar();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                              success ? l10n.exportSuccess : l10n.exportError),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Conversation conversation,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConversation),
        content: Text(l10n.deleteConversationConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(chatHistoryProvider.notifier)
                  .deleteConversation(conversation.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.conversationDeleted),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final Locale locale;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _ConversationCard({
    required this.conversation,
    required this.locale,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y', locale.toString());
    final timeFormat = DateFormat('h:mm a', locale.toString());
    final dateText = dateFormat.format(conversation.timestamp);
    final timeText = timeFormat.format(conversation.timestamp);

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return AlertDialog(
                  title: Text(l10n.deleteConversation),
                  content: Text(l10n.deleteConversationConfirmation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.delete),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic icon or Mara logo
                  _TopicIcon(topic: conversation.topic),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          conversation.title,
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Preview
                        Text(
                          conversation.preview,
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Date and time
                        Text(
                          '$dateText • $timeText',
                          style: TextStyle(
                            color: (isDark
                                    ? AppColorsDark.textSecondary
                                    : AppColors.textSecondary)
                                .withOpacity( 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Export and arrow icons
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: (isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary)
                          .withOpacity( 0.5),
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'export') {
                        onExport();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            const Icon(Icons.download, size: 20),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!
                                .exportConversation),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: (isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary)
                        .withOpacity( 0.5),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicIcon extends StatelessWidget {
  final String? topic;

  const _TopicIcon({this.topic});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (topic) {
      case 'symptoms':
        iconData = Icons.favorite;
        iconColor = Colors.red.shade400;
        break;
      case 'hydration':
        iconData = Icons.water_drop;
        iconColor = Colors.blue.shade400;
        break;
      case 'sleep':
        iconData = Icons.bedtime;
        iconColor = Colors.indigo.shade400;
        break;
      case 'exercise':
        iconData = Icons.directions_run;
        iconColor = Colors.green.shade400;
        break;
      case 'heart':
        iconData = Icons.favorite;
        iconColor = Colors.pink.shade400;
        break;
      case 'nutrition':
        iconData = Icons.restaurant;
        iconColor = Colors.orange.shade400;
        break;
      default:
        // Use Mara logo for unknown topics
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.languageButtonColor],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: MaraLogo(width: 24, height: 24),
          ),
        );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}
