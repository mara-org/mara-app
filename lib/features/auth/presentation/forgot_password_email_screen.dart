import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/providers/email_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/exceptions/rate_limit_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordEmailScreen extends ConsumerStatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  ConsumerState<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends ConsumerState<ForgotPasswordEmailScreen> {
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

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _onContinuePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save email for use in next screens
      ref.read(emailProvider.notifier).setEmail(email);
      
      // Use Firebase password reset email
      final success = await FirebaseAuthHelper.sendPasswordResetEmail(email);
      
      if (!mounted) return;
      
      if (success) {
        // Navigate to password reset link screen
        context.push('/password-reset-link');
      } else {
        setState(() {
          _errorMessage = 'Failed to send reset email. Please try again.';
        });
      }
    } on RateLimitException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Failed to send reset email. Please try again.';
      
      switch (e.code) {
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please wait a few minutes before trying again.';
          break;
        case 'user-not-found':
          // Don't reveal if user exists - show generic message
          errorMessage = 'If an account exists with this email, a password reset link has been sent.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      
      setState(() {
        _errorMessage = errorMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
                        color: AppColors.languageButtonColor
                            .withOpacity( 0.1),
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
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
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
                        onPressed: _isLoading ? null : _onContinuePressed,
                      ),
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: SpinningMaraLogo(width: 40, height: 40)),
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
