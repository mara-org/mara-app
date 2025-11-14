import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';

class WelcomeIntroScreen extends StatelessWidget {
  const WelcomeIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFC6ECFF), // #C6ECFF (top)
                  Color(0xFF339AD0), // #339AD0 (bottom)
                ],
              ),
            ),
          ),
          // Title positioned at Y = 324 (~38% of screen height)
          Positioned(
            top: h * 0.38,
            left: 24,
            right: 24,
            child: const Text(
              'Welcome to Mara 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0EA5C6), // #0EA5C6
              ),
            ),
          ),
          // Subtitle positioned at Y = 382 (~45% of screen height)
          Positioned(
            top: h * 0.45,
            left: 24,
            right: 24,
            child: const Text(
              'Your AI-powered health companion is here to help you on your wellness journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF10A9CC), // #10A9CC
                height: 1.5,
              ),
            ),
          ),
          // Bottom white card (fixed height ~22% of screen)
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
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: () {
                        context.go('/onboarding-insights');
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
