import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.contactUs,
            style: TextStyle(
              color: isDark
                  ? AppColorsDark.textSecondary
                  : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Center(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _socialButtons.length,
            itemBuilder: (context, index) {
              final button = _socialButtons[index];
              return _SocialIconButton(
                assetPath: button.assetPath,
                icon: button.icon,
                onTap: () => _openUrl(button.url),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SocialButtonData {
  final String? assetPath;
  final IconData? icon;
  final String url;

  const _SocialButtonData({this.assetPath, this.icon, required this.url})
      : assert(
          assetPath != null || icon != null,
          'Either assetPath or icon must be provided',
        );
}

const List<_SocialButtonData> _socialButtons = [
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/logo-black.png',
    url: 'https://x.com/iamurmara?s=21',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/Instagram_Glyph_Gradient.png',
    url: 'https://www.instagram.com/iamurmara?igsh=MXVodWtjMHExcXFoOA==',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/threads-logo-black-01.png',
    url: 'https://www.threads.com/@iamurmara?igshid=NTc4MTIwNjQ2YQ==',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/TikTok_Icon_Black_Square.png',
    url: 'https://www.tiktok.com/@iamurmara',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/LI-In-Bug.png',
    url: 'https://www.linkedin.com/company/yourmara/',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/Discord-Symbol-Blurple.png',
    url: 'https://discord.com/invite/hVxvU4ekhJ',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/Digital_Glyph_Green.png',
    url: 'https://whatsapp.com/channel/0029VbBvq5D9cDDgD72drm23',
  ),
  const _SocialButtonData(
    assetPath: 'assets/socialMedia/email.png',
    url: 'mailto:contact@iammara.com',
  ),
];

class _SocialIconButton extends StatelessWidget {
  final String? assetPath;
  final IconData? icon;
  final VoidCallback onTap;

  const _SocialIconButton({this.assetPath, this.icon, required this.onTap})
      : assert(
          assetPath != null || icon != null,
          'Either assetPath or icon must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isDark ? AppColorsDark.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.05),
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
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if asset fails to load
                    return Icon(
                      icon ?? Icons.link,
                      size: 28,
                      color: isDark
                          ? AppColorsDark.textPrimary
                          : AppColors.textPrimary,
                    );
                  },
                )
              : Icon(
                  icon,
                  size: 28,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
}
