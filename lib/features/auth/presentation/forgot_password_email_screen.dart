import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() => _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourEmail;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return l10n.pleaseEnterValidEmail;
    }
    return null;
  }

  void _onContinuePressed() {
    if (_formKey.currentState!.validate()) {
      // Navigate to verify email screen for password reset
      context.push('/forgot-password-verify');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                  const Center(
                    child: MaraLogo(
                      width: 258,
                      height: 202,
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  // Title
                  Text(
                    l10n.forgotPasswordTitle,
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
                    l10n.forgotPasswordSubtitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontFamily: 'Roboto',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Email field
                  MaraTextField(
                    label: l10n.emailLabel,
                    hint: l10n.enterYourEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _validateEmail(value, l10n),
                  ),
                  const SizedBox(height: 32),
                  // Continue button
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 52,
                      child: PrimaryButton(
                        text: l10n.continueButton,
                        width: 320,
                        height: 52,
                        borderRadius: 20,
                        onPressed: _onContinuePressed,
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

