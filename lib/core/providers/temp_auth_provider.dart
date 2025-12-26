import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary authentication state (password storage during sign-up flow).
///
/// This provider stores the password temporarily during the sign-up process
/// so it can be used after email verification to sign in the user.
/// The password is cleared immediately after use for security.
class TempAuthState {
  final String? password;

  const TempAuthState({this.password});

  TempAuthState copyWith({String? password}) {
    return TempAuthState(password: password ?? this.password);
  }
}

class TempAuthNotifier extends StateNotifier<TempAuthState> {
  TempAuthNotifier() : super(const TempAuthState());

  /// Set the password temporarily.
  void setPassword(String password) {
    state = TempAuthState(password: password);
  }

  /// Clear the password for security.
  void clearPassword() {
    state = const TempAuthState();
  }
}

/// Provider for temporary authentication state.
final tempAuthProvider = StateNotifierProvider<TempAuthNotifier, TempAuthState>(
  (ref) {
    return TempAuthNotifier();
  },
);
