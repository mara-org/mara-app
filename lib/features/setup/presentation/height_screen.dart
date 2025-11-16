import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';

class HeightScreen extends ConsumerStatefulWidget {
  const HeightScreen({super.key});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  String _selectedUnit = 'cm';
  int? _selectedHeight; // No default - user must choose

  void _handleContinue() {
    if (_selectedHeight != null && _selectedHeight! > 0) {
      ref.read(userProfileProvider.notifier).setHeight(_selectedHeight!, _selectedUnit);
      context.push('/weight');
    }
  }

  @override
  Widget build(BuildContext context) {
    final heights = _selectedUnit == 'cm'
        ? List.generate(61, (i) => 150 + i) // 150-210 cm
        : List.generate(25, (i) => 59 + i); // 59-83 inches

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
                  "What's your height?",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UnitToggle(
                      text: 'cm',
                      isSelected: _selectedUnit == 'cm',
                      onTap: () {
                        setState(() {
                          _selectedUnit = 'cm';
                          _selectedHeight = null; // Reset selection when unit changes
                        });
                      },
                    ),
                    const SizedBox(width: 40),
                    _UnitToggle(
                      text: 'in',
                      isSelected: _selectedUnit == 'in',
                      onTap: () {
                        setState(() {
                          _selectedUnit = 'in';
                          _selectedHeight = null; // Reset selection when unit changes
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Height picker
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: heights.length ~/ 2,
                    ),
                    onSelectedItemChanged: (index) {
                      if (index >= 0 && index < heights.length) {
                        setState(() {
                          _selectedHeight = heights[index];
                        });
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= heights.length) return null;
                        final height = heights[index];
                        final isSelected = height == _selectedHeight;
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.languageButtonColor.withOpacity(0.4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Text(
                            height.toString(),
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
                      childCount: heights.length,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: 'Continue',
                  onPressed: (_selectedHeight != null && _selectedHeight! > 0) ? _handleContinue : null,
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

