import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';

class SignUpChoicesScreen extends StatelessWidget {
  const SignUpChoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content for logo
            SingleChildScrollView(
              child: Padding(
                padding: PlatformUtils.getDefaultPadding(context),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Mara logo
                    const Center(
                      child: MaraLogo(
                        width: 258,
                        height: 202,
                      ),
                    ),
                    const SizedBox(
                        height: 800), // Space for positioned elements
                  ],
                ),
              ),
            ),
            // Positioned "Join Mara" title at x33, y285
            PositionedDirectional(
              start: 33,
              top: 285,
              child: Text(
                l10n.joinMara,
                style: TextStyle(
                  color: AppColors.languageButtonColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
            // Positioned subtitle at x24, y325
            PositionedDirectional(
              start: 24,
              top: 325,
              child: SizedBox(
                width: screenWidth - 48,
                child: Text(
                  l10n.joinMaraSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            // Positioned "Continue with Google" button at x32, y365
            PositionedDirectional(
              start: 32,
              top: 365,
              child: _SocialButton(
                text: l10n.continueWithGoogle,
                iconImagePath: 'assets/icons/Sign in/Social media logo.png',
                backgroundColor: Colors.white,
                textColor: AppColors.textPrimary,
                width: screenWidth - 64,
                height: 52,
                onPressed: () {
                  // TODO: Implement Google sign-in
                },
              ),
            ),
            // Positioned "Continue with Apple" button at x32, y437
            PositionedDirectional(
              start: 32,
              top: 437,
              child: _SocialButton(
                text: l10n.continueWithApple,
                iconImagePath: 'assets/icons/Sign in/Wrapper.png',
                backgroundColor: AppColors.appleButtonColor,
                textColor: Colors.white,
                width: screenWidth - 64,
                height: 52,
                onPressed: () {
                  // TODO: Implement Apple sign-in
                },
              ),
            ),
            // Positioned "Sign up with Email" button at x32, y509
            PositionedDirectional(
              start: 32,
              top: 509,
              child: _SocialButton(
                text: l10n.signUpWithEmail,
                iconImagePath: 'assets/icons/Sign in/mail.png',
                backgroundColor: AppColors.languageButtonColor,
                textColor: Colors.white,
                width: screenWidth - 64,
                height: 52,
                onPressed: () {
                  context.go('/sign-in-email');
                },
              ),
            ),
            // Positioned "Already a member ?" at x117, y740
            PositionedDirectional(
              start: 117,
              top: 740,
              child: GestureDetector(
                onTap: () {
                  context.go('/welcome-back');
                },
                child: Row(
                  children: [
                    Text(
                      '${l10n.alreadyAMember} ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned "Sign in" at x265, y740
            PositionedDirectional(
              start: 265,
              top: 740,
              child: GestureDetector(
                onTap: () {
                  context.go('/welcome-back');
                },
                child: Text(
                  l10n.signIn,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.underline,
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

class _SocialButton extends StatelessWidget {
  final String text;
  final String? iconImagePath;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    this.iconImagePath,
    required this.backgroundColor,
    required this.textColor,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconImagePath != null) ...[
              SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(
                  iconImagePath!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image: $iconImagePath - $error');
                    return Icon(
                      Icons.image,
                      color: textColor,
                      size: 28,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
