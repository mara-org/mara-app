import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/providers/email_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/datasources/auth_remote_data_source_impl.dart'
    show VerificationRateLimitException;

class ForgotPasswordVerifyScreen extends ConsumerStatefulWidget {
  const ForgotPasswordVerifyScreen({super.key});

  @override
  ConsumerState<ForgotPasswordVerifyScreen> createState() =>
      _ForgotPasswordVerifyScreenState();
}

class _ForgotPasswordVerifyScreenState
    extends ConsumerState<ForgotPasswordVerifyScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifying = false;
  String? _errorMessage;
  String? _resetToken; // Store reset token from backend

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify(AppLocalizations l10n) async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verifyEmailError)),
      );
      return;
    }

    final email = ref.read(emailProvider);
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please start over.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // NOTE: This screen is deprecated - using Firebase email links instead
      // The verifyPasswordResetCode method no longer exists in AuthRepository
      // This screen should not be accessible in production
      // For now, return false to prevent navigation
      final success = false;
      // final authRepository = ref.read(authRepositoryProvider);
      // final success = await authRepository.verifyPasswordResetCode(
      //   email: email,
      //   code: code,
      // );

      if (!mounted) return;

      if (success) {
        // Store reset token (backend should return it, but for now we'll use code as token)
        // TODO: Update when backend returns actual reset token
        _resetToken = code;

        // Navigate to reset password screen with token
        context.push('/reset-password', extra: {'resetToken': _resetToken});
      } else {
        setState(() {
          _errorMessage = 'Invalid code. Please try again.';
        });
        // Clear code inputs
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } on VerificationRateLimitException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                AppColors.languageButtonColor.withOpacity(0.1),
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
                    const Center(child: MaraLogo(width: 140, height: 99)),
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
                    l10n.forgotPasswordVerifySubtitle,
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
                const SizedBox(height: 40),
                // OTP input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 52,
                      height: 72,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          color: isDark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: isDark
                              ? AppColorsDark.cardBackground
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColorsDark.borderColor
                                  : AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColorsDark.borderColor
                                  : AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.languageButtonColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  const SizedBox(height: 20),
                ],
                // Verify button with gradient
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment(
                        0.0005944162257947028,
                        -0.15902137756347656,
                      ),
                      end: Alignment(6.022111415863037, 0.0005944162257947028),
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 50,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isVerifying ? null : () => _handleVerify(l10n),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: _isVerifying
                            ? const SpinningMaraLogo(
                                width: 32,
                                height: 32,
                              )
                            : Text(
                                l10n.verify,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  height: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
