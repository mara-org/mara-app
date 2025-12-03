import 'package:flutter/material.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const MaraLogo(width: 32, height: 32),
            const SizedBox(width: 12),
            const Text('Privacy Policy'),
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
                  'Privacy Policy',
                  style: AppTextStyles.heading1(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 24),
                Text(
                  'Last updated: ${DateTime.now().year}',
                  style: AppTextStyles.caption(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                _Section(
                  title: 'Data Collection',
                  content:
                      'Mara collects minimal health data necessary to provide personalized health insights. This includes information you provide during setup, such as your name, date of birth, gender, height, weight, blood type, and health goals.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Local Processing',
                  content:
                      'All data processing happens directly on your device. Your health information, conversations with Mara, and any camera or microphone data are processed locally and never leave your device without your explicit consent.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'No Data Selling',
                  content:
                      'We do not sell, rent, or share your personal health data with third parties. Your privacy is our top priority, and we are committed to keeping your information secure and private.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Permissions',
                  content:
                      'Mara may request access to your camera, microphone, notifications, and health data to provide enhanced features. You can manage these permissions at any time through the Settings screen. All permissions are optional, and you can use Mara without granting them.',
                ),
                const SizedBox(height: 24),
                _Section(
                  title: 'Contact Information',
                  content:
                      'If you have any questions about this Privacy Policy, please contact us at privacy@mara.app. We are committed to addressing your concerns and ensuring your privacy is protected.',
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

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: AppTextStyles.body(
            context,
          ).copyWith(color: AppColors.textSecondary, height: 1.6),
        ),
      ],
    );
  }
}
