import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPrivacyScreen extends StatelessWidget {
  const OnboardingPrivacyScreen({super.key});

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.languageButtonColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 32,
        color: AppColors.languageButtonColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your data stays private',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  _buildCircleIcon(Icons.lock_outline),
                  const SizedBox(width: 16),
                  _buildCircleIcon(Icons.language),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 3) "Mara understands 100+ languages"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Mara understands 100+ languages',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A), // #0F172A
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 4) Smaller description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Speak freely in your own language — Mara listens and keeps your health data 100% private.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  text: 'Continue',
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
