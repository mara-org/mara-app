import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/language_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AppSettingsSection extends ConsumerWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final language = ref.watch(languageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            l10n.settingsTitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // App language
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: InkWell(
            onTap: () => context.push('/language-selector?from=profile'),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.languageButtonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language,
                    color: AppColors.languageButtonColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appLanguage,
                        style: TextStyle(
                          color: const Color(0xFF0F172A), // #0F172A
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        language == AppLanguage.english
                            ? l10n.english
                            : l10n.arabic,
                        style: TextStyle(
                          color: const Color(0xFF64748B), // #64748B
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Health reminders switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.languageButtonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: AppColors.languageButtonColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.healthReminders,
                      style: TextStyle(
                        color: const Color(0xFF0F172A), // #0F172A
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.healthRemindersSubtitle,
                      style: TextStyle(
                        color: const Color(0xFF64748B), // #64748B
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.healthReminders,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setHealthReminders(value);
                },
                activeColor: AppColors.languageButtonColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Email notifications switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.languageButtonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email,
                  color: AppColors.languageButtonColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emailNotifications,
                      style: TextStyle(
                        color: const Color(0xFF0F172A), // #0F172A
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.emailNotificationsSubtitle,
                      style: TextStyle(
                        color: const Color(0xFF64748B), // #64748B
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.emailNotifications,
                onChanged: (value) {
                  ref
                      .read(settingsProvider.notifier)
                      .setEmailNotifications(value);
                },
                activeColor: AppColors.languageButtonColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
