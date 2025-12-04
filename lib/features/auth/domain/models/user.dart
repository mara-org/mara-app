/// Domain model representing a user in the authentication context.
///
/// This is a domain model that contains business logic and validation.
/// It does not depend on any external frameworks or data sources.
class User {
  final String id;
  final String email;
  final String? displayName;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.isEmailVerified = false,
    this.createdAt,
  });

  /// Validates if the user model is valid.
  bool get isValid {
    return id.isNotEmpty && _isValidEmail(email);
  }

  /// Returns a display name for the user.
  ///
  /// Falls back to email if display name is not available.
  String get displayNameOrEmail => displayName ?? email;

  /// Checks if the email format is valid.
  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    // Basic email validation - can be enhanced
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Creates a copy of this user with updated fields.
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, isEmailVerified: $isEmailVerified)';
}

