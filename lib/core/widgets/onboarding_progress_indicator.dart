import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_dark.dart';
import '../../l10n/app_localizations.dart';

/// Progress indicator for onboarding screens.
///
/// Shows "Step X of Y" with a progress bar. RTL-aware and theme-aware.
class OnboardingProgressIndicator extends StatelessWidget {
  /// Current step (1-based).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  /// Whether to show the progress bar.
  final bool showProgressBar;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showProgressBar = true,
  }) : assert(currentStep > 0 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Determine colors based on theme
    final progressColor = isDark 
        ? AppColorsDark.languageButtonColor 
        : AppColors.languageButtonColor;
    final backgroundColor = isDark
        ? AppColorsDark.borderColor
        : AppColors.borderColor;
    final textColor = isDark
        ? AppColorsDark.textPrimary
        : AppColors.textPrimary;

    return Column(
      children: [
        // Step text
        Text(
          l10n.stepXOfY(currentStep, totalSteps),
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showProgressBar) ...[
          const SizedBox(height: 8),
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: backgroundColor,
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: currentStep / totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: progressColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

