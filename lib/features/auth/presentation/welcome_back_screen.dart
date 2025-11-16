import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';

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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
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
              Positioned(
                left: 28,
                top: 365,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ),
              ),

              // Positioned Password field at x28, y427
              Positioned(
                left: 28,
                top: 427,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
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
              Positioned(
                left: 28,
                top: 511,
                child: SizedBox(
                  width: buttonWidth,
                  child: PrimaryButton(
                    text: 'Verify',
                    width: buttonWidth,
                    height: 52,
                    borderRadius: 20,
                    onPressed: _handleVerify,
                  ),
                ),
              ),

              // Positioned "Continue with Google" button at x28, y576 (same width as email/password fields)
              Positioned(
                left: 28,
                top: 576,
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: 'Continue with Google',
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
              Positioned(
                left: 28,
                top: 640, // 576 + 52 (button height) + 12 (spacing)
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: 'Continue with Apple',
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
              Positioned(
                left: 38,
                top: 285,
                child: Text(
                  'Welcome back',
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
              Positioned(
                left: 40,
                top: 331,
                child: Text(
                  'Happy to have you again',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),

              // Positioned "Forget your password? Click here" at x193, y489
              Positioned(
                left: 193,
                top: 489,
                child: GestureDetector(
                  onTap: () {
                    context.go('/forgot-password-email');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.underline,
                      ),
                      children: [
                        const TextSpan(text: 'Forget your password? '),
                        TextSpan(
                          text: 'Click here',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Positioned "Don't have an account? Click here" at x87, y740
              Positioned(
                left: 87,
                top: 740,
                child: GestureDetector(
                  onTap: () {
                    context.go('/sign-up-choices');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        const TextSpan(text: 'Don\'t have an account? '),
                        TextSpan(
                          text: 'Click here',
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
              textAlign: TextAlign.center,
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
