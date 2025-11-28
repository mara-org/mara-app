import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/email_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cache_utils.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/system/system_providers.dart';
import 'widgets/app_settings_section.dart';
import 'widgets/contact_us_section.dart';
import 'widgets/health_profile_section.dart';
import 'widgets/subscription_banner.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/delete-account/email');
            },
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final email =
        ref.watch(emailProvider) ?? 'No email'; // Get email from provider

    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      body: SafeArea(
        child: Column(
          children: [
            // Simple AppBar-style header
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: PlatformUtils.getDefaultPadding(context).left,
                right: PlatformUtils.getDefaultPadding(context).right,
                top: 8,
                bottom: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
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
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.profileTitle,
                        style: TextStyle(
                          color: const Color(0xFF0F172A), // #0F172A
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36), // Balance the back button
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: PlatformUtils.getDefaultPadding(context),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Subscription banner or premium status
                      Consumer(
                        builder: (context, ref, child) {
                          final subscriptionStatus =
                              ref.watch(subscriptionProvider);
                          if (subscriptionStatus ==
                              SubscriptionStatus.premium) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.youAreOnMaraPro,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const SubscriptionBanner();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      // User section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                start: 4, bottom: 12),
                            child: Text(
                              l10n.user,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.emailLabel,
                                        style: TextStyle(
                                          color: const Color(
                                              0xFF0F172A), // #0F172A
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          color: const Color(
                                              0xFF64748B), // #64748B
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Health Profile section
                      const HealthProfileSection(),
                      const SizedBox(height: 40),
                      // App Settings section
                      const AppSettingsSection(),
                      const SizedBox(height: 40),
                      // Privacy Policy
                      _ProfileMenuItem(
                        title: l10n.privacyPolicy,
                        subtitle: null,
                        icon: Icons.privacy_tip,
                        onTap: () {
                          context.push('/privacy-webview');
                        },
                      ),
                      const SizedBox(height: 16),
                      // Terms of Service
                      _ProfileMenuItem(
                        title: l10n.termsOfService,
                        subtitle: null,
                        icon: Icons.description,
                        onTap: () async {
                          final uri = Uri.parse('https://iammara.com/terms');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.inAppWebView,
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.couldNotOpenTerms),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                      // Developer Settings section
                      _DeveloperSettingsSection(),
                      const SizedBox(height: 40),
                      // Contact us section
                      const ContactUsSection(),
                      const SizedBox(height: 40),
                      // Log out button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextButton(
                          onPressed: () {
                            context.go('/logout-confirmation');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            l10n.logOut,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () => _showDeleteAccountDialog(context),
                          child: Text(
                            l10n.deleteAccount,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileMenuItem({
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
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
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
                icon,
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
                    title,
                    style: TextStyle(
                      color: const Color(0xFF0F172A), // #0F172A
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

class _DeveloperSettingsSection extends ConsumerWidget {
  const _DeveloperSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appVersionAsync = ref.watch(appVersionProvider);
    final deviceInfoAsync = ref.watch(deviceInfoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            l10n.developerSettings,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _DeveloperInfoItem(
          title: l10n.appVersion,
          icon: Icons.info_outline,
          value: appVersionAsync.when(
            data: (value) => value,
            loading: () => l10n.loading,
            error: (_, __) => '-',
          ),
        ),
        const SizedBox(height: 16),
        _DeveloperInfoItem(
          title: l10n.deviceInfo,
          icon: Icons.phone_android,
          value: deviceInfoAsync.when(
            data: (value) => value,
            loading: () => l10n.loading,
            error: (_, __) => '-',
          ),
        ),
        const SizedBox(height: 16),
        _DeveloperInfoItem(
          title: l10n.clearCache,
          icon: Icons.cleaning_services_outlined,
          value: l10n.clearCacheDescription,
          onTap: () => _showClearCacheDialog(context),
        ),
      ],
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearCache(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await CacheUtils.clearLocalCaches();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cacheClearedSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cacheClearedSuccess)),
        );
      }
    }
  }
}

class _DeveloperInfoItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? value;
  final VoidCallback? onTap;

  const _DeveloperInfoItem({
    required this.title,
    required this.icon,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
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
              icon,
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
                  title,
                  style: TextStyle(
                    color: const Color(0xFF0F172A), // #0F172A
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    value!,
                    style: TextStyle(
                      color: const Color(0xFF64748B), // #64748B
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: card,
        ),
      );
    }

    return card;
  }
}
