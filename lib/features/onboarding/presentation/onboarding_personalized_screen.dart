import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';

class OnboardingPersonalizedScreen extends StatelessWidget {
  const OnboardingPersonalizedScreen({super.key});

  Widget _buildHeartIcon(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsDark.languageButtonColor.withOpacity(0.2)
            : const Color(0xFF38BDF8).withOpacity(0.2), // #38BDF8 at 20%
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset('assets/icons/favorite.png', fit: BoxFit.contain),
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
                    AppColorsDark.personalizedGradientStart,
                    AppColorsDark.personalizedGradientEnd,
                  ]
                : [
                    AppColors.personalizedGradientStart, // #BAE6FD (top)
                    AppColors.personalizedGradientEnd, // #7DD3FC (bottom)
                  ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: h * 0.18), // Top spacing
                  // 1) Large blue heart icon
                  _buildHeartIcon(isDark),

                  const SizedBox(height: 16), // 16px spacing
                  // 2) Title: "Personalized health insights, made just for you"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      l10n.personalizedTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColorsDark.textPrimary
                            : AppColors.textPrimary, // #0F172A
                      ),
                    ),
                  ),

                  const SizedBox(height: 12), // 8-12px spacing
                  // 3) Description text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Text(
                      l10n.personalizedSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textPrimary.withOpacity(0.65), // 60-70% opacity
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Continue button positioned at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      text: l10n.continueButton,
                      width: 324,
                      height: 52,
                      borderRadius: 20,
                      onPressed: () {
                        context.go('/sign-up-choices');
                      },
                    ),
                    const SizedBox(height: 16),
                    // "Already have an account?" text
                    GestureDetector(
                      onTap: () {
                        context.go('/welcome-back');
                      },
                      child: Text(
                        l10n.alreadyHaveAccount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppColorsDark.textSecondary
                              : Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
