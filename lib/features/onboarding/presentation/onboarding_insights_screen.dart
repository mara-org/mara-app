import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class OnboardingInsightsScreen extends StatelessWidget {
  const OnboardingInsightsScreen({super.key});

  Widget _buildRobotIcon() {
    return SizedBox(
      width: 88,
      height: 76,
      child: Image.asset(
        'assets/icons/smart_toy.png',
        width: 88,
        height: 76,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColorsDark.onboardingGradientStart,
                    AppColorsDark.onboardingGradientEnd,
                  ]
                : [
                    AppColors.onboardingGradientStart, // #E0F7FA (top)
                    AppColors.onboardingGradientEnd, // #F9FAFB (bottom)
            ],
          ),
        ),
        child: Stack(
          children: [
            // Title positioned at Y = 249/852 (first - highest)
            PositionedDirectional(
              top: h * (249 / 852),
              start: 24,
              end: 24,
              child: Text(
                l10n.onboardingInsightsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary, // #0F172A
                ),
              ),
            ),
            // Robot icon positioned at Y = 321/852 (middle)
            Positioned(
              top: h * (321 / 852),
              left: 0,
              right: 0,
              child: Center(child: _buildRobotIcon()),
            ),
            // Subtitle positioned at Y = 363/852 (last - lowest, renders on top)
            PositionedDirectional(
              top: h * (390 / 852),
              start: 32,
              end: 32,
              child: Text(
                l10n.onboardingInsightsSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary, // #64748B
                ),
              ),
            ),
            // Continue button positioned at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: PrimaryButton(
                  text: l10n.continueButton,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: () {
                    context.go('/onboarding-privacy');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
