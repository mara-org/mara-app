import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingPersonalizedScreen extends StatelessWidget {
  const OnboardingPersonalizedScreen({super.key});

  Widget _buildHeartIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.favorite_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'Personalized health insights, made just for you',
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
                  'Mara learns from your daily patterns to help you stay healthy, motivated, and consistent.',
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
                  text: 'Continue',
                  onPressed: () {
                    context.go('/sign-up-choices');
                  },
                ),
              ),
              
              // 5) "Already have an account?" text
              Text(
                'Already have an account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
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
