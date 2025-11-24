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
        child: Stack(
          children: [
            SafeArea(
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
                ],
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
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
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
