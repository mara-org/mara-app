import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingPrivacyScreen extends StatelessWidget {
  const OnboardingPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white, // Pure white background
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
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A), // #0F172A
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
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A), // #0F172A
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
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B), // #64748B
                      ),
                    ),
                  ),
                ],
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
                        context.go('/onboarding-personalized');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
