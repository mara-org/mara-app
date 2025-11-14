import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';

class DobInputScreen extends ConsumerStatefulWidget {
  const DobInputScreen({super.key});

  @override
  ConsumerState<DobInputScreen> createState() => _DobInputScreenState();
}

class _DobInputScreenState extends ConsumerState<DobInputScreen> {
  int _selectedDay = 15;
  int _selectedMonth = 6;
  late int _selectedYear;
  late FixedExtentScrollController _yearController;

  final List<int> _days = List.generate(31, (i) => i + 1); // 1-31
  final List<int> _months = List.generate(12, (i) => i + 1); // 1-12
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(currentYear - 1899, (i) => 1900 + i); // 1900 to current year
    final defaultYearIndex = _years.length ~/ 2;
    _selectedYear = _years[defaultYearIndex]; // Default to middle year
    _yearController = FixedExtentScrollController(initialItem: defaultYearIndex);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    try {
      final dateOfBirth = DateTime(_selectedYear, _selectedMonth, _selectedDay);
      if (dateOfBirth.isBefore(DateTime.now())) {
        ref.read(userProfileProvider.notifier).setDateOfBirth(dateOfBirth);
        context.go('/gender');
      }
    } catch (e) {
      // Invalid date (e.g., Feb 30)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid date'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  alignment: Alignment.centerLeft,
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
                // Title
                Text(
                  'When were you born?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Date pickers in a row
                Row(
                  children: [
                    // Day picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Day',
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
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedDay = _days[index];
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _days.length) return null;
                                  final day = _days[index];
                                  final isSelected = day == _selectedDay;
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.languageButtonColor.withOpacity(0.4)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    child: Text(
                                      day.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                            : AppColors.textSecondary.withOpacity(0.66),
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                                childCount: _days.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Month picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Month',
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
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedMonth = _months[index];
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _months.length) return null;
                                  final month = _months[index];
                                  final isSelected = month == _selectedMonth;
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.languageButtonColor.withOpacity(0.4)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    child: Text(
                                      month.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                            : AppColors.textSecondary.withOpacity(0.66),
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
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
                    // Year picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Year',
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
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  if (index < 0 || index >= _years.length) return null;
                                  final year = _years[index];
                                  final isSelected = year == _selectedYear;
                                  return Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.languageButtonColor.withOpacity(0.4)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    child: Text(
                                      year.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.languageButtonColor
                                            : AppColors.textSecondary.withOpacity(0.66),
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
                  ],
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _handleContinue,
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

