import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_code_input.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/datasources/auth_remote_data_source_impl.dart'
    show VerificationRateLimitException, VerificationCooldownException;

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _codeLength = 6;
  static const int _maxAttempts = 5;
  static const int _cooldownSeconds = 60;
  
  final GlobalKey<MaraCodeInputState> _codeInputKey =
      GlobalKey<MaraCodeInputState>();
  String _code = '';
  bool _isVerifying = false;
  bool _isResending = false;
  int _verificationAttempts = 0;
  DateTime? _lastResendTime;
  DateTime? _lockoutUntil;
  Timer? _cooldownTimer;
  Timer? _lockoutTimer;
  int _cooldownRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastResendTime != null) {
        final elapsed = DateTime.now().difference(_lastResendTime!);
        final remaining = _cooldownSeconds - elapsed.inSeconds;
        
        if (remaining > 0) {
          setState(() {
            _cooldownRemaining = remaining;
          });
        } else {
          setState(() {
            _cooldownRemaining = 0;
          });
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startLockoutTimer(DateTime lockoutUntil) {
    _lockoutTimer?.cancel();
    _lockoutUntil = lockoutUntil;
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
        setState(() {});
      } else {
        setState(() {
          _lockoutUntil = null;
        });
        timer.cancel();
      }
    });
  }

  bool get _isCodeComplete => _code.length == _codeLength;
  bool get _isCooldownActive => _cooldownRemaining > 0;
  bool get _isLockedOut => _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);
  bool get _canResend => !_isResending && !_isCooldownActive;
  bool get _canVerify => _isCodeComplete && !_isVerifying && !_isLockedOut;

  Duration? get _remainingLockoutTime {
    if (!_isLockedOut || _lockoutUntil == null) return null;
    return _lockoutUntil!.difference(DateTime.now());
  }

  Future<void> _handleVerify() async {
    if (!_canVerify) return;
    
    final authRepository = ref.read(authRepositoryProvider);
    
    setState(() {
      _isVerifying = true;
    });

    try {
      final success = await authRepository.verifyEmailCode(_code);
      
      if (!mounted) return;
      
      if (success) {
        // Success - navigate to ready screen
        context.go('/ready');
      } else {
        // Failed verification
        setState(() {
          _verificationAttempts++;
        });
        
        // Check if locked out (5 attempts)
        if (_verificationAttempts >= _maxAttempts) {
          final lockoutUntil = DateTime.now().add(const Duration(minutes: 10));
          _startLockoutTimer(lockoutUntil);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Too many attempts. Please try again in 10 minutes.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          // Show remaining attempts
          final remaining = _maxAttempts - _verificationAttempts;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid code. $remaining ${remaining == 1 ? 'attempt' : 'attempts'} remaining.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          
          // Clear code input
          _codeInputKey.currentState?.clear();
          setState(() {
            _code = '';
          });
        }
      }
    } on VerificationRateLimitException catch (e) {
      // Handle rate limit from backend
      if (!mounted) return;
      
      if (e.lockoutUntil != null) {
        _startLockoutTimer(e.lockoutUntil!);
      }
      
      final message = e.remainingAttempts != null
          ? 'Too many attempts. ${e.remainingAttempts} ${e.remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining.'
          : e.message;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    
    final authRepository = ref.read(authRepositoryProvider);
    
    setState(() {
      _isResending = true;
    });

    try {
      final success = await authRepository.resendVerificationCode();
      
      if (!mounted) return;
      
      if (success) {
        // Success - start cooldown
        setState(() {
          _lastResendTime = DateTime.now();
          _cooldownRemaining = _cooldownSeconds;
        });
        _startCooldownTimer();
        
        // Unified success message (doesn't reveal if email exists)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'If the email exists, a verification code has been sent.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'If the email exists, a verification code has been sent.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on VerificationCooldownException catch (e) {
      // Handle cooldown from backend
      if (!mounted) return;
      
      final cooldownSeconds = e.cooldownSeconds;
      if (e.cooldownUntil != null) {
        final remaining = e.cooldownUntil!.difference(DateTime.now());
        setState(() {
          _lastResendTime = DateTime.now().subtract(
            Duration(seconds: _cooldownSeconds - remaining.inSeconds),
          );
          _cooldownRemaining = remaining.inSeconds.clamp(0, _cooldownSeconds);
        });
      } else {
        setState(() {
          _lastResendTime = DateTime.now();
          _cooldownRemaining = cooldownSeconds;
        });
      }
      _startCooldownTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait ${cooldownSeconds} seconds before requesting another code.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Unified message (doesn't reveal if email exists)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'If the email exists, a verification code has been sent.',
          ),
          backgroundColor: Colors.green,
        ),
      );
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
                // Attempt counter or lockout warning
                if (_verificationAttempts > 0 && !_isLockedOut)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${_maxAttempts - _verificationAttempts} ${_maxAttempts - _verificationAttempts == 1 ? 'attempt' : 'attempts'} remaining',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (_isLockedOut && _remainingLockoutTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Locked out. Try again in ${_remainingLockoutTime!.inMinutes}m ${_remainingLockoutTime!.inSeconds % 60}s',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                // OTP input boxes
                AutofillGroup(
                  child: Opacity(
                    opacity: _isLockedOut ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isLockedOut,
                      child: MaraCodeInput(
                        key: _codeInputKey,
                        length: _codeLength,
                        onChanged: (final value) {
                          setState(() {
                            _code = value;
                          });
                        },
                        onCompleted: (final value) {
                          setState(() {
                            _code = value;
                          });
                          if (_canVerify) {
                            _handleVerify();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                // Resend button with cooldown
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _isCooldownActive
                      ? Text(
                          'Resend code in ${_cooldownRemaining}s',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        )
                      : TextButton(
                          onPressed: _canResend ? _resendCode : null,
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
                                    color: _canResend
                                        ? AppColors.languageButtonColor
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                ),
                const SizedBox(height: 40),
                // Verify button with gradient
                Opacity(
                  opacity: _canVerify ? 1 : 0.5,
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
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.25),
                          offset: const Offset(0, 4),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _canVerify ? _handleVerify : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
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
