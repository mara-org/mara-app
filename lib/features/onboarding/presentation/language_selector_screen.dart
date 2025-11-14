import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class LanguageSelectorScreen extends ConsumerWidget {
  const LanguageSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0EA5C6), // #0EA5C6
              Color(0xFF10A9CC), // #10A9CC
            ],
          ),
        ),
        child: Column(
          children: [
            // Expanded area with gradient and logo
            Expanded(
              child: Stack(
                children: [
                  // Logo at specific position
                  Positioned(
                    left: 68,
                    top: 270,
                    child: const MaraLogo(
                      width: 285,
                      height: 202,
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
                color: AppColors.languageCardBackground,
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
                      onPressed: () {
                        ref.read(languageProvider.notifier).setLanguage(
                              AppLanguage.arabic,
                            );
                        context.go('/welcome-intro');
                      },
                    ),
                    const SizedBox(height: 20),
                    // English button
                    _LanguageButton(
                      text: 'English',
                      onPressed: () {
                        ref.read(languageProvider.notifier).setLanguage(
                              AppLanguage.english,
                            );
                        context.go('/welcome-intro');
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
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
          color: AppColors.languageButtonColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

