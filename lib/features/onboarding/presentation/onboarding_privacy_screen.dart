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
      body: Container(
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
              
              const Spacer(),
              
              // 5) Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
            ],
          ),
        ),
      ),
    );
  }
}
