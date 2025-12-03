import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/email_provider.dart';
import '../../../l10n/app_localizations.dart';

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
    _emailController.dispose();
    _passwordController.removeListener(_checkPasswordRequirements);
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

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      // Save the email before navigating
      final email = _emailController.text.trim();
      ref.read(emailProvider.notifier).setEmail(email);
      // Navigate to verify email screen, then ready screen
      context.go('/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
                  const Center(child: MaraLogo(width: 258, height: 202)),
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
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontFamily: 'Roboto',
                              ),
                              children: [
                                TextSpan(text: '${l10n.iAgreeToThe} '),
                                TextSpan(
                                  text: l10n.terms,
                                  style: const TextStyle(
                                    color: Color(0xFF0EA5C6),
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
                  // Verify button (width 320, height 52)
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: PrimaryButton(
                        text: l10n.verify,
                        width: 320,
                        height: 52,
                        borderRadius: 20,
                        onPressed: (_agreedToTerms && _isPasswordValid)
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
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                          children: [
                            TextSpan(
                              text: l10n.login,
                              style: const TextStyle(
                                color: Color(0xFF0EA5C6),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordRequirements,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(text: l10n.atLeastOneUppercase, isMet: hasUppercase),
          const SizedBox(height: 6),
          _RequirementItem(text: l10n.atLeastOneLowercase, isMet: hasLowercase),
          const SizedBox(height: 6),
          _RequirementItem(text: l10n.atLeastOneNumber, isMet: hasNumeric),
          const SizedBox(height: 6),
          _RequirementItem(
            text: l10n.atLeastOneSpecialChar,
            isMet: hasSpecialChar,
          ),
          const SizedBox(height: 6),
          _RequirementItem(
            text: l10n.between8And4096Chars,
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

  const _RequirementItem({required this.text, required this.isMet});

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
              ? const Icon(Icons.check, size: 12, color: Colors.white)
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
