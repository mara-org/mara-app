import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: () => context.go('/subscription'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left: back arrow icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.languageButtonColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.languageButtonColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Center: Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.upgradeYourMaraAccount,
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.upgradeSubtitle,
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: spark/badge icon
            Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.languageButtonColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
