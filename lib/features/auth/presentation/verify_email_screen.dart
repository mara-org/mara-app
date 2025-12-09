import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_code_input.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _codeLength = 6;
  final GlobalKey<MaraCodeInputState> _codeInputKey =
      GlobalKey<MaraCodeInputState>();
  String _code = '';
  bool _isResending = false;

  bool get _isCodeComplete => _code.length == _codeLength;

  void _handleVerify() {
    final l10n = AppLocalizations.of(context)!;
    if (_isCodeComplete) {
      context.go('/ready');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.verifyEmailError)));
    }
  }

  Future<void> _resendCode() async {
    if (_isResending) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isResending = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _isResending = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.resendCodeSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColorsDark.backgroundLight
          : AppColors.backgroundLight,
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
                            color: AppColors.languageButtonColor.withValues(
                              alpha: 0.1,
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
                    const Center(child: MaraLogo(width: 258, height: 202)),
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
                      l10n.verifyEmailSubtitleFull,
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
                AutofillGroup(
                  child: MaraCodeInput(
                    key: _codeInputKey,
                    length: _codeLength,
                    onChanged: (value) {
                      setState(() {
                        _code = value;
                      });
                    },
                    onCompleted: (value) {
                      setState(() {
                        _code = value;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: _isResending
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.resendCodeButton,
                          style: TextStyle(
                            color: AppColors.languageButtonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
                // Verify button with gradient
                Opacity(
                  opacity: _isCodeComplete ? 1 : 0.5,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: const Alignment(
                          0.0005944162257947028,
                          -0.15902137756347656,
                        ),
                        end: const Alignment(
                          6.022111415863037,
                          0.0005944162257947028,
                        ),
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: isDark ? 0.4 : 0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isCodeComplete ? _handleVerify : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
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
