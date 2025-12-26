import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../l10n/app_localizations.dart';

/// Provider to check health permissions status.
final healthPermissionsStatusProvider = FutureProvider<bool>((ref) async {
  final healthDataService = ref.read(healthDataServiceProvider);
  return await healthDataService.hasPermissions();
});

/// Widget displaying health permissions status and management.
class HealthPermissionsSection extends ConsumerWidget {
  const HealthPermissionsSection({super.key});

  Future<void> _requestPermissions(BuildContext context, WidgetRef ref) async {
    final healthDataService = ref.read(healthDataServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    try {
      final granted = await healthDataService.requestPermissions();

      // Invalidate the provider to refresh status
      ref.invalidate(healthPermissionsStatusProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                  ? l10n.healthPermissionsGranted
                  : l10n.healthPermissionsNotGranted,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorRequestingPermissions),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openSystemSettings() async {
    if (Platform.isIOS) {
      // iOS: Open Health app settings
      final uri = Uri.parse('x-apple-health://');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to app settings
        final settingsUri = Uri.parse('app-settings:');
        if (await canLaunchUrl(settingsUri)) {
          await launchUrl(settingsUri);
        }
      }
    } else if (Platform.isAndroid) {
      // Android: Open app settings where user can manage permissions
      final settingsUri = Uri.parse('package:com.iammara.mara_app');
      if (await canLaunchUrl(settingsUri)) {
        await launchUrl(settingsUri);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final permissionsStatus = ref.watch(healthPermissionsStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            l10n.healthData,
            style: TextStyle(
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.languageButtonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.languageButtonColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PlatformUtils.isIOS
                              ? l10n.appleHealth
                              : l10n.googleFit,
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.textPrimary
                                : const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        permissionsStatus.when(
                          data: (hasPermissions) => Text(
                            hasPermissions ? l10n.connected : l10n.notConnected,
                            style: TextStyle(
                              color: hasPermissions
                                  ? Colors.green
                                  : (isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColors.textSecondary),
                              fontSize: 14,
                            ),
                          ),
                          loading: () => Text(
                            l10n.checking,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          error: (_, __) => Text(
                            l10n.unknown,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  permissionsStatus.when(
                    data: (hasPermissions) => Icon(
                      hasPermissions ? Icons.check_circle : Icons.cancel,
                      color: hasPermissions
                          ? Colors.green
                          : (isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary),
                      size: 24,
                    ),
                    loading: () => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => Icon(
                      Icons.error_outline,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              permissionsStatus.when(
                data: (hasPermissions) {
                  if (hasPermissions) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _openSystemSettings(),
                        icon: const Icon(Icons.settings, size: 18),
                        label: Text(l10n.manageInSettings),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _requestPermissions(context, ref),
                        icon: const Icon(Icons.link, size: 18),
                        label: Text(l10n.connect),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.languageButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  }
                },
                loading: () => const SizedBox(
                  width: double.infinity,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _requestPermissions(context, ref),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.languageButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
