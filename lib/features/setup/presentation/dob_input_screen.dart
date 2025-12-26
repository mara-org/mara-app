import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

class DobInputScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;

  const DobInputScreen({super.key, this.isFromProfile = false});

  @override
  ConsumerState<DobInputScreen> createState() => _DobInputScreenState();
}

class _DobInputScreenState extends ConsumerState<DobInputScreen> {
  static const int _minYear = 1900;
  static const List<int> _allMonths = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  late final DateTime _maxAllowedDate;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _maxAllowedDate = DateTime(now.year - 13, now.month, now.day);
    final maxYear = _maxAllowedDate.year;
    if (maxYear >= _minYear) {
      _years = List.generate(maxYear - _minYear + 1, (i) => _minYear + i);
    } else {
      _years = [_minYear];
    }
    _yearController = FixedExtentScrollController();
    _monthController = FixedExtentScrollController();
    _dayController = FixedExtentScrollController();

    // Set default year to 1999
    final defaultYear = 1999;
    final initialYear =
        _years.contains(defaultYear) ? defaultYear : _years.last;
    final yearIndex = _years.indexOf(initialYear);
    if (yearIndex != -1) {
      _selectedYear = initialYear;
      // Scroll to 1999 after the first frame is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_yearController.hasClients) {
          _yearController.jumpToItem(yearIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedYear == null ||
        _selectedMonth == null ||
        _selectedDay == null) {
      return;
    }
    try {
      final dateOfBirth = DateTime(
        _selectedYear!,
        _selectedMonth!,
        _selectedDay!,
      );
      if (!dateOfBirth.isAfter(_maxAllowedDate)) {
        ref.read(userProfileProvider.notifier).setDateOfBirth(dateOfBirth);
        if (widget.isFromProfile) {
          context.go('/profile');
        } else {
          context.push('/gender');
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectValidDate)));
      }
    } catch (e) {
      // Invalid date (e.g., Feb 30)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectValidDate)));
    }
  }

  bool get _canContinue =>
      _selectedYear != null && _selectedMonth != null && _selectedDay != null;

  List<int> get _validDays {
    if (_selectedYear == null || _selectedMonth == null) {
      return [];
    }
    final isMaxYear = _selectedYear == _maxAllowedDate.year;
    final isMaxMonth = isMaxYear && _selectedMonth == _maxAllowedDate.month;
    final daysInMonth = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    final allowedDays = isMaxMonth ? _maxAllowedDate.day : daysInMonth;
    return List.generate(allowedDays, (i) => i + 1);
  }

  List<int> get _monthOptions {
    if (_selectedYear == null) {
      return _allMonths;
    }
    final isMaxYear = _selectedYear == _maxAllowedDate.year;
    final maxMonth = isMaxYear ? _maxAllowedDate.month : 12;
    if (maxMonth == 12) {
      return _allMonths;
    }
    return _allMonths.take(maxMonth).toList();
  }

  void _resetMonthAndDayScroll() {
    if (_monthController.hasClients) {
      _monthController.jumpToItem(0);
    }
    if (_dayController.hasClients) {
      _dayController.jumpToItem(0);
    }
  }

  void _resetDayScroll() {
    if (_dayController.hasClients) {
      _dayController.jumpToItem(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthOptions = _monthOptions;
    final validDays = _validDays;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Back button
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.languageButtonColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.languageButtonColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mara logo
                const Center(child: MaraLogo(width: 140, height: 99)),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.whenWereYouBorn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Date pickers in a row (Year first, then Month, then Day)
                Row(
                  children: [
                    // Year picker (must be selected first)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.year,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              diameterRatio: 1.5,
                              physics: const FixedExtentScrollPhysics(),
                              controller: _yearController,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedYear = _years[index];
                                  // Reset month and day when year changes
                                  _selectedMonth = null;
                                  _selectedDay = null;
                                });
                                _resetMonthAndDayScroll();
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _years.length)
                                    return null;
                                  final year = _years[index];
                                  final isSelected = year == _selectedYear;
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.languageButtonColor
                                              .withOpacity(0.4)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    child: Text(
                                      year.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                            : (isDark
                                                    ? AppColorsDark
                                                        .textSecondary
                                                    : AppColors.textSecondary)
                                                .withOpacity(0.66),
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                                childCount: _years.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Month picker (enabled only after year is selected)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.month,
                            style: TextStyle(
                              color: _selectedYear != null
                                  ? (isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColors.textSecondary)
                                  : (isDark
                                          ? AppColorsDark.textSecondary
                                          : AppColors.textSecondary)
                                      .withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              diameterRatio: 1.5,
                              physics: _selectedYear != null
                                  ? const FixedExtentScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              controller: _monthController,
                              onSelectedItemChanged: _selectedYear != null
                                  ? (index) {
                                      setState(() {
                                        _selectedMonth = monthOptions[index];
                                        // Reset day when month changes
                                        _selectedDay = null;
                                      });
                                      _resetDayScroll();
                                    }
                                  : null,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 ||
                                      index >= monthOptions.length) {
                                    return null;
                                  }
                                  final month = monthOptions[index];
                                  final isSelected = month == _selectedMonth;
                                  final isEnabled = _selectedYear != null;
                                  return Opacity(
                                    opacity: isEnabled ? 1.0 : 0.5,
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                                .withOpacity(0.4)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                      child: Text(
                                        month.toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.languageButtonColor
                                              : (isDark
                                                      ? AppColorsDark
                                                          .textSecondary
                                                      : AppColors.textSecondary)
                                                  .withOpacity(0.66),
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: monthOptions.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Day picker (enabled only after year and month are selected)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.day,
                            style: TextStyle(
                              color: _selectedYear != null &&
                                      _selectedMonth != null
                                  ? (isDark
                                      ? AppColorsDark.textSecondary
                                      : AppColors.textSecondary)
                                  : (isDark
                                          ? AppColorsDark.textSecondary
                                          : AppColors.textSecondary)
                                      .withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              diameterRatio: 1.5,
                              physics: _selectedYear != null &&
                                      _selectedMonth != null
                                  ? const FixedExtentScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              controller: _dayController,
                              onSelectedItemChanged: _selectedYear != null &&
                                      _selectedMonth != null
                                  ? (index) {
                                      setState(() {
                                        final days = _validDays;
                                        if (index >= 0 && index < days.length) {
                                          _selectedDay = days[index];
                                        }
                                      });
                                    }
                                  : null,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= validDays.length) {
                                    return null;
                                  }
                                  final day = validDays[index];
                                  final isSelected = day == _selectedDay;
                                  final isEnabled = _selectedYear != null &&
                                      _selectedMonth != null;
                                  return Opacity(
                                    opacity: isEnabled ? 1.0 : 0.5,
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                                .withOpacity(0.4)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(19),
                                      ),
                                      child: Text(
                                        day.toString(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.languageButtonColor
                                              : (isDark
                                                      ? AppColorsDark
                                                          .textSecondary
                                                      : AppColors.textSecondary)
                                                  .withOpacity(0.66),
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: validDays.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Continue button (disabled until all three are selected)
                PrimaryButton(
                  text: l10n.continueButtonText,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: _canContinue ? _handleContinue : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
