import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // #E0F7FA (top)
              Color(0xFFF9FAFB), // #F9FAFB (bottom)
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
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A), // #0F172A
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
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B), // #64748B
                ),
              ),
            ),
            // Bottom white card (fixed height ~22% of screen) - same as welcome screen
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: h * 0.22 + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 24,
                    end: 24,
                    top: 32,
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrimaryButton(
                        text: l10n.continueButton,
                        width: 324,
                        height: 52,
                        borderRadius: 20,
                        onPressed: () {
                          context.go('/onboarding-privacy');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
