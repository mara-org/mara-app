import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';
import '../../../core/services/native_permission_service.dart';
import '../../../l10n/app_localizations.dart';

class CameraPermissionScreen extends ConsumerWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.cameraPermissionBackground
          : AppColors.cameraPermissionBackground,
      body: SafeArea(
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
                            l10n.allowCameraAccess,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textPrimary
                                  : AppColors.textPrimary,
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
                              l10n.cameraAccessDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? AppColorsDark.textSecondary
                                    : AppColors.textSecondary,
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
                            // Request native camera permission
                            final permissionService = NativePermissionService();
                            final granted = await permissionService
                                .requestCameraPermission();

                            // Update provider state
                            ref
                                .read(permissionsProvider.notifier)
                                .setCamera(granted);

                            // Navigate to next screen
                            if (context.mounted) {
                              context.push('/microphone-permission');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Not now button
                        TextButton(
                          onPressed: () {
                            ref
                                .read(permissionsProvider.notifier)
                                .setCamera(false);
                            context.push('/microphone-permission');
                          },
                          child: Text(
                            l10n.notNow,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
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
                            l10n.cameraPermissionPrivacy,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColors.textSecondary)
                                  .withOpacity( 0.7),
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
