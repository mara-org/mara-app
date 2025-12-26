import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';
import '../../../core/services/native_permission_service.dart';
import 'widgets/capability_activation_dialog.dart';
import '../../../l10n/app_localizations.dart';

class HealthDataPermissionScreen extends ConsumerWidget {
  const HealthDataPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.002758405404165387, -0.9999642372131348),
            end: const Alignment(0.9999642372131348, -0.012964393012225628),
            colors: isDark
                ? [
                    AppColorsDark.onboardingGradientStart,
                    AppColorsDark.onboardingGradientEnd,
                  ]
                : [
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
                              l10n.connectHealthData,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                l10n.healthDataDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColors.textSecondary,
                                  fontSize: 16,
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
                          // Connect button
                          PrimaryButton(
                            text: l10n.connectHealthData,
                            onPressed: () async {
                              // Request native health data permission (HealthKit/Google Fit)
                              final permissionService =
                                  NativePermissionService();
                              final granted = await permissionService
                                  .requestHealthDataPermission();

                              // Update provider state
                              ref
                                  .read(permissionsProvider.notifier)
                                  .setHealthData(granted);

                              // Show capability activation dialog if granted
                              if (granted && context.mounted) {
                                await CapabilityActivationDialog.show(
                                  context: context,
                                  title: l10n.healthKitActivated,
                                  message: l10n.healthKitActivatedMessage,
                                  onContinue: () {
                                    if (context.mounted) {
                                      context.push('/permissions-summary');
                                    }
                                  },
                                );
                              } else if (context.mounted) {
                                // Navigate to next screen if not granted
                                context.push('/permissions-summary');
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Not now button
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(permissionsProvider.notifier)
                                  .setHealthData(false);
                              context.push('/permissions-summary');
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
                              l10n.stayConnectedToYourHealth,
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
              // Health data image centered horizontally at y288
              Positioned(
                left: (MediaQuery.of(context).size.width - 100) / 2,
                top: 288,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF0EA5C6).withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/monitor_heart.png',
                    width: 100,
                    height: 80,
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
