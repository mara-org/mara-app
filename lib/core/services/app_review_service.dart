import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

/// Abstract interface for app review and store listing functionality.
///
/// This abstraction allows for easy testing and potential future
/// implementation changes without affecting dependent code.
abstract class IAppReviewService {
  /// Checks if in-app review is available on the current platform.
  ///
  /// Returns `true` if the platform supports in-app review or store listing,
  /// `false` otherwise.
  Future<bool> isReviewAvailable();

  /// Opens the app's store listing page.
  ///
  /// On Android, opens Google Play Store.
  /// On iOS, opens App Store.
  ///
  /// If in-app review is not available, falls back to opening
  /// the store listing URL directly.
  ///
  /// Does not throw exceptions. Callers should handle UI feedback
  /// (e.g., show SnackBar) if the operation fails.
  Future<void> openStoreListing();
}

/// Implementation of [IAppReviewService] using [InAppReview] package.
///
/// This service handles opening the app store listing for rating/review.
/// It uses the `in_app_review` package when available, and falls back
/// to platform-specific URLs if needed.
class AppReviewService implements IAppReviewService {
  final InAppReview _inAppReview;

  /// Creates an [AppReviewService] instance.
  ///
  /// If [inAppReview] is not provided, uses [InAppReview.instance].
  AppReviewService({final InAppReview? inAppReview})
      : _inAppReview = inAppReview ?? InAppReview.instance;

  @override
  Future<bool> isReviewAvailable() async {
    try {
      // InAppReview is available on both iOS and Android
      return await _inAppReview.isAvailable();
    } on Exception catch (e) {
      // If check fails, we can still try to open store URL
      debugPrint('AppReviewService: Error checking review availability: $e');
      return false;
    }
  }

  @override
  Future<void> openStoreListing() async {
    try {
      // First, try to use in-app review if available
      final isAvailable = await isReviewAvailable();
      if (isAvailable) {
        await _inAppReview.openStoreListing();
        return;
      }
    } on Exception catch (e) {
      debugPrint(
        'AppReviewService: Error opening in-app review, falling back to URL: $e',
      );
    }

    // Fallback to platform-specific store URL
    try {
      final storeUrl = _getStoreUrl();
      final uri = Uri.parse(storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('AppReviewService: Could not launch store URL: $storeUrl');
      }
    } on Exception catch (e) {
      debugPrint('AppReviewService: Error opening store URL: $e');
      // Silently fail - caller should handle UI feedback
    }
  }

  /// Returns the platform-specific store URL.
  String _getStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id${AppConfig.iosAppId}';
    } else {
      // Web or other platforms - return a generic URL
      // In practice, this might not be used, but it's safe to have a fallback
      return 'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}';
    }
  }
}

