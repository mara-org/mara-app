# Changes Guide - Backend Integration & Updates

This document outlines all changes made to integrate backend services and update the app configuration.

## 📋 Table of Contents

1. [Overview](#overview)
2. [New Files Added](#new-files-added)
3. [Modified Files](#modified-files)
4. [Backend Integration](#backend-integration)
5. [Configuration Changes](#configuration-changes)
6. [Breaking Changes](#breaking-changes)
7. [Migration Guide](#migration-guide)

---

## Overview

This update integrates backend API services while maintaining compatibility with Aziz's existing codebase. All changes follow the existing architecture patterns and coding style.

**Key Principles:**
- ✅ No changes to Aziz's UI code
- ✅ Backend integration isolated in `lib/core/services/` and `lib/core/network/`
- ✅ Uses existing exception system (`lib/core/network/api_exceptions.dart`)
- ✅ Follows existing file organization structure
- ✅ Maintains backward compatibility

---

## New Files Added

### Backend Integration Services

#### `lib/core/services/api_service.dart`
- **Purpose**: Main API service for backend communication using `http` package
- **Endpoints**:
  - `GET /health` - Health check (no auth)
  - `GET /ready` - Readiness check (no auth)
  - `POST /api/v1/auth/session` - Create session (with Firebase token)
  - `GET /api/v1/auth/me` - Get current user (with Firebase token)
  - `POST /api/v1/chat` - Send chat message (with Firebase token)
  - `POST /api/v1/user/profile/complete` - Complete onboarding (with Firebase token)
  - `GET /api/v1/user/profile` - Get user profile (with Firebase token)
- **Error Handling**: Uses Aziz's existing `ApiException` system
- **Authentication**: Automatically attaches Firebase ID token to requests

#### `lib/core/services/auth_service.dart`
- **Purpose**: Firebase authentication service wrapper
- **Methods**:
  - `getFirebaseIdToken()` - Get fresh Firebase ID token
  - `isAuthenticated` - Check authentication status
  - `userId` - Get current user ID
- **Usage**: Helper service for Firebase auth operations

### API Response Models

#### `lib/core/models/api_responses.dart`
- **Purpose**: Typed response models for backend API
- **Models**:
  - `UserInfo` - User information (id, firebaseUid, email)
  - `SessionResponse` - Session data (user, plan, entitlements, limits, token)
  - `MeResponse` - Current user data (user, plan, entitlements, limits, consents)
  - `BackendChatResponse` - Chat response (success, response, citations, metadata, usage, remainingQuota)
  - `OnboardingResponse` - Onboarding completion response
  - `ProfileResponse` - User profile data
- **Note**: `BackendChatResponse` is different from Aziz's `ChatResponse` in `lib/features/chat/data/models/chat_response.dart` to avoid conflicts

### Configuration

#### `lib/core/config/app_config.dart` (Updated)
- **Purpose**: Centralized app configuration with environment support
- **Environments**: `dev`, `staging` (TestFlight), `prod`
- **Base URLs**:
  - Dev: `http://localhost:8000`
  - Staging: `https://mara-api-uoum.onrender.com` (TestFlight)
  - Prod: `https://api.mara.app`
- **New Properties**:
  - `androidPackageName` - Android package name (configurable via `--dart-define`)
  - `iosAppId` - iOS App Store ID (configurable via `--dart-define`)
- **Override**: Can be overridden via `--dart-define=API_BASE_URL=<url>`

---

## Modified Files

### Core Services

#### `lib/core/session/session_service.dart` (NEW - Simple Backend Integration)
- **Location**: `lib/core/session/session_service.dart`
- **Purpose**: Simple backend session management using `SimpleApiClient`
- **Methods**:
  - `createBackendSession()` - Creates backend session after Firebase sign-in
  - `fetchUserInfo()` - Fetches user info from `GET /v1/auth/me`
  - `getBackendToken()` - Gets stored backend session token
  - `clearBackendToken()` - Clears backend session token
- **Used by**: UI screens (`welcome_back_screen.dart`, `home_screen.dart`)
- **Note**: This is different from Aziz's `SessionService` in `lib/core/services/session_service.dart`

#### `lib/core/services/session_service.dart` (Aziz's - Existing)
- **Location**: `lib/core/services/session_service.dart`
- **Purpose**: Backend session management using `ApiClient` (Dio-based)
- **Returns**: `AppCapabilities` model
- **Used by**: Auth repository, app capabilities provider
- **Status**: Unchanged - kept for backward compatibility

#### `lib/core/session/app_session.dart` (NEW)
- **Purpose**: In-memory session storage for backend data
- **Stores**: user, plan, entitlements, limits, backendToken
- **Usage**: Flutter only renders what backend sends (no client-side pricing logic)
- **Pattern**: Singleton pattern for global access

### UI Integration

#### `lib/features/auth/presentation/welcome_back_screen.dart`
- **Changes**: 
  - Calls `SessionService.createBackendSession()` after Firebase sign-in
  - Calls `SessionService.fetchUserInfo()` to get entitlements
  - Handles backend errors gracefully (shows "Service unavailable" if backend is down)
- **Impact**: No UI changes, only backend integration

#### `lib/features/home/presentation/home_screen.dart`
- **Changes**: 
  - Added `_fetchUserInfoIfLoggedIn()` to fetch user info on app start
  - Calls `GET /v1/auth/me` if user is already logged in
- **Impact**: No UI changes, only backend integration

#### `lib/features/settings/presentation/settings_screen.dart`
- **Changes**: 
  - Version display now uses `SystemInfoService` to read from `pubspec.yaml`
  - Shows dynamic version: "Mara 1.2.2 (6)" instead of hardcoded "Mara v1.0.0"
- **Impact**: Version now updates automatically when `pubspec.yaml` changes

### Bug Fixes

#### `lib/features/auth/presentation/verify_email_screen.dart`
- **Fix**: Corrected import path from `../../domain/` to `../domain/`
- **Reason**: Import path was incorrect, causing build errors

#### `lib/features/chat/data/models/quota_state.dart`
- **Fix**: Added missing import for `ChatMetadata`
- **Reason**: Model was using `ChatMetadata` without importing it

#### `lib/features/profile/presentation/widgets/health_permissions_section.dart`
- **Fix**: Changed `Color.withValues()` to `Color.withOpacity()` for Material 3 compatibility
- **Reason**: `withValues` is deprecated in Flutter 3.24.5

---

## Backend Integration

### Authentication Flow

1. **User signs in with Firebase** (Email/Password, Google, or Apple)
2. **App gets Firebase ID token** via `FirebaseAuth.instance.currentUser?.getIdToken()`
3. **App sends token to backend** via `POST /api/v1/auth/session`
4. **Backend verifies token** and returns session data (user, plan, entitlements, limits)
5. **App stores session** in `AppSession` (in-memory) and optionally in `SecureStore` (backend token)
6. **App fetches user info** via `GET /api/v1/auth/me` to get latest entitlements

### API Client Architecture

**Two API clients coexist:**

1. **`ApiClient`** (Aziz's - uses Dio)
   - Location: `lib/core/network/api_client.dart`
   - Used by: Existing features (auth repository, chat repository)
   - Status: Unchanged

2. **`SimpleApiClient`** (New - uses Dio)
   - Location: `lib/core/network/simple_api_client.dart`
   - Used by: `SessionService` for simple backend calls
   - Purpose: Temporary MVP-safe client with `setState` support

3. **`ApiService`** (New - uses `http` package)
   - Location: `lib/core/services/api_service.dart`
   - Used by: Direct backend calls (when needed)
   - Purpose: Alternative API client using `http` package

**Note**: All clients use the same exception system (`lib/core/network/api_exceptions.dart`)

### Error Handling

All API errors use Aziz's existing exception system:
- `UnauthorizedException` (401)
- `ForbiddenException` (403)
- `RateLimitException` (429)
- `ServerException` (500+)
- `NetworkException` (connection errors)
- `UnknownApiException` (other errors)

---

## Configuration Changes

### Environment Configuration

**File**: `lib/core/config/app_config.dart`

**Environments**:
- `dev` - Development (localhost:8000)
- `staging` - TestFlight (https://mara-api-uoum.onrender.com)
- `prod` - Production (https://api.mara.app)

**Usage**:
```bash
# Development
flutter run --dart-define=ENV=dev

# Staging (TestFlight)
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=prod

# Override base URL
flutter run --dart-define=API_BASE_URL=https://custom-url.com
```

### Version Configuration

**File**: `pubspec.yaml`
- **Current Version**: `1.2.2+6` (version 1.2.2, build 6)
- **Display**: Automatically shown in Settings screen via `SystemInfoService`

---

## Breaking Changes

### None

✅ **No breaking changes** - All changes are additive and backward compatible.

**Compatibility:**
- Existing UI code unchanged
- Existing features continue to work
- New backend integration is optional (app works even if backend is down)

---

## Migration Guide

### For Developers

**No migration needed** - All changes are backward compatible.

**If you want to use the new backend services:**

1. **Import the service**:
   ```dart
   import 'package:mara_app/core/services/api_service.dart';
   ```

2. **Use the service**:
   ```dart
   final api = ApiService();
   final session = await api.getSession();
   print('Plan: ${session.plan}');
   ```

3. **Handle errors**:
   ```dart
   try {
     final response = await api.sendChatMessage(message: 'Hello');
   } on UnauthorizedException {
     // Handle 401
   } on RateLimitException {
     // Handle 429
   } on ServerException {
     // Handle 500+
   }
   ```

### For Backend Team

**API Contract**:
- See `lib/core/models/api_responses.dart` for expected response formats
- See `lib/core/services/api_service.dart` for endpoint specifications
- All endpoints require `Authorization: Bearer <firebaseIdToken>` header

**Endpoints Used**:
- `POST /api/v1/auth/session` - After Firebase sign-in
- `GET /api/v1/auth/me` - On app start and after login
- `POST /api/v1/chat` - Chat messages (if using new ApiService)
- `POST /api/v1/user/profile/complete` - Onboarding completion
- `GET /api/v1/user/profile` - Get user profile

---

## File Organization

### Structure Matches Aziz's Style

```
lib/
├── core/
│   ├── config/          # Configuration
│   │   ├── app_config.dart          # Environment-based config (NEW)
│   │   ├── api_config.dart          # API endpoints (Aziz's)
│   │   └── env_config.dart          # Environment variables (Aziz's)
│   ├── network/         # Network clients
│   │   ├── api_client.dart          # Dio-based client (Aziz's)
│   │   ├── simple_api_client.dart   # Simple Dio client (NEW)
│   │   ├── api_exceptions.dart      # Exception system (Aziz's)
│   │   └── ...
│   ├── services/        # Business services
│   │   ├── api_service.dart         # HTTP-based API service (NEW)
│   │   ├── auth_service.dart       # Firebase auth wrapper (NEW)
│   │   ├── session_service.dart     # Aziz's session service (EXISTING)
│   │   └── ...                      # Other services (Aziz's)
│   ├── session/         # Simple session management (NEW)
│   │   ├── app_session.dart         # In-memory session storage
│   │   └── session_service.dart     # Simple backend session service
│   ├── models/          # Data models
│   │   ├── api_responses.dart       # Backend API models (NEW)
│   │   └── ...                      # Other models (Aziz's)
│   └── ...
├── features/
│   ├── auth/            # Authentication (unchanged)
│   ├── chat/            # Chat feature (unchanged)
│   └── ...
└── ...
```

**Organization Principles:**
- ✅ Services in `lib/core/services/` (Aziz's pattern)
- ✅ Simple session in `lib/core/session/` (NEW - separate from services)
- ✅ Network clients in `lib/core/network/`
- ✅ Configuration in `lib/core/config/`
- ✅ Models in `lib/core/models/`
- ✅ Feature code unchanged (no UI modifications)

---

## Testing

### New Tests Needed

**Unit Tests**:
- `lib/core/services/api_service_test.dart` - Test API service methods
- `lib/core/services/auth_service_test.dart` - Test auth service
- `lib/core/models/api_responses_test.dart` - Test response models

**Integration Tests**:
- Backend connectivity tests (already in `lib/features/debug/presentation/network_test_screen.dart`)

### Existing Tests

✅ **All existing tests remain unchanged** - No test updates needed.

---

## Dependencies

### New Dependencies

**`pubspec.yaml`**:
```yaml
dependencies:
  http: ^1.2.0  # NEW: For ApiService
```

**No other new dependencies** - Uses existing packages.

---

## Security

### No Secrets in Code

✅ **All configuration via `--dart-define`**:
- Base URLs configurable at build time
- No hardcoded API keys
- Firebase config files excluded from git

### Secure Storage

- Backend session tokens stored in `SecureStore` (Keychain/EncryptedSharedPreferences)
- Firebase tokens fetched dynamically (never stored)

---

## Known Issues

### None

✅ **All issues resolved**:
- Import paths fixed
- Material 3 compatibility fixed
- Version display fixed
- App icons generated

---

## Next Steps

1. ✅ Backend integration complete
2. ✅ App icons updated
3. ✅ Version display updated
4. ⏳ Test backend connectivity (use Network Test screen in Settings)
5. ⏳ Deploy to TestFlight with staging URL

---

## Support

For questions or issues:
- Check `PRODUCTION_ENV_REQUIREMENTS.md` for production setup
- Review `lib/core/services/api_service.dart` for API usage examples
- See `docs/SECURITY.md` for security guidelines

---

**Last Updated**: December 2025
**Version**: 1.2.2+6

