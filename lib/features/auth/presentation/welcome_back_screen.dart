import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourEmail;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return l10n.pleaseEnterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourPassword;
    }
    return null;
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      // Navigate to Home screen
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth - 56; // Same width as email and password fields
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Scrollable content for buttons
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

              // Positioned Email field at x28, y365
              PositionedDirectional(
                start: 28,
                top: 365,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: l10n.emailLabel,
                    hint: l10n.enterYourEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _validateEmail(value, context),
                  ),
                ),
              ),

              // Positioned Password field at x28, y427
              PositionedDirectional(
                start: 28,
                top: 427,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: l10n.passwordLabel,
                    hint: l10n.enterYourPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => _validatePassword(value, context),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Positioned Verify button at x28, y511 (same width as email/password fields)
              PositionedDirectional(
                start: 28,
                top: 511,
                child: SizedBox(
                  width: buttonWidth,
                  child: PrimaryButton(
                    text: l10n.verify,
                    width: buttonWidth,
                    height: 52,
                    borderRadius: 20,
                    onPressed: _handleVerify,
                  ),
                ),
              ),

              // Positioned "Continue with Google" button at x28, y576 (same width as email/password fields)
              PositionedDirectional(
                start: 28,
                top: 576,
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: l10n.continueWithGoogle,
                    iconImagePath: 'assets/icons/Sign in/Social media logo.png',
                    backgroundColor: Colors.white,
                    textColor: AppColors.textPrimary,
                    width: buttonWidth,
                    height: 52,
                    onPressed: () {
                      // TODO: Implement Google sign-in
                    },
                  ),
                ),
              ),

              // Positioned "Continue with Apple" button at x28, y640 (same width as email/password fields)
              PositionedDirectional(
                start: 28,
                top: 640, // 576 + 52 (button height) + 12 (spacing)
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: l10n.continueWithApple,
                    iconImagePath: 'assets/icons/Sign in/Wrapper.png',
                    backgroundColor: AppColors.appleButtonColor,
                    textColor: Colors.white,
                    width: buttonWidth,
                    height: 52,
                    onPressed: () {
                      // TODO: Implement Apple sign-in
                    },
                  ),
                ),
              ),

              // Positioned "Welcome back" title at x38, y285
              PositionedDirectional(
                start: 38,
                top: 285,
                child: Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 38,
                    fontWeight: FontWeight.w600, // SemiBold
                    height: 1,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),

              // Positioned "Happy to have you again" at x40, y331
              PositionedDirectional(
                start: 40,
                top: 331,
                child: Text(
                  l10n.welcomeBackSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),

              // Positioned "Forget your password? Click here" directly under password field, direction-aware alignment
              PositionedDirectional(
                start: 28,
                top: 427 + 56 + 5, // Password field top (427) + field height (~56) + margin (5px)
                child: SizedBox(
                  width: screenWidth - 56, // Same width as password field - full width
                  child: Align(
                    alignment: AlignmentDirectional.centerStart, // Left in LTR, right in RTL
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: GestureDetector(
                        onTap: () {
                          context.push('/forgot-password-email');
                        },
                        child: RichText(
                          textAlign: TextAlign.start, // Left in LTR, right in RTL
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                              decoration: TextDecoration.underline,
                            ),
                            children: [
                              TextSpan(text: '${l10n.forgotPassword} '),
                              TextSpan(
                                text: l10n.clickHere,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned "Don't have an account? Click here" centered horizontally
              PositionedDirectional(
                start: 0,
                end: 0,
                top: 740,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/sign-up-choices');
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(text: '${l10n.dontHaveAccount} '),
                          TextSpan(
                            text: l10n.signUp,
                            style: const TextStyle(
                              color: Color(0xFF0EA5C6), // #0EA5C6
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                fontWeight: FontWeight.w500, // Medium
                height: 1,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
