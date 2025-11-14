import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Icon placeholder (cognition/brain icon)
                  Container(
                    width: 80,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.languageButtonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 48,
                      color: AppColors.languageButtonColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    'Are you ready?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.languageButtonColor,
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'To start your journey you need to answer few question',
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
                    text: 'Ready!',
                    onPressed: () {
                      context.go('/name-input');
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

