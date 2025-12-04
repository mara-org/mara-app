/// Result of email validation.
///
/// Domain model for email validation with business rules.
class EmailValidationResult {
  final bool isValid;
  final String? errorMessage;

  const EmailValidationResult._(this.isValid, this.errorMessage);

  /// Valid email.
  factory EmailValidationResult.valid() =>
      const EmailValidationResult._(true, null);

  /// Invalid email with error message.
  factory EmailValidationResult.invalid(String message) =>
      EmailValidationResult._(false, message);

  /// Validates an email address according to business rules.
  ///
  /// Returns a validation result indicating if the email is valid
  /// and providing an error message if invalid.
  static EmailValidationResult validate(String email) {
    if (email.isEmpty) {
      return EmailValidationResult.invalid('Email cannot be empty');
    }

    // Basic email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return EmailValidationResult.invalid('Invalid email format');
    }

    // Additional business rules can be added here
    // e.g., domain whitelist, length limits, etc.

    return EmailValidationResult.valid();
  }
}

