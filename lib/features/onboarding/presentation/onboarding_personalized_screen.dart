import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingPersonalizedScreen extends StatelessWidget {
  const OnboardingPersonalizedScreen({super.key});

  Widget _buildHeartIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF38BDF8).withOpacity(0.2), // #38BDF8 at 20%
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/favorite.png',
          fit: BoxFit.contain,
        ),
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
              Color(0xFFBAE6FD), // #BAE6FD (top)
              Color(0xFF7DD3FC), // #7DD3FC (bottom)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: h * 0.18), // Top spacing
              
              // 1) Large blue heart icon
              _buildHeartIcon(),
              
              const SizedBox(height: 16), // 16px spacing
              
              // 2) Title: "Personalized health insights, made just for you"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  l10n.personalizedTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A), // #0F172A
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
                    color: const Color(0xFF0F172A).withOpacity(0.65), // 60-70% opacity
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 4) Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: PrimaryButton(
                  text: l10n.continueButton,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: () {
                    context.go('/sign-up-choices');
                  },
                ),
              ),
              
              // 5) "Already have an account?" text
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
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              
              SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
