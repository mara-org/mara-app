import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';

class CameraPermissionScreen extends ConsumerWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cameraPermissionBackground,
      body: SafeArea(
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
                  'Allow Camera Access',
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
                    'Mara uses your camera to help analyze your facial expressions, detect fatigue, and support your well-being — directly on your device. No videos or images are stored or shared. Ever.',
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
                    ref.read(permissionsProvider.notifier).setCamera(true);
                    context.push('/microphone-permission');
                  },
                ),
                const SizedBox(height: 16),
                // Not now button
                TextButton(
                  onPressed: () {
                    ref.read(permissionsProvider.notifier).setCamera(false);
                    context.push('/microphone-permission');
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
                    'Your privacy matters. Camera access stays local to your device.',
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
            // Camera image centered horizontally at y327
            Positioned(
              left: (MediaQuery.of(context).size.width - 133) / 2,
              top: 327,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  const Color(0xFF0EA5C6).withOpacity(0.4),
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/photo_camera.png',
                  width: 133,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

