# Requirements & Setup Guide

## 📋 Requirements

### Development Environment

#### Required Software
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Xcode**: Latest version (for iOS development)
- **CocoaPods**: Latest version (for iOS dependencies)
- **Git**: Latest version

#### Platform Support
- **iOS**: 13.0+
- **Android**: API 21+ (Android 5.0+)
- **Web**: Modern browsers (Chrome, Safari, Firefox, Edge)

### Firebase Setup

#### Required Files (Not in Git)
These files must be provided separately (not committed to repository):

1. **iOS**: `ios/Runner/GoogleService-Info.plist`
   - Location: `ios/Runner/GoogleService-Info.plist`
   - Source: Firebase Console → Project Settings → iOS App

2. **Android**: `android/app/google-services.json`
   - Location: `android/app/google-services.json`
   - Source: Firebase Console → Project Settings → Android App

#### Firebase Configuration
- ✅ Firebase project created
- ✅ iOS app registered in Firebase Console
- ✅ Android app registered in Firebase Console
- ✅ Email/Password authentication enabled
- ✅ Google Sign-In enabled (if using)
- ✅ Apple Sign-In enabled (if using)

### Backend Requirements

#### Base URL Configuration
The app supports multiple environments:

- **Development**: `http://localhost:8000`
- **Staging (TestFlight)**: `https://mara-api-uoum.onrender.com`
- **Production**: `https://api.mara.app`

**Configuration via `--dart-define`**:
```bash
flutter run --dart-define=ENV=staging
flutter run --dart-define=API_BASE_URL=https://custom-url.com
```

#### Backend Endpoints Required

**Authentication**:
- `POST /api/v1/auth/session` - Create session with Firebase token
- `GET /api/v1/auth/me` - Get current user and entitlements

**Chat**:
- `POST /api/v1/chat` - Send chat message

**Profile**:
- `POST /api/v1/user/profile/complete` - Complete onboarding
- `GET /api/v1/user/profile` - Get user profile

**Health**:
- `GET /health` - Health check (no auth)
- `GET /ready` - Readiness check (no auth)

### Environment Variables

#### Build-Time Configuration

**iOS Production** (Apple Developer Portal):
- Bundle Identifier: `com.iammara.app` (or configured value)
- App Store Connect API Key
- Provisioning Profiles
- Certificates

**Firebase**:
- iOS: `GoogleService-Info.plist` (provided separately)
- Android: `google-services.json` (provided separately)

**Backend**:
- Base URL: Configurable via `--dart-define=API_BASE_URL=<url>`
- Environment: Configurable via `--dart-define=ENV=dev|staging|prod`

#### Runtime Configuration

**No runtime environment variables needed** - All configuration is build-time via `--dart-define`.

---

## 🚀 Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/mara-org/mara-app.git
cd mara-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Install CocoaPods (iOS)

```bash
cd ios
pod install
cd ..
```

### 4. Add Firebase Configuration Files

**iOS**:
1. Get `GoogleService-Info.plist` from Firebase Console
2. Place it at: `ios/Runner/GoogleService-Info.plist`

**Android**:
1. Get `google-services.json` from Firebase Console
2. Place it at: `android/app/google-services.json`

### 5. Configure Environment (Optional)

**Development** (default):
```bash
flutter run
```

**Staging**:
```bash
flutter run --dart-define=ENV=staging
```

**Production**:
```bash
flutter run --dart-define=ENV=prod
```

**Custom Base URL**:
```bash
flutter run --dart-define=API_BASE_URL=https://your-backend.com
```

### 6. Run the App

**iOS Simulator**:
```bash
flutter run -d "iPhone 17 Pro"
```

**Android Emulator**:
```bash
flutter run -d <device-id>
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1      # State management
  go_router: ^13.2.0            # Navigation
  firebase_core: ^3.0.0         # Firebase
  firebase_auth: ^5.3.1         # Firebase Auth
  dio: ^5.4.0                   # HTTP client (Aziz's)
  http: ^1.2.0                  # HTTP client (New backend)
  flutter_secure_storage: ^9.2.2 # Secure storage
  crypto: ^3.0.5                # Email hashing
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^3.0.0
  integration_test: sdk: flutter
```

---

## 🔧 Configuration Files

### Required Files

1. **`pubspec.yaml`** - Dependencies and app version
2. **`ios/Runner/GoogleService-Info.plist`** - Firebase iOS config (not in git)
3. **`android/app/google-services.json`** - Firebase Android config (not in git)
4. **`.gitignore`** - Excludes sensitive files

### Optional Configuration

- **`analysis_options.yaml`** - Linting rules
- **`l10n.yaml`** - Localization configuration

---

## ✅ Verification Checklist

### Before Running

- [ ] Flutter SDK installed (`flutter --version`)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] CocoaPods installed (`pod --version`)
- [ ] iOS pods installed (`cd ios && pod install`)
- [ ] Firebase config files added (iOS and Android)
- [ ] Backend URL configured (if not using defaults)

### After Running

- [ ] App launches without errors
- [ ] Firebase authentication works
- [ ] Backend connectivity works (check Network Test in Settings)
- [ ] Version displays correctly (Settings → bottom)
- [ ] App icon appears correctly (home screen)

---

## 🐛 Troubleshooting

### Common Issues

**1. CocoaPods not installed**
```bash
sudo gem install cocoapods
cd ios && pod install
```

**2. Firebase config files missing**
- Get files from Firebase Console
- Place in correct locations (see Setup Instructions)

**3. Backend connection fails**
- Check backend URL in `lib/core/config/app_config.dart`
- Use Network Test screen in Settings (Debug section)
- Verify backend is running and accessible

**4. Build errors**
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**5. Version not updating**
- Check `pubspec.yaml` version
- Do a full rebuild (not hot reload)
- Version reads from `package_info_plus` at runtime

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Backend Integration Guide](CHANGES_GUIDE.md)
- [Production Requirements](PRODUCTION_ENV_REQUIREMENTS.md)

---

**Last Updated**: December 2025

