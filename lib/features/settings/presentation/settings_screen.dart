import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/system/system_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final language = ref.watch(languageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const MaraLogo(width: 32, height: 32),
            const SizedBox(width: 12),
            const Text('Settings'),
          ],
        ),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.go('/home');
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // General section
                Text(
                  'General',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // App language
                _SettingsRow(
                  title: 'App language',
                  subtitle:
                      language == AppLanguage.english ? 'English' : 'العربية',
                  icon: Icons.language,
                  onTap: () {
                    _showLanguagePicker(context, ref);
                  },
                ),
                const SizedBox(height: 12),
                // Dark mode toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Switch between light and dark themes',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.themeMode == AppThemeMode.dark,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).setThemeMode(
                                value ? AppThemeMode.dark : AppThemeMode.light,
                              );
                        },
                        activeColor: AppColors.languageButtonColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Health Goals
                _SettingsRow(
                  title: l10n.healthGoals,
                  subtitle: l10n.setDailyGoals,
                  icon: Icons.flag,
                  onTap: () {
                    context.push('/settings/health-goals');
                  },
                ),
                const SizedBox(height: 32),
                // Notifications section
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health reminders',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hydration, medication, and daily goals reminders.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.healthReminders,
                        onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .setHealthReminders(value);
                        },
                        activeColor: AppColors.languageButtonColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email notifications',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Receive important updates and reports by email.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
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
                const SizedBox(height: 32),
                // Data & Privacy section
                Text(
                  'Data & Privacy',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsRow(
                  title: 'Privacy Policy',
                  subtitle: null,
                  icon: Icons.privacy_tip,
                  onTap: () async {
                    final uri = Uri.parse('https://iammara.com/privacy');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Privacy Policy'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                _SettingsRow(
                  title: 'Terms of Service',
                  subtitle: null,
                  icon: Icons.description,
                  onTap: () async {
                    final uri = Uri.parse('https://iammara.com/terms');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.inAppWebView);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open Terms of Service'),
                          ),
                        );
                      }
                    }
                  },
                ),
                
                // Debug: Network Test (only in debug/staging)
                if (AppConfig.isDebug || AppConfig.isStaging) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Debug',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsRow(
                    title: 'Network Test',
                    subtitle: 'Test backend connectivity',
                    icon: Icons.network_check,
                    onTap: () {
                      context.push('/network-test');
                    },
                  ),
                ],
                
                const SizedBox(height: 40),
                // Version info
                Consumer(
                  builder: (context, ref, child) {
                    final versionAsync = ref.watch(appVersionProvider);
                    return Center(
                      child: versionAsync.when(
                        data: (version) => Text(
                          'Mara $version',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        loading: () => Text(
                          'Mara',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Mara',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title: const Text('English'),
                  leading: const Icon(Icons.language),
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(AppLanguage.english);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('العربية'),
                  leading: const Icon(Icons.language),
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(AppLanguage.arabic);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.languageButtonColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
    );
  }
}
