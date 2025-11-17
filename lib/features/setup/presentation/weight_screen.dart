import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  String _selectedUnit = 'kg';
  int? _selectedWeight; // No default - user must choose

  void _handleContinue() {
    if (_selectedWeight != null && _selectedWeight! > 0) {
      ref.read(userProfileProvider.notifier).setWeight(_selectedWeight!, _selectedUnit);
      context.push('/blood-type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weights = _selectedUnit == 'kg'
        ? List.generate(61, (i) => 40 + i) // 40-100 kg
        : List.generate(133, (i) => 88 + i); // 88-220 lbs

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
                  "What's your weight?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Unit toggle
                Column(
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UnitToggle(
                      text: 'Kg',
                      isSelected: _selectedUnit == 'kg',
                      onTap: () {
                        setState(() {
                          _selectedUnit = 'kg';
                          _selectedWeight = null; // Reset selection when unit changes
                        });
                      },
                    ),
                        const SizedBox(width: 96),
                    _UnitToggle(
                      text: 'lb',
                      isSelected: _selectedUnit == 'lb',
                      onTap: () {
                        setState(() {
                          _selectedUnit = 'lb';
                          _selectedWeight = null; // Reset selection when unit changes
                        });
                      },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Blue line under unit selector
                    Container(
                      width: 176,
                      height: 2,
                      color: AppColors.languageButtonColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Weight picker
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 48,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: weights.length ~/ 2,
                    ),
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < weights.length) {
                        setState(() {
                          _selectedWeight = weights[index];
                        });
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= weights.length) return null;
                        final weight = weights[index];
                        final isSelected = weight == _selectedWeight;
                        return Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC4F4FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Text(
                            weight.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF10A9CC)
                                  : const Color(0xFF94A3B8).withOpacity(0.6),
                              fontSize: 20,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      childCount: weights.length,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: 'Continue',
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: (_selectedWeight != null && _selectedWeight! > 0) ? _handleContinue : null,
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

class _UnitToggle extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitToggle({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? AppColors.languageButtonColor
              : AppColors.textSecondary,
          fontSize: 26,
          fontWeight: FontWeight.normal,
          height: 1,
        ),
      ),
    );
  }
}

