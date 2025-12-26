import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/session/session_service.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../l10n/app_localizations.dart';

class SignUpChoicesScreen extends ConsumerStatefulWidget {
  const SignUpChoicesScreen({super.key});

  @override
  ConsumerState<SignUpChoicesScreen> createState() => _SignUpChoicesScreenState();
}

class _SignUpChoicesScreenState extends ConsumerState<SignUpChoicesScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info(
        'Starting Sign in with Apple',
        feature: 'auth',
        screen: 'sign_up_choices_screen',
      );

      // Step 1: Sign in with Apple (works for both new and existing users)
      await FirebaseAuthHelper.signInWithApple();

      // Step 2: Create backend session (send Firebase ID token for verification)
      Logger.info(
        'Apple sign-in successful, creating backend session',
        feature: 'auth',
        screen: 'sign_up_choices_screen',
      );
      
      final sessionService = SessionService();
      try {
        await sessionService.createBackendSession();
        Logger.info(
          'Backend session created successfully',
          feature: 'auth',
          screen: 'sign_up_choices_screen',
        );
        
        // Step 3: Fetch user info and entitlements
        try {
          Logger.info(
            'Fetching user info',
            feature: 'auth',
            screen: 'sign_up_choices_screen',
          );
          await sessionService.fetchUserInfo();
          Logger.info(
            'User info fetched successfully',
            feature: 'auth',
            screen: 'sign_up_choices_screen',
          );
        } catch (e) {
          Logger.warning(
            'Failed to fetch user info: $e',
            feature: 'auth',
            screen: 'sign_up_choices_screen',
          );
        }
      } catch (e, stackTrace) {
        Logger.error(
          'Backend session failed',
          feature: 'auth',
          screen: 'sign_up_choices_screen',
          error: e,
          stackTrace: stackTrace,
        );
        
        // Backend session failed - check if it's a backend down error
        if (e.toString().contains('network') || 
            e.toString().contains('connection') ||
            e.toString().contains('timeout') ||
            e.toString().contains('unavailable')) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Service unavailable. Please try again later.';
          });
          return;
        }
        // Other errors - allow Apple sign-in to proceed
        Logger.warning(
          'Allowing Apple sign-in to proceed despite backend error',
          feature: 'auth',
          screen: 'sign_up_choices_screen',
        );
      }

      if (!mounted) return;

      // Step 4: Get user email (if available) and navigate
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (email != null && email.isNotEmpty) {
        ref.read(emailProvider.notifier).setEmail(email);
      }
      
      Logger.info(
        'Apple sign-in successful, navigating to home',
        feature: 'auth',
        screen: 'sign_up_choices_screen',
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      
      Logger.error(
        'Apple sign-in error: $e',
        feature: 'auth',
        screen: 'sign_up_choices_screen',
        error: e,
      );
      
      String errorMsg = 'Sign in with Apple failed. Please try again.';
      
      // Handle device limit error
      if (e is DeviceLimitException) {
        setState(() {
          _isLoading = false;
          if (e.plan == 'free') {
            _errorMessage = '${e.message}\n\nUpgrade to Premium to use up to 3 devices.';
          } else {
            _errorMessage = '${e.message}\n\nYou can remove a device from Settings to add this one.';
          }
        });
        return;
      }
      
      if (e.toString().contains('canceled')) {
        // User canceled - don't show error, just reset loading state
        setState(() {
          _isLoading = false;
        });
        return;
      } else if (e.toString().contains('network') || 
                 e.toString().contains('connection') ||
                 e.toString().contains('unavailable')) {
        errorMsg = 'Service unavailable. Please try again later.';
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
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
                    const Center(child: MaraLogo(width: 180, height: 130)),
                    const SizedBox(
                      height: 800,
                    ), // Space for positioned elements
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
                    color: isDark
                        ? AppColorsDark.textSecondary
                        : AppColors.textSecondary,
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
                backgroundColor:
                    isDark ? AppColorsDark.cardBackground : Colors.white,
                textColor:
                    isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                width: screenWidth - 64,
                height: 52,
                isDark: isDark,
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
                backgroundColor:
                    isDark ? Colors.black : AppColors.appleButtonColor,
                textColor: Colors.white,
                width: screenWidth - 64,
                height: 52,
                isDark: isDark,
                onPressed: _isLoading ? null : () {
                  _handleAppleSignIn();
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
            // Error message
            if (_errorMessage != null)
              PositionedDirectional(
                start: 32,
                top: 580,
                child: Container(
                  width: screenWidth - 64,
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

            // Positioned "Already a member? Sign in" at y740, centered horizontally
            PositionedDirectional(
              start: 0,
              end: 0,
              top: 740,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    context.go('/welcome-back');
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.alreadyAMember,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textPrimary
                                  : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text: l10n.signIn,
                            style: TextStyle(
                              color: AppColors.languageButtonColor,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
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
  final bool isDark;
  final VoidCallback? onPressed;

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
      onTap: onPressed ?? () {},
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
                  errorBuilder: (context, final error, stackTrace) {
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
