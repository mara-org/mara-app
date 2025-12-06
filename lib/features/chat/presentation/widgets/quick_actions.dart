import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';

/// Quick action buttons for common health queries in the chat.
///
/// These buttons allow users to quickly ask common questions without typing.
class ChatQuickActions extends ConsumerWidget {
  final Function(String)? onActionSelected;

  const ChatQuickActions({super.key, this.onActionSelected});

  void _sendQuickMessage(
      BuildContext context, WidgetRef ref, String message) {
    if (onActionSelected != null) {
      onActionSelected!(message);
    } else {
      // Fallback: navigate to chat
      context.go('/chat');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final backgroundColor = isDark
        ? AppColorsDark.cardBackground
        : AppColors.cardBackground;
    final textColor = isDark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;
    final buttonColor = isDark
        ? AppColorsDark.languageButtonColor
        : AppColors.languageButtonColor;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                label: l10n.howAreMyStepsToday,
                onTap: () => _sendQuickMessage(
                  context,
                  ref,
                  l10n.howAreMyStepsToday,
                ),
                backgroundColor: backgroundColor,
                textColor: textColor,
                borderColor: buttonColor,
              ),
              _QuickActionChip(
                label: l10n.howWasMySleepThisWeek,
                onTap: () => _sendQuickMessage(
                  context,
                  ref,
                  l10n.howWasMySleepThisWeek,
                ),
                backgroundColor: backgroundColor,
                textColor: textColor,
                borderColor: buttonColor,
              ),
              _QuickActionChip(
                label: l10n.howMuchWaterDidIDrinkToday,
                onTap: () => _sendQuickMessage(
                  context,
                  ref,
                  l10n.howMuchWaterDidIDrinkToday,
                ),
                backgroundColor: backgroundColor,
                textColor: textColor,
                borderColor: buttonColor,
              ),
              _QuickActionChip(
                label: l10n.showMeMyHealthDashboard,
                onTap: () {
                  // Always navigate to analytics screen
                  context.go('/analytics');
                },
                backgroundColor: backgroundColor,
                textColor: textColor,
                borderColor: buttonColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

