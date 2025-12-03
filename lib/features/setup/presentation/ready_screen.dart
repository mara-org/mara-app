import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../l10n/app_localizations.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.0026640670839697123, -0.9999666213989258),
            end: Alignment(0.9999666213989258, -0.012521007098257542),
            colors: [
              AppColors.onboardingGradientStart,
              AppColors.onboardingGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: PlatformUtils.getDefaultPadding(context),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // Title
                  Text(
                    l10n.areYouReady,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.languageButtonColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w600, // Semibold
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // cognition_2.png image between headline and secondary line
                  SizedBox(
                    width: 80,
                    height: 84.16,
                    child: Image.asset(
                      'assets/icons/cognition_2.png',
                      width: 80,
                      height: 84.16,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image,
                          color: AppColors.languageButtonColor,
                          size: 48,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.readySubtitleText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Ready button
                  PrimaryButton(
                    text: l10n.readyButton,
                    width: 324,
                    height: 52,
                    borderRadius: 20,
                    onPressed: () {
                      context.push('/name-input');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
