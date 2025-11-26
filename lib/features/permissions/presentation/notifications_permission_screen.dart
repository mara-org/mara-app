import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsPermissionScreen extends ConsumerWidget {
  const NotificationsPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0008150712819769979, -0.9999969005584717),
            end: Alignment(0.9999969005584717, 0.003830801695585251),
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
                              l10n.enableNotifications,
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
                                l10n.notificationsDescription,
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
                    height: 220, // Fixed height to ensure buttons are at same position
                    child: Padding(
                      padding: PlatformUtils.getDefaultPadding(context),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Allow button
                          PrimaryButton(
                            text: l10n.allowNotifications,
                            onPressed: () {
                              ref.read(permissionsProvider.notifier).setNotifications(true);
                              context.push('/health-data-permission');
                            },
                          ),
                          const SizedBox(height: 16),
                          // Not now button
                          TextButton(
                            onPressed: () {
                              ref.read(permissionsProvider.notifier).setNotifications(false);
                              context.push('/health-data-permission');
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
                          // Spacer to match privacy note height on other screens
                          const SizedBox(height: 32),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Notifications image centered horizontally at y288
              Positioned(
                left: (MediaQuery.of(context).size.width - 167) / 2,
                top: 288,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF0EA5C6).withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/notifications_active.png',
                    width: 167,
                    height: 167,
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

