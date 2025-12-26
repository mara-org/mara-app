import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';

class VerifyEmailLinkScreen extends ConsumerStatefulWidget {
  const VerifyEmailLinkScreen({super.key});

  @override
  ConsumerState<VerifyEmailLinkScreen> createState() =>
      _VerifyEmailLinkScreenState();
}

class _VerifyEmailLinkScreenState extends ConsumerState<VerifyEmailLinkScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check email verification status periodically
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      // Check if email is verified
      final isVerified = await FirebaseAuthHelper.isEmailVerified();

      if (!mounted) return;

      if (isVerified) {
        Logger.info(
          'Email verified via link',
          feature: 'auth',
          screen: 'verify_email_link_screen',
        );

        // Navigate to welcome back screen
        context.go('/welcome-back');
      } else {
        // Continue checking periodically
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _checkEmailVerification();
          }
        });
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error checking email verification: $e',
        feature: 'auth',
        screen: 'verify_email_link_screen',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _onResendPressed() async {
    if (_isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final success = await FirebaseAuthHelper.sendEmailVerification();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Failed to send verification email. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final email = ref.read(emailProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Back button area with logo
                Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: () => context.go('/sign-in-email'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.languageButtonColor.withOpacity(
                              0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.languageButtonColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Center(child: MaraLogo(width: 180, height: 130)),
                  ],
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.verifyEmailTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    email != null
                        ? 'We\'ve sent a verification link to $email. Please check your inbox and click the link to verify your email address.'
                        : 'We\'ve sent a verification link to your email. Please check your inbox and click the link to verify your email address.',
                    textAlign: TextAlign.center,
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
                if (_isChecking) ...[
                  const SizedBox(height: 40),
                  const Center(child: SpinningMaraLogo(width: 40, height: 40)),
                  const SizedBox(height: 16),
                  Text(
                    'Checking verification status...',
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Resend button
                SizedBox(
                  width: 320,
                  height: 52,
                  child: PrimaryButton(
                    text: _isResending
                        ? 'Sending...'
                        : 'Resend verification email',
                    width: 320,
                    height: 52,
                    borderRadius: 20,
                    onPressed: _isResending ? null : _onResendPressed,
                  ),
                ),
                const SizedBox(height: 16),
                // Back to sign in button
                TextButton(
                  onPressed: () => context.go('/sign-in-email'),
                  child: Text(
                    'Back to sign in',
                    style: TextStyle(
                      color: AppColors.languageButtonColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
