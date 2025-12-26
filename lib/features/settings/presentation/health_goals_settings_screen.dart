import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/health/health_goals.dart';
import '../../../core/providers/health_goals_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../l10n/app_localizations.dart';

/// Screen for editing health goals with beautiful scrollable pickers.
class HealthGoalsSettingsScreen extends ConsumerStatefulWidget {
  const HealthGoalsSettingsScreen({super.key});

  @override
  ConsumerState<HealthGoalsSettingsScreen> createState() =>
      _HealthGoalsSettingsScreenState();
}

class _HealthGoalsSettingsScreenState
    extends ConsumerState<HealthGoalsSettingsScreen> {
  // Steps: 1000 to 30000, increments of 500
  late final List<int> _stepsOptions;
  late final FixedExtentScrollController _stepsController;
  int? _selectedSteps;

  // Sleep: 4.0 to 12.0 hours, increments of 0.5
  late final List<double> _sleepOptions;
  late final FixedExtentScrollController _sleepController;
  double? _selectedSleep;

  // Water: 1.0 to 5.0 liters, increments of 0.25
  late final List<double> _waterOptions;
  late final FixedExtentScrollController _waterController;
  double? _selectedWater;

  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize steps options: 1000 to 30000, step 500
    _stepsOptions = List.generate(
      59,
      (index) => 1000 + (index * 500),
    );
    _stepsController = FixedExtentScrollController();

    // Initialize sleep options: 4.0 to 12.0, step 0.5
    _sleepOptions = List.generate(
      17,
      (index) => 4.0 + (index * 0.5),
    );
    _sleepController = FixedExtentScrollController();

    // Initialize water options: 1.0 to 5.0, step 0.25
    _waterOptions = List.generate(
      17,
      (index) => 1.0 + (index * 0.25),
    );
    _waterController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _sleepController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _initializeFromGoals(HealthGoals goals) {
    if (_initialized) return;
    _initialized = true;

    // Set steps
    final stepsIndex = _stepsOptions.indexOf(goals.dailyStepsGoal);
    if (stepsIndex >= 0) {
      _selectedSteps = goals.dailyStepsGoal;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stepsController.jumpToItem(stepsIndex);
      });
    } else {
      // Find closest value
      int closestIndex = 0;
      int minDiff = (goals.dailyStepsGoal - _stepsOptions[0]).abs();
      for (int i = 1; i < _stepsOptions.length; i++) {
        final diff = (goals.dailyStepsGoal - _stepsOptions[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
      _selectedSteps = _stepsOptions[closestIndex];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stepsController.jumpToItem(closestIndex);
      });
    }

    // Set sleep
    final sleepIndex = _sleepOptions.indexOf(goals.dailySleepGoal);
    if (sleepIndex >= 0) {
      _selectedSleep = goals.dailySleepGoal;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sleepController.jumpToItem(sleepIndex);
      });
    } else {
      // Find closest value
      int closestIndex = 0;
      double minDiff = (goals.dailySleepGoal - _sleepOptions[0]).abs();
      for (int i = 1; i < _sleepOptions.length; i++) {
        final diff = (goals.dailySleepGoal - _sleepOptions[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
      _selectedSleep = _sleepOptions[closestIndex];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sleepController.jumpToItem(closestIndex);
      });
    }

    // Set water
    final waterIndex = _waterOptions.indexOf(goals.dailyWaterGoal);
    if (waterIndex >= 0) {
      _selectedWater = goals.dailyWaterGoal;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _waterController.jumpToItem(waterIndex);
      });
    } else {
      // Find closest value
      int closestIndex = 0;
      double minDiff = (goals.dailyWaterGoal - _waterOptions[0]).abs();
      for (int i = 1; i < _waterOptions.length; i++) {
        final diff = (goals.dailyWaterGoal - _waterOptions[i]).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = i;
        }
      }
      _selectedWater = _waterOptions[closestIndex];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _waterController.jumpToItem(closestIndex);
      });
    }
  }

  Future<void> _saveGoals() async {
    if (_selectedSteps == null ||
        _selectedSleep == null ||
        _selectedWater == null) {
      _showError('Please select all goals');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final goals = HealthGoals(
      dailyStepsGoal: _selectedSteps!,
      dailySleepGoal: _selectedSleep!,
      dailyWaterGoal: _selectedWater!,
      lastUpdatedAt: DateTime.now(),
    );

    final saved = await ref.read(
      updateHealthGoalsProvider(goals).future,
    );

    setState(() {
      _isSaving = false;
    });

    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.goalsSaved),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      _showError(AppLocalizations.of(context)!.errorSavingGoals);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(healthGoalsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(l10n.healthGoals),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
      ),
      body: goalsAsync.when(
        data: (goals) {
          _initializeFromGoals(goals);

          return SingleChildScrollView(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.setDailyGoals,
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                // Steps goal picker
                _GoalPickerSection(
                  title: l10n.dailyStepsGoal,
                  icon: Icons.directions_walk,
                  isDark: isDark,
                  child: SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: _stepsController,
                      onSelectedItemChanged: (index) {
                        if (index >= 0 && index < _stepsOptions.length) {
                          setState(() {
                            _selectedSteps = _stepsOptions[index];
                          });
                        }
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= _stepsOptions.length) {
                            return null;
                          }
                          final steps = _stepsOptions[index];
                          final isSelected = steps == _selectedSteps;
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${steps.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  )} ${l10n.steps}',
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.languageButtonColor
                                    : (isDark
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          );
                        },
                        childCount: _stepsOptions.length,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Sleep goal picker
                _GoalPickerSection(
                  title: l10n.dailySleepGoal,
                  icon: Icons.bedtime,
                  isDark: isDark,
                  child: SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: _sleepController,
                      onSelectedItemChanged: (index) {
                        if (index >= 0 && index < _sleepOptions.length) {
                          setState(() {
                            _selectedSleep = _sleepOptions[index];
                          });
                        }
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= _sleepOptions.length) {
                            return null;
                          }
                          final sleep = _sleepOptions[index];
                          final isSelected = sleep == _selectedSleep;
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${sleep.toStringAsFixed(1)} ${l10n.hours}',
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.languageButtonColor
                                    : (isDark
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          );
                        },
                        childCount: _sleepOptions.length,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Water goal picker
                _GoalPickerSection(
                  title: l10n.dailyWaterGoal,
                  icon: Icons.water_drop,
                  isDark: isDark,
                  child: SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: _waterController,
                      onSelectedItemChanged: (index) {
                        if (index >= 0 && index < _waterOptions.length) {
                          setState(() {
                            _selectedWater = _waterOptions[index];
                          });
                        }
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= _waterOptions.length) {
                            return null;
                          }
                          final water = _waterOptions[index];
                          final isSelected = water == _selectedWater;
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              '${water.toStringAsFixed(2)} ${l10n.liters}',
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.languageButtonColor
                                    : (isDark
                                        ? AppColorsDark.textSecondary
                                        : AppColors.textSecondary),
                              ),
                            ),
                          );
                        },
                        childCount: _waterOptions.length,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.languageButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            l10n.saveGoals,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.languageButtonColor,
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error loading goals: $error',
              style: TextStyle(
                color:
                    isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Beautiful section widget for each goal picker.
class _GoalPickerSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Widget child;

  const _GoalPickerSection({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColorsDark.borderColor
              : AppColors.borderColor.withOpacity( 0.3),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  color: AppColors.languageButtonColor.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.languageButtonColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
