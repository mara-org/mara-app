import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';

class MicrophonePermissionScreen extends ConsumerWidget {
  const MicrophonePermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.00032816489692777395, -0.9999995231628418),
            end: Alignment(0.9999995231628418, -0.0015423615695908666),
            colors: [
              AppColors.onboardingGradientStart,
              AppColors.onboardingGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: PlatformUtils.getDefaultPadding(context),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Spacer for image
                      const SizedBox(height: 120),
                      const SizedBox(height: 40),
                  // Title
                  Text(
                    'Allow Microphone Access',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Mara listens when you talk — so you can describe your symptoms naturally, just like talking to a friend. Your voice is processed safely on your device and never stored or shared.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Allow button
                  PrimaryButton(
                    text: 'Allow',
                    onPressed: () {
                      ref.read(permissionsProvider.notifier).setMicrophone(true);
                      context.push('/notifications-permission');
                    },
                  ),
                  const SizedBox(height: 16),
                  // Not now button
                  TextButton(
                    onPressed: () {
                      ref.read(permissionsProvider.notifier).setMicrophone(false);
                      context.push('/notifications-permission');
                    },
                    child: Text(
                      'Not now',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Privacy note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your privacy matters. your voice access stays local in your device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Microphone image centered horizontally at y330
              Positioned(
                left: (MediaQuery.of(context).size.width - 88) / 2,
                top: 330,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF0EA5C6).withOpacity(0.25),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/mic.png',
                    width: 88,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

