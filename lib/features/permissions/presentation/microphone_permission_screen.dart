import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';
import '../../../core/services/native_permission_service.dart';
import '../../../l10n/app_localizations.dart';

class MicrophonePermissionScreen extends ConsumerWidget {
  const MicrophonePermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                              l10n.allowMicrophoneAccess,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                l10n.microphoneAccessDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buttons section - fixed at bottom with consistent height
                  SizedBox(
                    height:
                        220, // Fixed height to ensure buttons are at same position
                    child: Padding(
                      padding: PlatformUtils.getDefaultPadding(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Allow button
                          PrimaryButton(
                            text: l10n.allow,
                            onPressed: () async {
                              // Request native microphone permission
                              final permissionService =
                                  NativePermissionService();
                              final granted = await permissionService
                                  .requestMicrophonePermission();

                              // Update provider state
                              ref
                                  .read(permissionsProvider.notifier)
                                  .setMicrophone(granted);

                              // Navigate to next screen
                              if (context.mounted) {
                                context.push('/notifications-permission');
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Not now button
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(permissionsProvider.notifier)
                                  .setMicrophone(false);
                              context.push('/notifications-permission');
                            },
                            child: Text(
                              l10n.notNow,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Privacy note
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              l10n.microphonePermissionPrivacy,
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
                ],
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
