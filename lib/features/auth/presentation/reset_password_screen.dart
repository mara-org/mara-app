import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (!_isPasswordValid) {
      return 'Password does not meet all requirements';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                  const Center(
                    child: MaraLogo(
                      width: 258,
                      height: 202,
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  // Title
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.languageButtonColor,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    'Enter your new password below',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Roboto',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Password field
                  MaraTextField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
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
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field
                  MaraTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your new password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
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
                        text: 'Reset Password',
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
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumeric;
  final bool hasSpecialChar;
  final bool hasMinLength;
  final bool hasMaxLength;

  const _PasswordRequirementsWidget({
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumeric,
    required this.hasSpecialChar,
    required this.hasMinLength,
    required this.hasMaxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Password Requirements',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'At least one uppercase letter',
            isMet: hasUppercase,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: 'At least one lowercase letter',
            isMet: hasLowercase,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: 'At least one number',
            isMet: hasNumeric,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: 'At least one special character',
            isMet: hasSpecialChar,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: 'Between 8 and 4096 characters',
            isMet: hasMinLength && hasMaxLength,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
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
            color: isMet ? const Color(0xFF0EA5C6) : const Color(0xFFE2E8F0),
          ),
          child: isMet
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? const Color(0xFF0EA5C6) : const Color(0xFF64748B),
              fontFamily: 'Roboto',
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

