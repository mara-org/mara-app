import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/quota_state.dart';

/// Banner widget showing upgrade hint when quota is exhausted.
///
/// Displays upgrade message and navigates to subscription screen.
class UpgradeBanner extends StatelessWidget {
  final QuotaState? quotaState;

  const UpgradeBanner({
    super.key,
    this.quotaState,
  });

  @override
  Widget build(BuildContext context) {
    if (quotaState == null || quotaState!.canSendMessage) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final upgradeMessage =
        quotaState!.upgradeHint ?? 'Unlock higher limits with Pro';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark ? AppColorsDark.cardBackground : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.languageButtonColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            color: AppColors.languageButtonColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              upgradeMessage,
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.push('/subscription'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Upgrade' ?? 'Upgrade',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.languageButtonColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
