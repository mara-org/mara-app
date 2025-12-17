import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';

/// Toggle widget for High Quality Mode (paid only).
///
/// Only visible for paid users. Shows toggle to enable/disable high quality mode.
class QualityToggle extends StatelessWidget {
  final bool isPaid;
  final bool isHighQualityMode;
  final ValueChanged<bool> onChanged;

  const QualityToggle({
    super.key,
    required this.isPaid,
    required this.isHighQualityMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Only show for paid users
    if (!isPaid) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.languageButtonColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.highQualityMode ?? 'High Quality Mode',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: isHighQualityMode,
            onChanged: onChanged,
            activeColor: AppColors.languageButtonColor,
          ),
        ],
      ),
    );
  }
}

