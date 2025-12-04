# Fastlane Configuration for Mara App

This directory contains Fastlane configuration for building Play Store and App Store releases.

## Setup

### Prerequisites

1. **Ruby and Bundler:**
   ```bash
   gem install bundler
   bundle install
   ```

2. **Fastlane:**
   ```bash
   bundle exec fastlane --version
   ```

3. **Flutter:**
   - Flutter SDK must be installed and in PATH
   - Run `flutter doctor` to verify setup

### Android Setup

1. **Keystore Configuration:**
   - Keystore should be stored as GitHub Secret: `ANDROID_KEYSTORE_BASE64`
   - Key alias: `ANDROID_KEY_ALIAS`
   - Passwords: `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`

2. **Build AAB:**
   ```bash
   bundle exec fastlane android build_aab
   ```

3. **Build APK:**
   ```bash
   bundle exec fastlane android build_apk
   ```

### iOS Setup

1. **Code Signing:**
   - Requires Xcode and Apple Developer account
   - Certificates and provisioning profiles must be configured
   - This is typically done via Xcode or Fastlane match

2. **Build IPA:**
   ```bash
   bundle exec fastlane ios build_ipa
   ```

## CI/CD Integration

The `.github/workflows/store-build.yml` workflow uses these Fastlane lanes to build store-ready artifacts.

## Notes

- **Frontend-only:** This Fastfile only builds artifacts, does NOT upload to stores
- **Credentials:** Store credentials should be configured separately (not in this repo)
- **Signing:** Android signing is handled in CI workflows, iOS requires Xcode setup

