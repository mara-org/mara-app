/// Simple in-memory session storage.
///
/// Stores backend session data after Firebase sign-in.
/// Flutter only renders what backend sends - no client-side pricing/limits logic.
class AppSession {
  AppSession._();

  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  // Session data - stored exactly as backend sends
  Map<String, dynamic>? _user;
  String? _plan;
  Map<String, dynamic>? _entitlements;
  Map<String, dynamic>? _limits;
  String? _backendToken; // Backend session token (if used)

  /// Get user data.
  Map<String, dynamic>? get user => _user;

  /// Get plan (as sent by backend).
  String? get plan => _plan;

  /// Get entitlements (as sent by backend).
  Map<String, dynamic>? get entitlements => _entitlements;

  /// Get usage limits (as sent by backend).
  Map<String, dynamic>? get limits => _limits;

  /// Get backend session token.
  String? get backendToken => _backendToken;

  /// Check if user is on paid plan (from backend data).
  bool get isPaid => _plan == 'paid';

  /// Check if user has high quality mode (from backend entitlements).
  bool get hasHighQualityMode {
    if (_entitlements == null) return false;
    return _entitlements!['high_quality_mode'] == true ||
        _entitlements!['highQualityMode'] == true;
  }

  /// Check if user can send messages (from backend limits).
  bool get canSendMessages {
    if (_limits == null) return false;
    // Backend uses 'messages_remaining' field
    final remaining = _limits!['messages_remaining'] ??
        _limits!['remaining_messages_today'] ??
        _limits!['remainingMessagesToday'] ??
        0;
    return (remaining as num).toInt() > 0;
  }

  /// Set session data from backend response.
  ///
  /// Stores exactly what backend sends - no client-side logic.
  ///
  /// Backend response structure:
  /// {
  ///   "plan": "free" | "paid",
  ///   "limits": {
  ///     "messages_remaining": 10
  ///   },
  ///   "entitlements": {...},
  ///   "user": {...}
  /// }
  void setSession(Map<String, dynamic> data) {
    // Backend sends plan and limits at root level
    _plan = data['plan'] as String?;
    _limits = data['limits'] as Map<String, dynamic>?;
    _entitlements = data['entitlements'] as Map<String, dynamic>?;
    _user = data['user'] as Map<String, dynamic>?;
    _backendToken =
        data['token'] as String? ?? data['session_token'] as String?;
  }

  /// Clear session (on logout).
  void clear() {
    _user = null;
    _plan = null;
    _entitlements = null;
    _limits = null;
    _backendToken = null;
  }

  /// Check if session exists.
  bool get hasSession => _user != null;
}
