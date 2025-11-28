import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mara_logo.dart';

class DeleteAccountScaffold extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const DeleteAccountScaffold({
    super.key,
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.04),
                GestureDetector(
                  onTap: onBack,
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
                SizedBox(height: size.height * 0.02),
                const Center(
                  child: MaraLogo(
                    width: 258,
                    height: 202,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: AppColors.languageButtonColor,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Roboto',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ...children,
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

