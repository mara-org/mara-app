/// Application configuration constants.
///
/// This file contains non-sensitive configuration values used throughout the app.
/// For sensitive values (API keys, secrets), use environment variables or
/// secure storage.
class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  /// Android package name for Google Play Store.
  ///
  /// TODO: Replace with actual package name when app is published.
  /// Example: 'com.mara.app'
  static const String androidPackageName = 'com.mara.app';

  /// iOS App Store ID.
  ///
  /// TODO: Replace with actual App Store ID when app is published.
  /// Example: '1234567890'
  /// You can find this in App Store Connect or by searching for your app.
  static const String iosAppId = '1234567890';

  /// Android Google Play Store URL.
  ///
  /// TODO: Replace with actual package ID when app is published.
  /// Example: 'https://play.google.com/store/apps/details?id=com.mara.app'
  static const String androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.mara.app';

  /// iOS App Store URL.
  ///
  /// TODO: Replace with actual App Store ID when app is published.
  /// Example: 'https://apps.apple.com/app/id1234567890'
  static const String iosStoreUrl = 'https://apps.apple.com/app/id1234567890';

  /// Public landing page URL.
  ///
  /// Used as a fallback if store-specific URLs are not yet configured.
  /// TODO: Adjust if the actual landing page URL differs.
  static const String publicLandingPageUrl = 'https://mara.health';
}

