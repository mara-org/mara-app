/// API response models for backend communication.

/// User information model
class UserInfo {
  final String id;
  final String firebaseUid;
  final String email;

  UserInfo({
    required this.id,
    required this.firebaseUid,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'email': email,
    };
  }
}

/// Session response from POST /v1/auth/session
class SessionResponse {
  final UserInfo user;
  final String plan; // "free" or "premium"
  final Map<String, dynamic> entitlements;
  final Map<String, int> limits;

  SessionResponse({
    required this.user,
    required this.plan,
    required this.entitlements,
    required this.limits,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      plan: json['plan'] as String? ?? 'free',
      entitlements: json['entitlements'] != null
          ? Map<String, dynamic>.from(json['entitlements'] as Map)
          : <String, dynamic>{},
      limits: json['limits'] != null
          ? Map<String, int>.from(
              (json['limits'] as Map).map(
                (k, v) => MapEntry(k, (v is int ? v : int.tryParse(v.toString()) ?? 0)),
              ),
            )
          : <String, int>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'plan': plan,
      'entitlements': entitlements,
      'limits': limits,
    };
  }
}

/// Current user response from GET /api/v1/auth/me
class MeResponse {
  final UserInfo user;
  final List<dynamic>? consents;

  MeResponse({
    required this.user,
    this.consents,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      consents: json['consents'] != null
          ? List<dynamic>.from(json['consents'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      if (consents != null) 'consents': consents,
    };
  }
}

/// Chat response from POST /api/v1/chat
class ChatResponse {
  final bool success;
  final String response;
  final List<String>? citations;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? remainingQuota;

  ChatResponse({
    required this.success,
    required this.response,
    this.citations,
    required this.metadata,
    this.usage,
    this.remainingQuota,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] as bool,
      response: json['response'] as String,
      citations: json['citations'] != null
          ? List<String>.from(json['citations'] as List)
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      usage: json['usage'] != null
          ? Map<String, dynamic>.from(json['usage'] as Map)
          : null,
      remainingQuota: json['remaining_quota'] != null
          ? Map<String, dynamic>.from(json['remaining_quota'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'response': response,
      if (citations != null) 'citations': citations,
      'metadata': metadata,
      if (usage != null) 'usage': usage,
      if (remainingQuota != null) 'remaining_quota': remainingQuota,
    };
  }
}

/// Onboarding completion response from POST /api/v1/user/profile/complete
class OnboardingResponse {
  final bool success;
  final String message;
  final String userId;
  final bool onboardingCompleted;

  OnboardingResponse({
    required this.success,
    required this.message,
    required this.userId,
    required this.onboardingCompleted,
  });

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      userId: json['user_id'] as String,
      onboardingCompleted: json['onboarding_completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user_id': userId,
      'onboarding_completed': onboardingCompleted,
    };
  }
}

/// User profile response from GET /api/v1/user/profile
class ProfileResponse {
  final Map<String, dynamic> profile;

  ProfileResponse({required this.profile});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      profile: Map<String, dynamic>.from(json['profile'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile,
    };
  }
}

