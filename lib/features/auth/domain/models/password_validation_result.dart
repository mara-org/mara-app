/// Result of password validation.
///
/// Domain model for password validation with business rules.
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final PasswordStrength strength;

  const PasswordValidationResult._(
    this.isValid,
    this.errors,
    this.strength,
  );

  /// Valid password.
  factory PasswordValidationResult.valid(PasswordStrength strength) =>
      PasswordValidationResult._(true, const [], strength);

  /// Invalid password with error messages.
  factory PasswordValidationResult.invalid(List<String> errors) =>
      PasswordValidationResult._(
        false,
        errors,
        PasswordStrength.weak,
      );

  /// Validates a password according to business rules.
  ///
  /// Returns a validation result indicating if the password is valid
  /// and providing error messages if invalid.
  static PasswordValidationResult validate(String password) {
    final errors = <String>[];

    if (password.isEmpty) {
      return PasswordValidationResult.invalid(['Password cannot be empty']);
    }

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters');
    }

    if (password.length > 4096) {
      errors.add('Password must be at most 4096 characters');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    if (!password.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      errors.add('Password must contain at least one special character');
    }

    if (errors.isNotEmpty) {
      return PasswordValidationResult.invalid(errors);
    }

    // Determine password strength
    final strength = _calculateStrength(password);

    return PasswordValidationResult.valid(strength);
  }

  /// Calculates password strength based on length and complexity.
  static PasswordStrength _calculateStrength(String password) {
    if (password.length >= 16) {
      return PasswordStrength.strong;
    } else if (password.length >= 12) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }
}

/// Password strength levels.
enum PasswordStrength {
  weak,
  medium,
  strong,
}
