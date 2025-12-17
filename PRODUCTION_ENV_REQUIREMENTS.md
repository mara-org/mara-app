# iOS Production Environment Requirements

This document lists all environment variables, API keys, and configurations needed for iOS production builds in Apple Developer Portal with Firebase integration.

## 🔑 Required Environment Variables (via --dart-define)

These must be provided when building for production:

### 1. **API_BASE_URL** (REQUIRED)
- **Description**: Backend API base URL
- **Format**: `https://api.yourdomain.com`
- **Example**: `--dart-define=API_BASE_URL=https://api.mara.app`
- **Required for**: All API calls (auth, chat, health data sync)
- **Note**: Must use HTTPS in production (HTTP only allowed in debug mode)

### 2. **ENABLE_CRASH_REPORTING** (Optional)
- **Description**: Enable Sentry crash reporting
- **Format**: `true` or `false`
- **Default**: `false`
- **Example**: `--dart-define=ENABLE_CRASH_REPORTING=true`
- **Required for**: Crash reporting and error tracking

### 3. **SENTRY_DSN** (Required if ENABLE_CRASH_REPORTING=true)
- **Description**: Sentry DSN for crash reporting
- **Format**: `https://xxx@sentry.io/xxx`
- **Example**: `--dart-define=SENTRY_DSN=https://abc123@o123456.ingest.sentry.io/123456`
- **Required for**: Sentry integration

### 4. **ENABLE_ANALYTICS** (Optional)
- **Description**: Enable Firebase Analytics
- **Format**: `true` or `false`
- **Default**: `false`
- **Example**: `--dart-define=ENABLE_ANALYTICS=true`
- **Required for**: User analytics and behavior tracking

### 5. **FIREBASE_PROJECT_ID** (Optional)
- **Description**: Firebase project ID (usually auto-detected from firebase_options.dart)
- **Format**: `your-project-id`
- **Example**: `--dart-define=FIREBASE_PROJECT_ID=mara-6c4f8`
- **Required for**: Firebase services override (if needed)

## 📱 iOS (Apple Developer Portal) Requirements

### 1. **App ID Configuration**
- **Bundle Identifier**: `com.iammara.maraApp`
- **Capabilities Required**:
  - ✅ **HealthKit** (for health data access)
  - ✅ **Push Notifications** (for health reminders)
  - ✅ **Sign in with Apple** (for authentication)
  - ✅ **Associated Domains** (if using universal links)

### 2. **HealthKit Entitlements** ✅ CONFIGURED
- **File**: `ios/Runner/Runner.entitlements` ✅ EXISTS
- **Status**: Already configured with HealthKit access
- **Contains**:
  - ✅ `com.apple.developer.healthkit` = `true`
  - ✅ `com.apple.developer.healthkit.access` = `health-records`
  - ✅ `com.apple.developer.applesignin` = `Default`
  - ✅ `aps-environment` = `production`

**Health Data Types Required**:
- Steps (HKQuantityTypeIdentifierStepCount)
- Sleep Analysis (HKCategoryTypeIdentifierSleepAnalysis)
- Heart Rate (HKQuantityTypeIdentifierHeartRate)
- Active Energy (HKQuantityTypeIdentifierActiveEnergyBurned)
- Distance Walking/Running (HKQuantityTypeIdentifierDistanceWalkingRunning)

### 3. **Info.plist Permissions** ✅ CONFIGURED
- ✅ `NSHealthShareUsageDescription`: "Mara needs access to your health data to provide personalized health insights."
- ✅ `NSHealthUpdateUsageDescription`: "Mara needs to save your health data to track your progress."
- ✅ `NSCameraUsageDescription`: "Mara needs camera access for facial expression analysis and fatigue detection."
- ✅ `NSMicrophoneUsageDescription`: "Mara needs microphone access for voice input and natural conversation."
- ✅ `NSFaceIDUsageDescription`: "Mara uses Face ID to securely authenticate you."

### 4. **Firebase Configuration** ✅ CONFIGURED
- **File**: `ios/Runner/GoogleService-Info.plist` ✅ EXISTS
- **Status**: Already configured with Firebase project `mara-6c4f8`
- **Bundle ID**: `com.iammara.maraApp`
- **Project ID**: `mara-6c4f8`
- **Contains**:
  - ✅ `CLIENT_ID`
  - ✅ `REVERSED_CLIENT_ID`
  - ✅ `API_KEY`
  - ✅ `GCM_SENDER_ID`
  - ✅ `BUNDLE_ID`: `com.iammara.maraApp`
  - ✅ `PROJECT_ID`: `mara-6c4f8`
  - ✅ `STORAGE_BUCKET`
  - ✅ `GOOGLE_APP_ID`
- **Note**: File is properly excluded from git (in `.gitignore`)

### 5. **Provisioning Profiles**
- **Development**: For testing on devices
- **Distribution**: For App Store submission
- **Capabilities**: Must include HealthKit, Push Notifications, Sign in with Apple

### 6. **App Store Connect**
- **Privacy Policy URL**: Required for health data apps
- **Health Data Usage Description**: Must match Info.plist description
- **App Privacy Details**: Declare health data collection

## 🔥 Firebase Console Setup

### Required Services:
1. **Firebase Authentication**
   - ✅ Enable Email/Password
   - ✅ Enable Google Sign-In
   - ✅ Enable Apple Sign-In (iOS)
   - Configure OAuth redirect URLs

2. **Firebase Analytics** (Optional)
   - Enable in Firebase Console
   - Set via `ENABLE_ANALYTICS=true`

3. **Firebase Crashlytics** (Optional)
   - Enable in Firebase Console
   - Automatically enabled if Firebase is initialized

4. **Firebase Remote Config** (Optional)
   - Enable in Firebase Console
   - Used for feature flags

### Firebase Project Setup:
1. ✅ Firebase project created: `mara-6c4f8`
2. ✅ iOS app added (Bundle ID: `com.iammara.maraApp`)
3. ✅ `GoogleService-Info.plist` downloaded and configured
4. Configure Authentication providers:
   - Email/Password
   - Google Sign-In
   - Apple Sign-In
5. Configure OAuth redirect URLs
6. Enable Analytics (optional)
7. Enable Crashlytics (optional)
8. Enable Remote Config (optional)

## 🏗️ Build Commands for Production

### iOS (App Store)
```bash
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.mara.app \
  --dart-define=ENABLE_CRASH_REPORTING=true \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx \
  --dart-define=ENABLE_ANALYTICS=true
```

Then archive in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect

## 📋 Checklist for Production Deployment

### Pre-Deployment:
- [ ] Set `API_BASE_URL` to production backend URL
- [x] Configure Firebase project ✅ (mara-6c4f8)
- [x] Download and configure `GoogleService-Info.plist` ✅
- [x] Configure HealthKit entitlements ✅
- [ ] Create release provisioning profiles (iOS)
- [ ] Configure Sign in with Apple
- [ ] Set up Push Notifications certificate
- [ ] Configure Sentry DSN (if using crash reporting)
- [ ] Test health data permissions on real devices
- [ ] Verify Firebase Authentication works
- [ ] Test Google/Apple Sign-In

### Apple Developer Portal:
- [ ] Create App ID with HealthKit capability
- [ ] Create Provisioning Profile (Development + Distribution)
- [ ] Configure Sign in with Apple
- [ ] Set up Push Notifications certificate
- [ ] Add Privacy Policy URL
- [ ] Configure App Privacy details

### Firebase Console:
- [x] Create Firebase project ✅ (mara-6c4f8)
- [x] Add iOS app (Bundle ID: `com.iammara.maraApp`) ✅
- [x] Download `GoogleService-Info.plist` ✅ (Already in place)
- [ ] Enable Authentication (Email, Google, Apple)
- [ ] Configure OAuth redirect URLs
- [ ] Enable Analytics (optional)
- [ ] Enable Crashlytics (optional)
- [ ] Enable Remote Config (optional)

## 🔒 Security Notes

1. **Never commit**:
   - `GoogleService-Info.plist` ✅ (properly excluded)
   - `firebase_options.dart` (if generated)
   - `.env` files
   - Provisioning profiles
   - Certificates

2. **All secrets** must be provided via `--dart-define` flags, not hardcoded

3. **Health Data**: Ensure compliance with:
   - HIPAA (if applicable)
   - GDPR (EU users)
   - App Store Review Guidelines

## 🚀 Quick Start Commands

### Generate Firebase Config (if needed):
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

### Build for Production:
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://api.mara.app
```

## 📞 Support

For issues with:
- **HealthKit**: Check Apple Developer Portal → Certificates, Identifiers & Profiles
- **Firebase**: Check Firebase Console → Project Settings
- **Build Errors**: Check Flutter logs and Xcode console
