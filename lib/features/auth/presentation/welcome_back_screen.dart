import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/session/session_service.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../l10n/app_localizations.dart';

class WelcomeBackScreen extends ConsumerStatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  ConsumerState<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

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

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Step 1: Sign in with Firebase
      await FirebaseAuthHelper.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Create backend session (send Firebase ID token for verification)
      final sessionService = SessionService();
      try {
        await sessionService.createBackendSession();
        
        // Step 3: Fetch user info and entitlements from GET /v1/auth/me
        try {
          await sessionService.fetchUserInfo();
        } catch (e) {
          // If /v1/auth/me fails, log but don't block login
          // Session was created successfully, user info can be fetched later
        }
      } catch (e) {
        // Backend session failed - check if it's a backend down error
        if (e.toString().contains('network') || 
            e.toString().contains('connection') ||
            e.toString().contains('timeout') ||
            e.toString().contains('unavailable')) {
          // Backend is down - show service unavailable state
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Service unavailable. Please try again later.';
          });
          return;
        }
        // Other errors - allow Firebase sign-in to proceed
        // User can still use app with Firebase auth
      }

      if (!mounted) return;

      // Step 3: Save email and navigate
      ref.read(emailProvider.notifier).setEmail(email);
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        // Show user-friendly error message
        if (e.toString().contains('network') || 
            e.toString().contains('connection') ||
            e.toString().contains('unavailable')) {
          _errorMessage = 'Service unavailable. Please try again later.';
        } else if (e.toString().contains('invalid') || 
                   e.toString().contains('credential')) {
          _errorMessage = 'Invalid email or password.';
        } else {
          _errorMessage = 'Sign in failed. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        screenWidth - 56; // Same width as email and password fields
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
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
                      const Center(child: MaraLogo(width: 258, height: 202)),
                      const SizedBox(
                        height: 800,
                      ), // Space for positioned elements
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          text: l10n.verify,
                          width: buttonWidth,
                          height: 52,
                          borderRadius: 20,
                          onPressed: _handleVerify,
                        ),
                ),
              ),
              
              // Error message
              if (_errorMessage != null)
                PositionedDirectional(
                  start: 28,
                  top: 580,
                  child: Container(
                    width: buttonWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
                    backgroundColor:
                        isDark ? AppColorsDark.cardBackground : Colors.white,
                    textColor: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    width: buttonWidth,
                    height: 52,
                    isDark: isDark,
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
                    backgroundColor:
                        isDark ? Colors.black : AppColors.appleButtonColor,
                    textColor: Colors.white,
                    width: buttonWidth,
                    height: 52,
                    isDark: isDark,
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
                top: 427 +
                    56 +
                    5, // Password field top (427) + field height (~56) + margin (5px)
                child: SizedBox(
                  width: screenWidth -
                      56, // Same width as password field - full width
                  child: Align(
                    alignment: AlignmentDirectional
                        .centerStart, // Left in LTR, right in RTL
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: GestureDetector(
                        onTap: () {
                          context.push('/forgot-password-email');
                        },
                        child: RichText(
                          textAlign:
                              TextAlign.start, // Left in LTR, right in RTL
                          text: TextSpan(
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
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
                          color:
                              isDark ? AppColorsDark.textPrimary : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(text: '${l10n.dontHaveAccount} '),
                          TextSpan(
                            text: l10n.signUp,
                            style: TextStyle(
                              color: AppColors.languageButtonColor, // #0EA5C6
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
  final bool isDark;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    this.iconImagePath,
    required this.backgroundColor,
    required this.textColor,
    required this.width,
    required this.height,
    this.isDark = false,
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
              color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
              width: 1),
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
                    return Icon(Icons.image, color: textColor, size: 28);
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
