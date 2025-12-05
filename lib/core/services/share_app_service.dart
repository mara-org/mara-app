import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';

/// Abstract interface for sharing the app.
///
/// This abstraction allows for easy testing and potential future
/// implementation changes without affecting dependent code.
abstract class IShareAppService {
  /// Shares the app with a platform-aware store URL.
  ///
  /// Builds a share message with the appropriate store URL based on platform:
  /// - Android: uses Google Play Store URL
  /// - iOS: uses App Store URL
  /// - Fallback: uses public landing page URL
  ///
  /// The share message is localized using [AppLocalizations].
  ///
  /// Does not throw exceptions. Callers should handle UI feedback
  /// (e.g., show SnackBar) if the operation fails.
  Future<void> shareApp(AppLocalizations l10n);
}

/// Implementation of [IShareAppService] using [Share] package.
///
/// This service handles sharing the app with platform-aware store URLs.
/// It uses the `share_plus` package to open the native share sheet.
class ShareAppService implements IShareAppService {
  /// Creates a [ShareAppService] instance.
  ShareAppService();

  @override
  Future<void> shareApp(AppLocalizations l10n) async {
    try {
      final storeUrl = _getStoreUrl();
      final shareMessage = _buildShareMessage(l10n, storeUrl);

      await Share.share(shareMessage);
    } on Exception catch (e) {
      debugPrint('ShareAppService: Error sharing app: $e');
      // Silently fail - caller should handle UI feedback
      // Do not rethrow to prevent app crashes
    }
  }

  /// Returns the platform-specific store URL.
  ///
  /// Falls back to [AppConfig.publicLandingPageUrl] if store URLs
  /// are not yet configured.
  String _getStoreUrl() {
    if (Platform.isAndroid) {
      return AppConfig.androidStoreUrl;
    } else if (Platform.isIOS) {
      return AppConfig.iosStoreUrl;
    } else {
      // Web or other platforms - use landing page as fallback
      return AppConfig.publicLandingPageUrl;
    }
  }

  /// Builds the share message with the store URL.
  ///
  /// Uses the localized share message template and replaces {link}
  /// with the actual store URL.
  String _buildShareMessage(AppLocalizations l10n, String storeUrl) {
    return l10n.shareAppMessage(storeUrl);
  }
}

