import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/core/models/app_capabilities.dart';

void main() {
  group('AppCapabilities', () {
    test('should parse complete session response', () {
      final json = {
        'user': {
          'id': 'user-123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'full_name': 'Test User Full',
          'isEmailVerified': true,
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-02T00:00:00Z',
          'lastLoginAt': '2024-01-03T00:00:00Z',
        },
        'plan': 'paid',
        'entitlements': {
          'high_quality_mode': true,
          'advanced_analytics': true,
          'priority_support': true,
          'features': {
            'feature1': true,
            'feature2': false,
          },
        },
        'limits': {
          'remaining_messages_today': 10,
          'remaining_token_budget_today': 1000,
          'daily_message_limit': 20,
          'daily_token_budget_limit': 2000,
        },
      };

      final capabilities = AppCapabilities.fromJson(json);

      expect(capabilities.profile.id, 'user-123');
      expect(capabilities.profile.email, 'test@example.com');
      expect(capabilities.profile.displayName, 'Test User');
      expect(capabilities.profile.fullName, 'Test User Full');
      expect(capabilities.profile.isEmailVerified, true);
      expect(capabilities.plan, 'paid');
      expect(capabilities.isPaid, true);
      expect(capabilities.hasHighQualityMode, true);
      expect(capabilities.entitlements.highQualityMode, true);
      expect(capabilities.entitlements.advancedAnalytics, true);
      expect(capabilities.entitlements.prioritySupport, true);
      expect(capabilities.limits.remainingMessagesToday, 10);
      expect(capabilities.limits.remainingTokenBudgetToday, 1000);
      expect(capabilities.limits.dailyMessageLimit, 20);
      expect(capabilities.limits.dailyTokenBudgetLimit, 2000);
      expect(capabilities.canSendMessages, true);
    });

    test('should handle missing optional fields', () {
      final json = {
        'user': {
          'id': 'user-123',
          'email': 'test@example.com',
        },
        'plan': 'free',
        'entitlements': {},
        'limits': {},
      };

      final capabilities = AppCapabilities.fromJson(json);

      expect(capabilities.profile.id, 'user-123');
      expect(capabilities.profile.email, 'test@example.com');
      expect(capabilities.profile.displayName, isNull);
      expect(capabilities.profile.isEmailVerified, false);
      expect(capabilities.plan, 'free');
      expect(capabilities.isPaid, false);
      expect(capabilities.hasHighQualityMode, false);
      expect(capabilities.entitlements.highQualityMode, false);
      expect(capabilities.limits.remainingMessagesToday, 0);
      expect(capabilities.canSendMessages, false);
    });

    test('should handle snake_case and camelCase field names', () {
      final json = {
        'user': {
          'id': 'user-123',
          'email': 'test@example.com',
          'display_name': 'Snake Case Name',
          'is_email_verified': true,
          'created_at': '2024-01-01T00:00:00Z',
        },
        'plan': 'paid',
        'entitlements': {
          'high_quality_mode': true,
        },
        'limits': {
          'remaining_messages_today': 5,
        },
      };

      final capabilities = AppCapabilities.fromJson(json);

      expect(capabilities.profile.displayName, 'Snake Case Name');
      expect(capabilities.profile.isEmailVerified, true);
      expect(capabilities.entitlements.highQualityMode, true);
      expect(capabilities.limits.remainingMessagesToday, 5);
    });

    test('should check quota exhaustion correctly', () {
      final capabilities = AppCapabilities(
        profile: UserProfile(id: '1', email: 'test@example.com'),
        plan: 'free',
        entitlements: Entitlements(),
        limits: UsageLimits(
          remainingMessagesToday: 0,
          remainingTokenBudgetToday: 0,
        ),
      );

      expect(capabilities.canSendMessages, false);
      expect(capabilities.limits.isMessageQuotaExhausted, true);
      expect(capabilities.limits.isTokenQuotaExhausted, true);
    });

    test('should create copy with updated fields', () {
      final original = AppCapabilities(
        profile: UserProfile(id: '1', email: 'test@example.com'),
        plan: 'free',
        entitlements: Entitlements(),
        limits: UsageLimits(remainingMessagesToday: 10),
      );

      final updated = original.copyWith(
        plan: 'paid',
        limits: UsageLimits(remainingMessagesToday: 5),
      );

      expect(updated.plan, 'paid');
      expect(updated.isPaid, true);
      expect(updated.limits.remainingMessagesToday, 5);
      expect(original.plan, 'free'); // Original unchanged
    });
  });

  group('UserProfile', () {
    test('should parse user profile correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'isEmailVerified': true,
        'createdAt': '2024-01-01T00:00:00Z',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user-123');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.isEmailVerified, true);
      expect(profile.createdAt, isNotNull);
    });
  });

  group('Entitlements', () {
    test('should parse entitlements correctly', () {
      final json = {
        'high_quality_mode': true,
        'advanced_analytics': true,
        'priority_support': true,
        'features': {
          'feature1': true,
          'feature2': false,
        },
      };

      final entitlements = Entitlements.fromJson(json);

      expect(entitlements.highQualityMode, true);
      expect(entitlements.advancedAnalytics, true);
      expect(entitlements.prioritySupport, true);
      expect(entitlements.features['feature1'], true);
      expect(entitlements.features['feature2'], false);
    });
  });

  group('UsageLimits', () {
    test('should parse usage limits correctly', () {
      final json = {
        'remaining_messages_today': 10,
        'remaining_token_budget_today': 1000,
        'daily_message_limit': 20,
        'daily_token_budget_limit': 2000,
      };

      final limits = UsageLimits.fromJson(json);

      expect(limits.remainingMessagesToday, 10);
      expect(limits.remainingTokenBudgetToday, 1000);
      expect(limits.dailyMessageLimit, 20);
      expect(limits.dailyTokenBudgetLimit, 2000);
      expect(limits.isMessageQuotaExhausted, false);
      expect(limits.isTokenQuotaExhausted, false);
    });

    test('should detect exhausted quota', () {
      final limits = UsageLimits(
        remainingMessagesToday: 0,
        remainingTokenBudgetToday: 0,
      );

      expect(limits.isMessageQuotaExhausted, true);
      expect(limits.isTokenQuotaExhausted, true);
    });
  });
}

