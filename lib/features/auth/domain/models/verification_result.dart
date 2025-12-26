/// Result of email verification operations.
///
/// Provides detailed information about verification attempts,
/// including rate limit status and lockout information.
class VerificationResult {
  final bool isSuccess;
  final String? errorMessage;
  final VerificationErrorType? errorType;
  final int? remainingAttempts;
  final DateTime? lockoutUntil;
  final Duration? cooldownRemaining;

  const VerificationResult.success()
      : isSuccess = true,
        errorMessage = null,
        errorType = null,
        remainingAttempts = null,
        lockoutUntil = null,
        cooldownRemaining = null;

  const VerificationResult.failure(
    this.errorMessage,
    this.errorType, {
    this.remainingAttempts,
    this.lockoutUntil,
    this.cooldownRemaining,
  }) : isSuccess = false;

  factory VerificationResult.successResult() =>
      const VerificationResult.success();

  factory VerificationResult.failureResult(
    String message,
    VerificationErrorType type, {
    int? remainingAttempts,
    DateTime? lockoutUntil,
    Duration? cooldownRemaining,
  }) =>
      VerificationResult.failure(
        message,
        type,
        remainingAttempts: remainingAttempts,
        lockoutUntil: lockoutUntil,
        cooldownRemaining: cooldownRemaining,
      );

  /// Whether the user is currently locked out.
  bool get isLockedOut {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }

  /// Remaining lockout time if locked out.
  Duration? get remainingLockoutTime {
    if (!isLockedOut || lockoutUntil == null) return null;
    return lockoutUntil!.difference(DateTime.now());
  }
}

/// Types of verification errors.
enum VerificationErrorType {
  /// Invalid verification code.
  invalidCode,

  /// Code has expired.
  expiredCode,

  /// Too many attempts (rate limited).
  tooManyAttempts,

  /// Account is locked out.
  lockedOut,

  /// Cooldown period active (for resend).
  cooldownActive,

  /// Network error.
  networkError,

  /// Unknown error.
  unknown,
}
