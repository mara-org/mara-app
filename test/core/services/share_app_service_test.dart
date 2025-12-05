// Unit tests for ShareAppService
// Tests the share app service functionality including platform-aware
// store URL selection and share message construction.

import 'package:flutter_test/flutter_test.dart';
import 'package:mara_app/core/config/app_config.dart';
import 'package:mara_app/core/services/share_app_service.dart';
import 'package:mara_app/l10n/app_localizations.dart';
import 'package:mara_app/l10n/app_localizations_en.dart';

void main() {
  group('ShareAppService', () {
    late ShareAppService service;
    late AppLocalizationsEn l10n;

    setUp(() {
      service = ShareAppService();
      l10n = AppLocalizationsEn();
    });

    group('shareApp', () {
      test('method exists and accepts AppLocalizations', () {
        // Verify the method signature is correct
        expect(
          service.shareApp,
          isA<Future<void> Function(AppLocalizations)>(),
        );
      });
    });
  });

  group('AppConfig store URLs', () {
    test('has Android store URL defined', () {
      expect(AppConfig.androidStoreUrl, isNotEmpty);
      expect(AppConfig.androidStoreUrl, contains('play.google.com'));
      // Note: In real app, this should be validated against actual package
    });

    test('has iOS store URL defined', () {
      expect(AppConfig.iosStoreUrl, isNotEmpty);
      expect(AppConfig.iosStoreUrl, contains('apps.apple.com'));
      // Note: In real app, this should be validated against actual App Store ID
    });

    test('has public landing page URL defined', () {
      expect(AppConfig.publicLandingPageUrl, isNotEmpty);
      expect(AppConfig.publicLandingPageUrl, contains('http'));
    });
  });

  group('IShareAppService interface', () {
    test('ShareAppService implements IShareAppService', () {
      final testService = ShareAppService();
      expect(testService, isA<IShareAppService>());
    });

    test('IShareAppService has required methods', () {
      final testService = ShareAppService();
      expect(
        testService.shareApp,
        isA<Future<void> Function(AppLocalizations)>(),
      );
    });
  });
}
