import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? oobCode;

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password requirements state
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumeric = false;
  bool _hasSpecialChar = false;
  bool _hasMinLength = false;
  bool _hasMaxLength = true; // Always true initially since max is 4096
  bool _isResetting = false;
  String? _errorMessage;
  String? _oobCode; // Firebase out-of-band code from deep link

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
    // Use oobCode from widget parameter (passed from route)
    _oobCode = widget.oobCode;
    if (_oobCode == null || _oobCode!.isEmpty) {
      // If no oobCode, show error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Invalid or missing reset link. Please request a new password reset.';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordRequirements);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourPassword;
    }
    if (!_isPasswordValid) {
      return l10n.passwordDoesNotMeetRequirements;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseConfirmYourPassword;
    }
    if (value != _passwordController.text) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _onResetPressed() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate oobCode is present
    if (_oobCode == null || _oobCode!.isEmpty) {
      setState(() {
        _errorMessage =
            'Invalid or missing reset link. Please request a new password reset.';
      });
      return;
    }

    setState(() {
      _isResetting = true;
      _errorMessage = null;
    });

    try {
      // Use Firebase's confirmPasswordReset with the oobCode
      final success = await FirebaseAuthHelper.confirmPasswordReset(
        oobCode: _oobCode!,
        newPassword: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        // Clear email from provider
        ref.read(emailProvider.notifier).clearEmail();

        Logger.info(
          'Password reset successful',
          feature: 'auth',
          screen: 'reset_password_screen',
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully! Please sign in.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to sign-in screen
        context.go('/welcome-back');
      } else {
        setState(() {
          _errorMessage = 'Failed to reset password. Please try again.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to reset password. Please try again.';

      switch (e.code) {
        case 'expired-action-code':
          errorMessage =
              'This password reset link has expired. Please request a new one.';
          break;
        case 'invalid-action-code':
          errorMessage =
              'Invalid reset link. Please request a new password reset.';
          break;
        case 'weak-password':
          errorMessage =
              'Password is too weak. Please choose a stronger password.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }

      setState(() {
        _errorMessage = errorMessage;
      });

      Logger.error(
        'Password reset error: ${e.code}',
        feature: 'auth',
        screen: 'reset_password_screen',
        error: e,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });

      Logger.error(
        'Unexpected password reset error',
        feature: 'auth',
        screen: 'reset_password_screen',
        error: e,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
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
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.04),
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.languageButtonColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.languageButtonColor,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  // Mara logo at the top
                  const Center(child: MaraLogo(width: 140, height: 99)),
                  SizedBox(height: h * 0.04),
                  // Title
                  Text(
                    l10n.resetPasswordTitle,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.languageButtonColor,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    l10n.resetPasswordSubtitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      fontFamily: 'Roboto',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Password field
                  MaraTextField(
                    label: l10n.newPasswordLabel,
                    hint: l10n.newPasswordHint,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => _validatePassword(value, l10n),
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
                    l10n: l10n,
                    hasUppercase: _hasUppercase,
                    hasLowercase: _hasLowercase,
                    hasNumeric: _hasNumeric,
                    hasSpecialChar: _hasSpecialChar,
                    hasMinLength: _hasMinLength,
                    hasMaxLength: _hasMaxLength,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field
                  MaraTextField(
                    label: l10n.confirmPasswordLabel,
                    hint: l10n.confirmPasswordHint,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => _validateConfirmPassword(value, l10n),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  // Reset button
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: PrimaryButton(
                        text: l10n.resetPasswordButton,
                        width: 320,
                        height: 52,
                        borderRadius: 20,
                        onPressed: (_isPasswordValid && !_isResetting)
                            ? _onResetPressed
                            : null,
                      ),
                    ),
                  ),
                  if (_isResetting) ...[
                    const SizedBox(height: 16),
                    const Center(
                        child: SpinningMaraLogo(width: 40, height: 40)),
                  ],
                  const SizedBox(height: 24),
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
  final AppLocalizations l10n;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumeric;
  final bool hasSpecialChar;
  final bool hasMinLength;
  final bool hasMaxLength;
  final bool isDark;

  const _PasswordRequirementsWidget({
    required this.l10n,
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
