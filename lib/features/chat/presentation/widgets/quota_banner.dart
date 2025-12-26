import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/quota_state.dart';

/// Banner widget showing remaining quota information.
///
/// Displays remaining messages and token budget in a subtle banner.
class QuotaBanner extends StatelessWidget {
  final QuotaState? quotaState;

  const QuotaBanner({
    super.key,
    this.quotaState,
  });

  @override
  Widget build(BuildContext context) {
    if (quotaState == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Don't show if quota is exhausted (show upgrade banner instead)
    if (!quotaState!.canSendMessage) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsDark.cardBackground
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AppColorsDark.borderColor
              : AppColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${'Remaining today'}: ${quotaState!.remainingMessages} ${'messages'}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${'Token budget'}: ${quotaState!.remainingTokenBudget}',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

