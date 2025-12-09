import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
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

  void _onResetPressed() {
    if (_formKey.currentState!.validate()) {
      // Navigate to home screen after password reset (replace all previous routes)
      context.go('/home');
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
                        color: AppColors.languageButtonColor
                            .withValues(alpha: 0.1),
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
                  const Center(child: MaraLogo(width: 258, height: 202)),
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
                        onPressed: _isPasswordValid ? _onResetPressed : null,
                      ),
                    ),
                  ),
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
