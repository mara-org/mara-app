import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/primary_button.dart';

class OnboardingInsightsScreen extends StatelessWidget {
  const OnboardingInsightsScreen({super.key});

  Widget _buildRobotIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5C6), // #0EA5C6
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        size: 40,
        color: Colors.white,
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
              Color(0xFFE0F7FA), // #E0F7FA (top)
              Color(0xFFF9FAFB), // #F9FAFB (bottom)
            ],
          ),
        ),
        child: Stack(
          children: [
            // Title positioned at Y = 249/852 (first - highest)
            Positioned(
              top: h * (249 / 852),
              left: 24,
              right: 24,
              child: const Text(
                'Get instant, accurate medical insights',
                textAlign: TextAlign.center,
                style: TextStyle(
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
            Positioned(
              top: h * (390 / 852),
              left: 32,
              right: 32,
              child: const Text(
                'Powered by advanced AI trained on trusted health data from Mayo Clinic, WHO, and more.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B), // #64748B
                ),
              ),
            ),
            // Bottom button pinned to bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 32 + MediaQuery.of(context).padding.bottom,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    context.go('/onboarding-privacy');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
