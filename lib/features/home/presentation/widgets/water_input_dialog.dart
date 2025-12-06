import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/health/daily_water_intake_entry.dart';
import '../../../../core/providers/health_tracking_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../l10n/app_localizations.dart';

/// Dialog for logging water intake.
class WaterInputDialog extends ConsumerStatefulWidget {
  const WaterInputDialog({super.key});

  @override
  ConsumerState<WaterInputDialog> createState() => _WaterInputDialogState();
}

class _WaterInputDialogState extends ConsumerState<WaterInputDialog> {
  final TextEditingController _litersController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _litersController.dispose();
    super.dispose();
  }

  Future<void> _addGlass(double liters) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Get today's current water intake if it exists
      final repository = ref.read(healthTrackingRepositoryProvider);
      final todayWater = await repository.getTodayWater();
      
      final currentLiters = todayWater?.waterLiters ?? 0.0;
      final newTotal = currentLiters + liters;

      final entry = DailyWaterIntakeEntry.today(newTotal);
      await repository.saveWaterIntakeEntry(entry);

      // Refresh the provider
      ref.invalidate(todayWaterProvider);

      if (mounted) {
        Navigator.of(context).pop();
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
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveManualLiters() async {
    final litersText = _litersController.text.trim();
    if (litersText.isEmpty) {
      return;
    }

    final liters = double.tryParse(litersText);
    if (liters == null || liters < 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final entry = DailyWaterIntakeEntry.today(liters);
      final repository = ref.read(healthTrackingRepositoryProvider);
      await repository.saveWaterIntakeEntry(entry);

      // Refresh the provider
      ref.invalidate(todayWaterProvider);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.healthDataSaved),
            duration: const Duration(seconds: 2),
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.logWaterIntake,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.howMuchWaterDidYouDrink,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Quick add glass button
            OutlinedButton.icon(
              onPressed: _isSaving ? null : () => _addGlass(0.25),
              icon: const Icon(Icons.water_drop),
              label: Text(l10n.oneGlass),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Divider with "or"
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
              ],
            ),
            const SizedBox(height: 16),
            // Manual input
            TextField(
              controller: _litersController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: l10n.liters,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.water_drop),
              ),
              autofocus: false,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: l10n.cancel,
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: l10n.save,
                    onPressed: _isSaving ? null : _saveManualLiters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

