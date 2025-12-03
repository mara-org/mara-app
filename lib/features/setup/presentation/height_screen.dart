import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

class HeightScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;

  const HeightScreen({super.key, this.isFromProfile = false});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  String _selectedUnit = 'cm';
  int? _selectedHeight; // No default - user must choose

  void _handleContinue() {
    if (_selectedHeight != null && _selectedHeight! > 0) {
      ref
          .read(userProfileProvider.notifier)
          .setHeight(_selectedHeight!, _selectedUnit);
      if (widget.isFromProfile) {
        context.go('/profile');
      } else {
        context.push('/weight');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                const Center(child: MaraLogo(width: 258, height: 202)),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.whatsYourHeight,
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
                          text: l10n.cm,
                          isSelected: _selectedUnit == 'cm',
                          onTap: () {
                            setState(() {
                              _selectedUnit = 'cm';
                              _selectedHeight =
                                  null; // Reset selection when unit changes
                            });
                          },
                        ),
                        const SizedBox(width: 96),
                        _UnitToggle(
                          text: l10n.inchUnit,
                          isSelected: _selectedUnit == 'in',
                          onTap: () {
                            setState(() {
                              _selectedUnit = 'in';
                              _selectedHeight =
                                  null; // Reset selection when unit changes
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
                // Height picker
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 48,
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
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFC4F4FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Text(
                            height.toString(),
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
                      childCount: heights.length,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: l10n.continueButtonText,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: (_selectedHeight != null && _selectedHeight! > 0)
                      ? _handleContinue
                      : null,
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
