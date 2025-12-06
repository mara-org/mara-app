import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/health_tracking_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/main_bottom_navigation.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/sleep_chart.dart';
import 'widgets/steps_chart.dart';
import 'widgets/water_chart.dart';

class AnalystDashboardScreen extends ConsumerStatefulWidget {
  const AnalystDashboardScreen({super.key});

  @override
  ConsumerState<AnalystDashboardScreen> createState() => _AnalystDashboardScreenState();
}

class _AnalystDashboardScreenState extends ConsumerState<AnalystDashboardScreen> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Get more entries than needed to filter by date range
    final stepsHistory = ref.watch(stepsHistoryProvider(_selectedDays * 2));
    final sleepHistory = ref.watch(sleepHistoryProvider(_selectedDays * 2));
    final waterHistory = ref.watch(waterHistoryProvider(_selectedDays * 2));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.backgroundLight
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const MaraLogo(width: 32, height: 32),
            const SizedBox(width: 12),
            Text(l10n.analystDashboard),
          ],
        ),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Time period selector
                Row(
                  children: [
                    Expanded(
                      child: _TimePeriodButton(
                        label: l10n.last7Days,
                        days: 7,
                        isSelected: _selectedDays == 7,
                        onTap: () => setState(() => _selectedDays = 7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimePeriodButton(
                        label: l10n.last30Days,
                        days: 30,
                        isSelected: _selectedDays == 30,
                        onTap: () => setState(() => _selectedDays = 30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Steps section
                stepsHistory.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return _EmptyState(
                        title: l10n.stepsTrend,
                        message: l10n.noHealthDataAvailable,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.stepsTrend,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.averageSteps}: ${_calculateAverageSteps(entries).toStringAsFixed(0)}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StepsChart(entries: entries, days: _selectedDays),
                      ],
                    );
                  },
                  loading: () => const _LoadingState(title: 'Steps'),
                  error: (err, stack) => _ErrorState(title: 'Steps'),
                ),
                const SizedBox(height: 32),
                // Sleep section
                sleepHistory.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return _EmptyState(
                        title: l10n.sleepTrend,
                        message: l10n.noHealthDataAvailable,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sleepTrend,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.averageSleep}: ${_calculateAverageSleep(entries).toStringAsFixed(1)}${l10n.hoursAbbreviation}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SleepChart(entries: entries, days: _selectedDays),
                      ],
                    );
                  },
                  loading: () => const _LoadingState(title: 'Sleep'),
                  error: (err, stack) => _ErrorState(title: 'Sleep'),
                ),
                const SizedBox(height: 32),
                // Water section
                waterHistory.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return _EmptyState(
                        title: l10n.waterTrend,
                        message: l10n.noHealthDataAvailable,
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.waterTrend,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.averageWater}: ${_calculateAverageWater(entries).toStringAsFixed(1)}${l10n.litersAbbreviation}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        WaterChart(entries: entries, days: _selectedDays),
                      ],
                    );
                  },
                  loading: () => const _LoadingState(title: 'Water'),
                  error: (err, stack) => _ErrorState(title: 'Water'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 1),
    );
  }

  double _calculateAverageSteps(List<dynamic> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<double>(0.0, (sum, entry) => sum + entry.steps.toDouble());
    return sum / entries.length;
  }

  double _calculateAverageSleep(List<dynamic> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<double>(0, (sum, entry) => sum + entry.hours);
    return sum / entries.length;
  }

  double _calculateAverageWater(List<dynamic> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<double>(0, (sum, entry) => sum + entry.waterLiters);
    return sum / entries.length;
  }
}

class _TimePeriodButton extends StatelessWidget {
  final String label;
  final int days;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimePeriodButton({
    required this.label,
    required this.days,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.languageButtonColor
              : AppColors.permissionCardBackground,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.permissionCardBackground,
          ),
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String title;

  const _LoadingState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.permissionCardBackground,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String title;

  const _ErrorState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.permissionCardBackground,
          ),
          child: Center(
            child: Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
          ),
        ),
      ],
    );
  }
}
