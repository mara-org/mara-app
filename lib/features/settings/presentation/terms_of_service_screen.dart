import 'package:flutter/material.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/theme/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const MaraLogo(width: 32, height: 32),
            const SizedBox(width: 12),
            const Text('Terms of Service'),
          ],
        ),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Terms of Service',
                  style: AppTextStyles.heading1(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Last updated: ${DateTime.now().year}',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Acceptance of Terms',
                  content:
                      'By accessing and using the Mara mobile application, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Use of the App',
                  content:
                      'Mara is designed to provide AI-powered health insights and guidance. The app is intended for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'User Responsibilities',
                  content:
                      'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must provide accurate and complete information when using the app.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Limitation of Liability',
                  content:
                      'Mara and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the app. The app is provided "as is" without warranties of any kind.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Governing Law',
                  content:
                      'These terms shall be governed by and construed in accordance with applicable laws. Any disputes arising from these terms or your use of the app shall be resolved through appropriate legal channels.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Changes to Terms',
                  content:
                      'We reserve the right to modify these terms at any time. We will notify users of any significant changes. Your continued use of the app after such modifications constitutes acceptance of the updated terms.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2(context).copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyles.body(context).copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

