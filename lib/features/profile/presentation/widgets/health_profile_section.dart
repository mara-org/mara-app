import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/models/user_profile_setup.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';

class HealthProfileSection extends ConsumerWidget {
  const HealthProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            l10n.healthProfileTitle,
            style: TextStyle(
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _HealthProfileRow(
                label: l10n.nameField,
                value: profile.name ?? l10n.notSet,
                onTap: () => context.push('/name-input?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.dateOfBirthField,
                value: profile.dateOfBirth != null
                    ? DateFormat(
                        'MMM dd, yyyy',
                        locale.toString(),
                      ).format(profile.dateOfBirth!)
                    : l10n.notSet,
                onTap: () => context.push('/dob-input?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.genderField,
                value: profile.gender != null
                    ? profile.gender == Gender.male
                        ? l10n.male
                        : l10n.female
                    : l10n.notSet,
                onTap: () => context.push('/gender?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.heightField,
                value: profile.height != null && profile.heightUnit != null
                    ? '${profile.height} ${profile.heightUnit}'
                    : l10n.notSet,
                onTap: () => context.push('/height?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.weightField,
                value: profile.weight != null && profile.weightUnit != null
                    ? '${profile.weight} ${profile.weightUnit}'
                    : l10n.notSet,
                onTap: () => context.push('/weight?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.bloodTypeField,
                value: profile.bloodType ?? l10n.notSet,
                onTap: () => context.push('/blood-type?from=profile'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(
                  0xFF0EA5C6,
                ).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: l10n.mainGoalField,
                value: profile.mainGoal ?? l10n.notSet,
                onTap: () => context.push('/goals?from=profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _HealthProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppColorsDark.textPrimary
                    : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
