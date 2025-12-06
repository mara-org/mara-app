import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/health/daily_sleep_entry.dart';
import '../../../../core/providers/health_tracking_providers.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/secondary_button.dart';

/// Dialog for syncing sleep data from HealthKit/Google Fit only.
/// Users cannot manually add sleep data - only sync from device.
class SleepInputDialog extends ConsumerStatefulWidget {
  const SleepInputDialog({super.key});

  @override
  ConsumerState<SleepInputDialog> createState() => _SleepInputDialogState();
}

class _SleepInputDialogState extends ConsumerState<SleepInputDialog> {
  bool _isSyncing = false;

  Future<void> _syncFromDevice() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final healthDataService = ref.read(healthDataServiceProvider);
      final l10n = AppLocalizations.of(context)!;

      // Check permissions first
      final hasPermissions = await healthDataService.hasPermissions();
      if (!hasPermissions) {
        // Request permissions
        final granted = await healthDataService.requestPermissions();
        if (!granted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.healthPermissionsNotGranted),
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() {
            _isSyncing = false;
          });
          return;
        }
      }

      // Get sleep data from HealthKit/Google Fit
      final sleepHours = await healthDataService.getTodaySleepHours();

      if (sleepHours != null && sleepHours > 0) {
        // Save to local storage
        final entry = DailySleepEntry.today(sleepHours);
        final repository = ref.read(healthTrackingRepositoryProvider);
        await repository.saveSleepEntry(entry);

        // Refresh the provider
        ref.invalidate(todaySleepProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.healthDataSaved),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noSleepDataAvailable),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingHealthData),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.syncSleepFromDevice,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.sleepDataFromDeviceOnly,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColorsDark.textSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Info icon and message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.languageButtonColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.languageButtonColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.languageButtonColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.sleepDataSyncOnlyMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColorsDark.textSecondary
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Sync from device button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncFromDevice,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isSyncing ? l10n.syncing : l10n.syncFromDevice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.languageButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: l10n.cancel,
              onPressed: _isSyncing ? null : () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
