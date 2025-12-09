import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class OnboardingPrivacyScreen extends StatelessWidget {
  const OnboardingPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.backgroundLight : Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: isDark
                ? AppColorsDark.backgroundLight
                : Colors.white, // Pure white background
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: h * 0.18), // Top spacing similar to Figma
                  // 1) Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.privacyTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary, // #0F172A
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2) Icons row (lock + globe)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 53.49,
                        height: 70.2,
                        child: Image.asset(
                          'assets/icons/lock.png',
                          width: 53.49,
                          height: 70.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 69,
                        height: 66.86,
                        child: Image.asset(
                          'assets/icons/globe_uk.png',
                          width: 69,
                          height: 66.86,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3) "Mara understands 100+ languages"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.privacySubtitle1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary, // #0F172A
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 4) Smaller description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l10n.privacySubtitle2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary, // #64748B
                      ),
                    ),
                  ),
                ],
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
                  context.go('/onboarding-personalized');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
