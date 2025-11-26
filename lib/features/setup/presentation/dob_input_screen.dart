import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
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
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  final List<int> _months = List.generate(12, (i) => i + 1); // 1-12
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(
        currentYear - 1899, (i) => 1900 + i); // 1900 to current year
    _yearController = FixedExtentScrollController();
    _monthController = FixedExtentScrollController();
    _dayController = FixedExtentScrollController();
    
    // Set default year to 1999
    final defaultYear = 1999;
    final yearIndex = _years.indexOf(defaultYear);
    if (yearIndex != -1) {
      _selectedYear = defaultYear;
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
      final dateOfBirth =
          DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
      if (dateOfBirth.isBefore(DateTime.now())) {
        ref.read(userProfileProvider.notifier).setDateOfBirth(dateOfBirth);
        if (widget.isFromProfile) {
          context.go('/profile');
        } else {
        context.push('/gender');
        }
      }
    } catch (e) {
      // Invalid date (e.g., Feb 30)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectValidDate),
        ),
      );
    }
  }

  bool get _canContinue =>
      _selectedYear != null && _selectedMonth != null && _selectedDay != null;
  
  List<int> get _validDays {
    if (_selectedYear == null || _selectedMonth == null) {
      return [];
    }
    final daysInMonth = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    return List.generate(daysInMonth, (i) => i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                const Center(
                  child: MaraLogo(
                    width: 258,
                    height: 202,
                  ),
                ),
                const SizedBox(height: 40),
                // Title (moved 4px to the right from previous position)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 1),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.whenWereYouBorn,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.languageButtonColor,
                        fontSize: 26,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
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
                              color: AppColors.textSecondary,
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
                                            : AppColors.textSecondary
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
                                  ? AppColors.textSecondary 
                                  : AppColors.textSecondary.withOpacity(0.5),
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
                                        _selectedMonth = _months[index];
                                        // Reset day when month changes
                                        _selectedDay = null;
                                      });
                                    }
                                  : null,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _months.length)
                                    return null;
                                  final month = _months[index];
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
                                              : AppColors.textSecondary
                                                  .withOpacity(0.66),
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: _months.length,
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
                                  ? AppColors.textSecondary 
                                  : AppColors.textSecondary.withOpacity(0.5),
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
                                        final validDays = _validDays;
                                        if (index >= 0 &&
                                            index < validDays.length) {
                                          _selectedDay = validDays[index];
                                        }
                                      });
                                    }
                                  : null,
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final validDays = _validDays;
                                  if (index < 0 || index >= validDays.length)
                                    return null;
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
                                              : AppColors.textSecondary
                                                  .withOpacity(0.66),
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: _validDays.length,
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
