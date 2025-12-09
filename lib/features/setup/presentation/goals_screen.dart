import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;

  const GoalsScreen({super.key, this.isFromProfile = false});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String? _selectedGoal;

  List<Map<String, String>> _getGoals(AppLocalizations l10n) {
    return [
      {'emoji': '🏃‍♂️', 'text': l10n.stayActive},
      {'emoji': '😌', 'text': l10n.reduceStress},
      {'emoji': '💤', 'text': l10n.sleepBetter},
      {'emoji': '❤️', 'text': l10n.trackMyHealth},
    ];
  }

  void _handleContinue() {
    if (_selectedGoal != null) {
      ref.read(userProfileProvider.notifier).setMainGoal(_selectedGoal!);
      if (widget.isFromProfile) {
        context.go('/profile');
      } else {
        context.push('/welcome-personal');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.backgroundLight
          : AppColors.backgroundLight,
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
                        color: AppColors.languageButtonColor.withValues(
                            alpha: 0.1),
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
                  l10n.whatsYourMainHealthGoal,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Goals list
                ..._getGoals(l10n).map((goal) {
                  final goalText = '${goal['emoji']} ${goal['text']}';
                  final isSelected = _selectedGoal == goal['text'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GoalButton(
                      text: goalText,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal['text'];
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: l10n.continueButtonText,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: _selectedGoal != null ? _handleContinue : null,
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

class _GoalButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalButton({
    required this.text,
    required this.isSelected,
    this.isDark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.languageButtonColor.withValues(alpha: 0.2)
              : (isDark ? AppColorsDark.cardBackground : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.languageButtonColor
                : (isDark
                    ? AppColorsDark.borderColor
                    : AppColors.borderColor),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? AppColors.languageButtonColor
                  : (isDark
                      ? AppColorsDark.textSecondary
                      : AppColors.textSecondary),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
