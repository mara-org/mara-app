import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class ContactUsSection extends StatelessWidget {
  const ContactUsSection({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Contact us',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _SocialIconButton(
              assetPath: 'assets/socialMedia/logo-black.png',
              onTap: () => _openUrl('https://x.com/iamurmara?s=21'),
            ),
            const SizedBox(width: 12),
            _SocialIconButton(
              assetPath: 'assets/socialMedia/Instagram_Glyph_Gradient.png',
              onTap: () => _openUrl('https://www.instagram.com/iamurmara?igsh=MXVodWtjMHExcXFoOA=='),
            ),
            const SizedBox(width: 12),
            _SocialIconButton(
              assetPath: 'assets/socialMedia/threads-logo-black-01.png',
              onTap: () => _openUrl('https://www.threads.com/@iamurmara?igshid=NTc4MTIwNjQ2YQ=='),
            ),
            const SizedBox(width: 12),
            _SocialIconButton(
              assetPath: 'assets/socialMedia/TikTok_Icon_Black_Square.png',
              onTap: () => _openUrl('https://www.tiktok.com/@iamurmara'),
            ),
            const SizedBox(width: 12),
            _SocialIconButton(
              assetPath: 'assets/socialMedia/LI-In-Bug.png',
              onTap: () => _openUrl('https://www.linkedin.com/company/yourmara/'),
            ),
            const SizedBox(width: 12),
            _SocialIconButton(
              assetPath: 'assets/socialMedia/Discord-Symbol-Blurple.PNG',
              onTap: () => _openUrl('https://discord.com/invite/hVxvU4ekhJ'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final VoidCallback onTap;

  const _SocialIconButton({
    this.assetPath,
    this.icon,
    required this.onTap,
  }) : assert(assetPath != null || icon != null, 'Either assetPath or icon must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: assetPath != null
              ? Image.asset(
                  assetPath!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                )
              : Icon(
                  icon,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
}

