import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/widgets/mara_logo.dart';

class LanguageSelectorScreen extends ConsumerWidget {
  final bool isFromProfile;

  const LanguageSelectorScreen({super.key, this.isFromProfile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final disableArabic = isFromProfile && currentLanguageCode == 'ar';
    final disableEnglish = isFromProfile && currentLanguageCode == 'en';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColorsDark.gradientStart,
                    AppColorsDark.gradientEnd,
                  ]
                : [
                    AppColors.gradientStart, // #0EA5C6
                    AppColors.gradientEnd, // #10A9CC
                  ],
          ),
        ),
        child: Column(
          children: [
            // Expanded area with gradient and logo
            Expanded(
              child: Stack(
                children: [
                  // Logo centered vertically
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MaraLogo(width: 200, height: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // White rounded container at bottom
            Container(
              height: 325 + MediaQuery.of(context).padding.bottom,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 24),
                    blurRadius: 55,
                  ),
                ],
                color: isDark
                    ? AppColorsDark.languageCardBackground
                    : AppColors.languageCardBackground,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Arabic button
                    _LanguageButton(
                      text: 'العربية',
                      isDisabled: disableArabic,
                      isDark: isDark,
                      onPressed: disableArabic
                          ? null
                          : () async {
                              await ref
                                  .read(appLocaleProvider.notifier)
                                  .setLocale(const Locale('ar'));
                              // Update old language provider for backward compatibility
                              ref
                                  .read(languageProvider.notifier)
                                  .setLanguage(AppLanguage.arabic);
                              // Wait for multiple frames to ensure MaterialApp and all widgets rebuild
                              await Future.delayed(
                                const Duration(milliseconds: 50),
                              );
                              if (context.mounted) {
                                if (isFromProfile) {
                                  final uri = Uri(
                                    path: '/name-input',
                                    queryParameters: {
                                      'from': 'profile',
                                      'fromLanguageChange': 'true',
                                      'language': 'ar',
                                    },
                                  );
                                  context.go(uri.toString());
                                } else {
                                  context.go('/welcome-intro');
                                }
                              }
                            },
                    ),
                    const SizedBox(height: 20),
                    // English button
                    _LanguageButton(
                      text: 'English',
                      isDisabled: disableEnglish,
                      isDark: isDark,
                      onPressed: disableEnglish
                          ? null
                          : () async {
                              await ref
                                  .read(appLocaleProvider.notifier)
                                  .setLocale(const Locale('en'));
                              // Update old language provider for backward compatibility
                              ref
                                  .read(languageProvider.notifier)
                                  .setLanguage(AppLanguage.english);
                              // Wait for multiple frames to ensure MaterialApp and all widgets rebuild
                              await Future.delayed(
                                const Duration(milliseconds: 50),
                              );
                              if (context.mounted) {
                                if (isFromProfile) {
                                  final uri = Uri(
                                    path: '/name-input',
                                    queryParameters: {
                                      'from': 'profile',
                                      'fromLanguageChange': 'true',
                                      'language': 'en',
                                    },
                                  );
                                  context.go(uri.toString());
                                } else {
                                  context.go('/welcome-intro');
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isDark;

  const _LanguageButton({
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDisabled
        ? (isDark ? AppColorsDark.borderColor : Colors.grey.shade300)
        : AppColors.languageButtonColor;
    final textColor = isDisabled
        ? (isDark ? AppColorsDark.textSecondary : Colors.grey.shade600)
        : Colors.white;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDisabled ? 0.05 : 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
          color: backgroundColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
