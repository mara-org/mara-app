import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/providers/temp_auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/exceptions/rate_limit_exception.dart';
import '../domain/models/auth_result.dart';
import '../data/datasources/auth_remote_data_source_impl.dart'
    show VerificationCooldownException;

class SignInEmailScreen extends ConsumerStatefulWidget {
  const SignInEmailScreen({super.key});

  @override
  ConsumerState<SignInEmailScreen> createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends ConsumerState<SignInEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isSigningUp = false;
  String? _errorMessage;
  String? _loadingMessage;
  bool _showSignInOption = false; // Show "Sign in instead" option

  // Password requirements state
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumeric = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  bool _hasMaxLength = true; // Always true initially since max is 4096

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
    // Clear error when user starts typing (but NOT on init - let errors show!)
    _emailController.addListener(_clearErrorOnInput);
    _passwordController.addListener(_clearErrorOnInput);
  }
  
  void _clearErrorOnInput() {
    // Only clear error if user is actively typing NEW characters
    // Don't clear if fields already had text (like pre-filled email)
    // This prevents clearing errors when screen loads with pre-filled data
    // Note: Currently we don't auto-clear errors - they persist until user submits again
    if (_errorMessage != null && mounted) {
      // Could add logic here to clear error on significant input changes
      // For now, errors persist until next submission attempt
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearErrorOnInput);
    _passwordController.removeListener(_checkPasswordRequirements);
    _passwordController.removeListener(_clearErrorOnInput);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPasswordRequirements() {
    final password = _passwordController.text;
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumeric = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[^a-zA-Z0-9]'));
      _hasMinLength = password.length >= 8;
      _hasMaxLength = password.length <= 4096;
    });
  }

  bool get _isPasswordValid {
    return _hasUppercase &&
        _hasLowercase &&
        _hasNumeric &&
        _hasSpecialChar &&
        _hasMinLength &&
        _hasMaxLength;
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
    if (!_isPasswordValid) {
      return l10n.pleaseEnterYourPassword; // Generic error
    }
    return null;
  }

  Future<void> _onVerifyPressed() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) return;
    if (_isSigningUp) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSigningUp = true;
      _errorMessage = null;
      _loadingMessage = 'Creating your account...';
    });

    try {
      Logger.info(
        'Starting sign-up process',
        feature: 'auth',
        screen: 'sign_in_email_screen',
      );

      // Update loading message for Firebase step
      setState(() {
        _loadingMessage = 'Setting up Firebase account...';
      });

      final authRepository = ref.read(authRepositoryProvider);
      
      // Update loading message for backend step (Render free tier takes time to wake up)
      setState(() {
        _loadingMessage = 'Connecting to server... (free tier may take 30-90 seconds to wake up)';
      });
      
      // Step 1: Sign up with Firebase and backend
      final result = await authRepository.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        Logger.info(
          'Sign-up successful - Firebase user created and backend user registered',
          feature: 'auth',
          screen: 'sign_in_email_screen',
        );
        
        // Save the email before navigating
        ref.read(emailProvider.notifier).setEmail(email);
        
        // Step 1: Send Firebase email verification link automatically after sign-up
        // User is already signed in to Firebase after sign-up, so we can send verification email
        try {
          setState(() {
            _loadingMessage = 'Sending verification email...';
          });
          
          final emailSent = await FirebaseAuthHelper.sendEmailVerification();
          
          if (!mounted) return;
          
          if (emailSent) {
            Logger.info(
              'Verification email sent, navigating to verify email screen',
              feature: 'auth',
              screen: 'sign_in_email_screen',
            );
            
            // Navigate to verify email screen
            // User will click link in email → Firebase verifies → App detects → Creates backend session → Navigates to home
            context.go('/verify-email');
          } else {
            Logger.warning(
              'Failed to send verification email, but navigating anyway',
              feature: 'auth',
              screen: 'sign_in_email_screen',
            );
            if (mounted) {
              context.go('/verify-email');
            }
          }
        } on RateLimitException catch (e) {
          // Rate limit error - show specific message
          if (!mounted) return;
          setState(() {
            _errorMessage = e.message;
            _isSigningUp = false;
            _loadingMessage = null;
          });
          return;
        } on FirebaseAuthException catch (e, stackTrace) {
          Logger.error(
            'Firebase error sending verification email: ${e.code}',
            feature: 'auth',
            screen: 'sign_in_email_screen',
            error: e,
            stackTrace: stackTrace,
          );
          
          // Handle specific Firebase errors
          if (!mounted) return;
          String errorMsg = 'Failed to send verification email. Please try again.';
          if (e.code == 'operation-not-allowed') {
            errorMsg = 'This email domain is not allowed. Please contact support or use a different email address.';
          }
          
          setState(() {
            _errorMessage = errorMsg;
            _isSigningUp = false;
            _loadingMessage = null;
          });
          return;
        } catch (e, stackTrace) {
          Logger.error(
            'Unexpected error sending verification email: $e',
            feature: 'auth',
            screen: 'sign_in_email_screen',
            error: e,
            stackTrace: stackTrace,
          );
          // Still navigate to verification screen - user can resend email there
          if (mounted) {
            context.go('/verify-email');
          }
        } finally {
          // Clear loading state
          if (mounted) {
            setState(() {
              _loadingMessage = null;
            });
          }
        }
      } else {
        Logger.error(
          'Sign-up failed: ${result.errorMessage} (ErrorType: ${result.errorType})',
          feature: 'auth',
          screen: 'sign_in_email_screen',
        );
        
        // Clear stored password on failure
        ref.read(tempAuthProvider.notifier).clearPassword();
        
        // Show specific error message based on error type
        String errorMsg;
        bool showSignInOption = false;
        switch (result.errorType) {
          case AuthErrorType.networkError:
            errorMsg = 'Network error. Please check your connection and try again.';
            break;
          case AuthErrorType.emailAlreadyRegistered:
            errorMsg = 'This email is already registered.';
            showSignInOption = true;
            break;
          case AuthErrorType.invalidCredentials:
            errorMsg = result.errorMessage ?? 'Invalid email or password. Please try again.';
            break;
          case AuthErrorType.emailNotVerified:
            errorMsg = 'Please verify your email address.';
            break;
          default:
            errorMsg = result.errorMessage ?? 'Sign up failed. Please try again.';
        }
        
        // Ensure error is visible - scroll to show it after state update
        setState(() {
          _errorMessage = errorMsg;
          _showSignInOption = showSignInOption;
          _isSigningUp = false; // Make sure loading state is cleared
        });
        
        // Scroll to error after frame is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _errorMessage != null && _errorMessage!.isNotEmpty) {
            try {
              // Find the error widget and scroll to it
              final context = this.context;
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              // If scroll fails, at least log the error
              debugPrint('Could not scroll to error: $e');
            }
          }
        });
        
        // Debug: Log error message to ensure it's being set
        debugPrint('🔴 ERROR SET: $errorMsg');
        debugPrint('🔴 showSignInOption: $showSignInOption');
        Logger.info(
          'Error message set: $errorMsg, showSignInOption: $showSignInOption',
          feature: 'auth',
          screen: 'sign_in_email_screen',
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Sign-up exception: $e',
        feature: 'auth',
        screen: 'sign_in_email_screen',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (!mounted) return;
      
      // Clear stored password on error
      ref.read(tempAuthProvider.notifier).clearPassword();
      
      // Provide more specific error message
      String errorMsg = 'An error occurred. Please try again.';
      bool showSignInOption = false;
      if (e.toString().contains('email-already-in-use') || 
          e.toString().contains('Email already registered')) {
        errorMsg = 'This email is already registered.';
        showSignInOption = true;
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMsg = 'Cannot connect to server. The server may be starting up (free tier takes 30-90 seconds). Please wait and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMsg = 'Request timed out. Free-tier servers take 30-90 seconds to wake up. Please wait a moment and try again.';
      } else if (e.toString().contains('Firebase')) {
        errorMsg = 'Firebase error. Please check your internet connection.';
      } else if (e.toString().contains('500') || 
                 e.toString().contains('internal server error') ||
                 e.toString().contains('Internal Server Error')) {
        errorMsg = 'Backend server error. The server is experiencing issues. Please try again later or contact support.';
      }
      
      // Ensure error is visible - scroll to show it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && errorMsg.isNotEmpty) {
          // Scroll to make error visible
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
      
      setState(() {
        _errorMessage = errorMsg;
        _showSignInOption = showSignInOption;
        _loadingMessage = null;
        _isSigningUp = false; // Make sure loading state is cleared
      });
      
      // Debug: Log error message to ensure it's being set
      debugPrint('🔴 ERROR SET (catch): $errorMsg');
      debugPrint('🔴 showSignInOption: $showSignInOption');
      Logger.info(
        'Error message set (catch): $errorMsg, showSignInOption: $showSignInOption',
        feature: 'auth',
        screen: 'sign_in_email_screen',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningUp = false;
          _loadingMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.backgroundLight : Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.04),
                  // Mara logo at the top
                  const Center(child: MaraLogo(width: 180, height: 130)),
                  SizedBox(height: h * 0.02),
                  // Title
                  Text(
                    l10n.enterYourEmail,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0EA5C6),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  MaraTextField(
                    label: l10n.emailLabel,
                    hint: l10n.enterYourEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _validateEmail(value, context),
                  ),
                  const SizedBox(height: 12),
                  // Password field
                  MaraTextField(
                    label: l10n.passwordLabel,
                    hint: l10n.enterYourPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => _validatePassword(value, context),
                    onChanged: (_) => _checkPasswordRequirements(),
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
                  const SizedBox(height: 12),
                  // Password requirements
                  _PasswordRequirementsWidget(
                    hasUppercase: _hasUppercase,
                    hasLowercase: _hasLowercase,
                    hasNumeric: _hasNumeric,
                    hasSpecialChar: _hasSpecialChar,
                    hasMinLength: _hasMinLength,
                    hasMaxLength: _hasMaxLength,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  // Terms checkbox + link
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF0EA5C6),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isDark
                                    ? AppColorsDark.textSecondary
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                                fontFamily: 'Roboto',
                              ),
                              children: [
                                TextSpan(text: '${l10n.iAgreeToThe} '),
                                TextSpan(
                                  text: l10n.terms,
                                  style: TextStyle(
                                    color: AppColors.languageButtonColor,
                                    decoration: TextDecoration.underline,
                                    fontFamily: 'Roboto',
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final url = Uri.parse(
                                        'https://iammara.com/terms',
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.inAppWebView,
                                        );
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Loading message
                  if (_loadingMessage != null && _isSigningUp)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          const SpinningMaraLogo(
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadingMessage!,
                            style: TextStyle(
                              color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  // Error message with better visibility
                  // Use a key to ensure it's properly rendered
                  if (_errorMessage != null && _errorMessage!.isNotEmpty)
                    Padding(
                      key: const ValueKey('error_message'),
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showSignInOption) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Pre-fill email in sign-in screen
                                  final email = _emailController.text.trim();
                                  if (email.isNotEmpty) {
                                    ref.read(emailProvider.notifier).setEmail(email);
                                  }
                                  // Navigate to sign-in screen
                                  context.go('/welcome-back');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.languageButtonColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: AppColors.languageButtonColor.withOpacity(0.05),
                                ),
                                child: Text(
                                  'Sign in instead',
                                  style: TextStyle(
                                    color: AppColors.languageButtonColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // Verify button (width 320, height 52)
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: PrimaryButton(
                        text: _isSigningUp 
                            ? (_loadingMessage?.contains('server') ?? false 
                                ? 'Connecting...' 
                                : 'Signing up...')
                            : l10n.verify,
                        width: 320,
                        height: 52,
                        borderRadius: 20,
                        onPressed: (_agreedToTerms && _isPasswordValid && !_isSigningUp)
                            ? _onVerifyPressed
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // "Already a member ? Login"
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to Welcome Back screen
                        context.push('/welcome-back');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: '${l10n.alreadyAMember} ',
                          style: TextStyle(
                            color: isDark
                                ? AppColorsDark.textSecondary
                                : const Color(0xFF64748B),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(
                              text: l10n.login,
                              style: TextStyle(
                                color: AppColors.languageButtonColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementsWidget extends StatelessWidget {
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumeric;
  final bool hasSpecialChar;
  final bool hasMinLength;
  final bool hasMaxLength;
  final bool isDark;

  const _PasswordRequirementsWidget({
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumeric,
    required this.hasSpecialChar,
    required this.hasMinLength,
    required this.hasMaxLength,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.cardBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColorsDark.borderColor : const Color(0xFFE2E8F0),
            width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordRequirements,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
              text: l10n.atLeastOneUppercase,
              isMet: hasUppercase,
              isDark: isDark),
          const SizedBox(height: 6),
          _RequirementItem(
              text: l10n.atLeastOneLowercase,
              isMet: hasLowercase,
              isDark: isDark),
          const SizedBox(height: 6),
          _RequirementItem(
              text: l10n.atLeastOneNumber, isMet: hasNumeric, isDark: isDark),
          const SizedBox(height: 6),
          _RequirementItem(
            text: l10n.atLeastOneSpecialChar,
            isMet: hasSpecialChar,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: l10n.between8And4096Chars,
            isMet: hasMinLength && hasMaxLength,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;
  final bool isDark;

  const _RequirementItem({
    required this.text,
    required this.isMet,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMet
                ? AppColors.languageButtonColor
                : (isDark
                    ? AppColorsDark.borderColor
                    : const Color(0xFFE2E8F0)),
          ),
          child: isMet
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet
                  ? AppColors.languageButtonColor
                  : (isDark
                      ? AppColorsDark.textSecondary
                      : const Color(0xFF64748B)),
              fontFamily: 'Roboto',
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
