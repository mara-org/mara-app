/// App capabilities model representing user's profile, plan, entitlements, and limits.
///
/// This is the single source of truth for user capabilities after backend session creation.
class AppCapabilities {
  /// User profile information.
  final UserProfile profile;

  /// User's subscription plan: "free" or "paid".
  final String plan;

  /// User entitlements (features they have access to).
  final Entitlements entitlements;

  /// Usage limits for the user.
  final UsageLimits limits;

  AppCapabilities({
    required this.profile,
    required this.plan,
    required this.entitlements,
    required this.limits,
  });

  /// Create from backend session response JSON.
  factory AppCapabilities.fromJson(Map<String, dynamic> json) {
    return AppCapabilities(
      profile: UserProfile.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
      plan: json['plan'] as String? ?? 'free',
      entitlements: Entitlements.fromJson(
        json['entitlements'] as Map<String, dynamic>? ?? {},
      ),
      limits: UsageLimits.fromJson(
        json['limits'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Convert to JSON (for caching/testing).
  Map<String, dynamic> toJson() {
    return {
      'user': profile.toJson(),
      'plan': plan,
      'entitlements': entitlements.toJson(),
      'limits': limits.toJson(),
    };
  }

  /// Create copy with updated fields.
  AppCapabilities copyWith({
    UserProfile? profile,
    String? plan,
    Entitlements? entitlements,
    UsageLimits? limits,
  }) {
    return AppCapabilities(
      profile: profile ?? this.profile,
      plan: plan ?? this.plan,
      entitlements: entitlements ?? this.entitlements,
      limits: limits ?? this.limits,
    );
  }

  /// Check if user is on paid plan.
  bool get isPaid => plan == 'paid';

  /// Check if user has high quality mode access.
  bool get hasHighQualityMode => entitlements.highQualityMode;

  /// Check if user can send messages (has remaining quota).
  bool get canSendMessages => limits.remainingMessagesToday > 0;
}

/// User profile information from backend.
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? fullName;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.fullName,
    this.isEmailVerified = false,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['display_name'] as String?,
      fullName: json['full_name'] as String? ?? json['fullName'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? json['is_email_verified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : (json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'] as String)
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (fullName != null) 'full_name': fullName,
      'isEmailVerified': isEmailVerified,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
    };
  }
}

/// User entitlements (features they have access to).
class Entitlements {
  /// Whether user has access to high quality mode.
  final bool highQualityMode;

  /// Whether user has access to advanced analytics.
  final bool advancedAnalytics;

  /// Whether user has access to priority support.
  final bool prioritySupport;

  /// Additional feature flags.
  final Map<String, bool> features;

  Entitlements({
    this.highQualityMode = false,
    this.advancedAnalytics = false,
    this.prioritySupport = false,
    Map<String, bool>? features,
  }) : features = features ?? {};

  factory Entitlements.fromJson(Map<String, dynamic> json) {
    return Entitlements(
      highQualityMode: json['high_quality_mode'] as bool? ?? json['highQualityMode'] as bool? ?? false,
      advancedAnalytics: json['advanced_analytics'] as bool? ?? json['advancedAnalytics'] as bool? ?? false,
      prioritySupport: json['priority_support'] as bool? ?? json['prioritySupport'] as bool? ?? false,
      features: Map<String, bool>.from(
        json['features'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'high_quality_mode': highQualityMode,
      'advanced_analytics': advancedAnalytics,
      'priority_support': prioritySupport,
      'features': features,
    };
  }
}

/// Usage limits for the user.
class UsageLimits {
  /// Remaining messages for today.
  final int remainingMessagesToday;

  /// Remaining token budget for today.
  final int remainingTokenBudgetToday;

  /// Daily message limit.
  final int dailyMessageLimit;

  /// Daily token budget limit.
  final int dailyTokenBudgetLimit;

  UsageLimits({
    this.remainingMessagesToday = 0,
    this.remainingTokenBudgetToday = 0,
    this.dailyMessageLimit = 0,
    this.dailyTokenBudgetLimit = 0,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      remainingMessagesToday: (json['remaining_messages_today'] as num?)?.toInt() ?? 0,
      remainingTokenBudgetToday: (json['remaining_token_budget_today'] as num?)?.toInt() ?? 0,
      dailyMessageLimit: (json['daily_message_limit'] as num?)?.toInt() ?? 0,
      dailyTokenBudgetLimit: (json['daily_token_budget_limit'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remaining_messages_today': remainingMessagesToday,
      'remaining_token_budget_today': remainingTokenBudgetToday,
      'daily_message_limit': dailyMessageLimit,
      'daily_token_budget_limit': dailyTokenBudgetLimit,
    };
  }

  /// Check if user has exhausted their message quota.
  bool get isMessageQuotaExhausted => remainingMessagesToday <= 0;

  /// Check if user has exhausted their token budget.
  bool get isTokenQuotaExhausted => remainingTokenBudgetToday <= 0;
}

