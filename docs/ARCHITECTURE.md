# Mara App Architecture

## Overview

This document describes the architecture of the Mara mobile application. This repository contains **only** the Flutter mobile client and its CI/CD infrastructure.

## Repository Separation

### This Repository (`mara-app`)

**Scope**: Flutter mobile client + mobile CI/CD

**Contains**:
- Flutter/Dart mobile application code
- Client-side observability (Sentry, Firebase Analytics/Crashlytics)
- Mobile testing and QA infrastructure
- GitHub Actions workflows for mobile CI/CD
- SBOM generation for mobile dependencies
- Client-side error handling and retry logic
- Offline-ready local cache layer

**Does NOT contain**:
- Backend API code
- Server-side services
- Database schemas
- `/health` endpoints
- Backend observability infrastructure

### Backend Repository (Separate)

**Scope**: Backend services and APIs

**Owned by**: Another engineer (separate repository)

**Contains**:
- API endpoints
- Backend services
- Database
- Server-side observability
- Backend SBOM generation
- Health check endpoints

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mara Mobile App                           │
│                  (This Repository)                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Flutter    │  │  Observability│  │   Testing    │      │
│  │    Client    │  │   (Sentry/   │  │   & QA       │      │
│  │              │  │   Firebase)  │  │              │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           │                                   │
│                  ┌─────────▼─────────┐                       │
│                  │   CI/CD Pipeline   │                       │
│                  │  (GitHub Actions)  │                       │
│                  └────────────────────┘                       │
│                                                               │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ (Future API calls)
                            │
┌───────────────────────────▼─────────────────────────────────┐
│              Backend Services                                │
│         (Separate Repository)                                │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     API      │  │  Observability│  │  Database    │      │
│  │   Endpoints  │  │   & Alerts   │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Client-Side Architecture

### Observability Stack

**Sentry** (Primary):
- Crash reporting
- Error tracking
- Performance monitoring
- Configured via `SENTRY_DSN` environment variable

**Firebase** (Optional):
- Firebase Analytics: User behavior tracking
- Firebase Crashlytics: Additional crash reporting
- Requires `Firebase.initializeApp()` at startup

**Implementation**:
- `lib/core/utils/crash_reporter.dart`: Unified crash reporting abstraction
- `lib/core/analytics/analytics_service.dart`: Analytics abstraction

### Network Layer

**HTTP Client**: Dio with retry interceptor
- Exponential backoff retry logic
- Retries on network errors and 5xx server errors
- Implementation: `lib/core/network/retry_interceptor.dart`

**Error Handling**:
- Graceful fallback UI: `lib/core/widgets/error_view.dart`
- Network error detection
- Retry button support

### Offline Support

**Local Cache**: `lib/core/storage/local_cache.dart`
- Key-value storage using SharedPreferences
- Simple interface: `saveString()`, `getString()`, etc.
- Can be extended with TTL, encryption, cache eviction

### State Management

- **Riverpod**: Primary state management solution
- Providers for: settings, permissions, language, user profile, chat topics

### Navigation

- **GoRouter**: Declarative routing
- Route definitions in `lib/core/routing/`

## CI/CD Pipeline

### Workflows

1. **Frontend CI** (`.github/workflows/frontend-ci.yml`):
   - Multi-platform builds (Android, iOS, Web)
   - Code formatting checks
   - Static analysis
   - Test execution with coverage
   - Flaky test detection
   - Performance timing metrics

2. **SBOM Generation** (`.github/workflows/sbom-generation.yml`):
   - Generates SBOM on push to `main` and release tags
   - Uploads SBOM as artifact

3. **Golden Tests** (`.github/workflows/golden-tests.yml`):
   - Visual regression testing
   - Uploads diffs as artifacts on failure

4. **Security Scanning**:
   - CodeQL analysis
   - Secrets scanning (TruffleHog)

5. **Automation**:
   - PR size labeling
   - Auto-labeler (by file paths)
   - Auto-merge (when conditions met)

## Testing Strategy

### Test Types

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components and screens
3. **Golden Tests**: Visual regression tests

### Test Utilities

- `test/utils/test_utils.dart`: Common test helpers
- `pumpMaraApp()`: Standard widget test setup
- Mock providers and navigation observers

### Coverage Goals

- **Current**: 15% minimum (hard fail)
- **Warning**: 70% (soft warning)
- **Future**: 80%+ (enforcement threshold)

## Dependencies

### Core Dependencies

- `flutter_riverpod`: State management
- `go_router`: Navigation
- `sentry_flutter`: Crash reporting
- `firebase_core`, `firebase_analytics`, `firebase_crashlytics`: Analytics
- `dio`: HTTP client with retry support
- `shared_preferences`: Local storage

### Development Dependencies

- `flutter_lints`: Linting rules
- `golden_toolkit`: Golden test support

## Future Backend Integration

When the backend is ready:

1. **API Client**: Will use Dio with retry interceptor
2. **Error Handling**: Will use `ErrorView` widget for network failures
3. **Offline Support**: Local cache will store data for offline access
4. **Observability**: Crashes and analytics already configured to work independently

**No backend code will be added to this repository.** All backend logic lives in a separate repository.

## Design Principles

1. **Client-Side Only**: No backend code in this repo
2. **Observability First**: Sentry/Firebase configured from the start
3. **Resilient**: Retry logic and error handling built-in
4. **Testable**: Comprehensive test utilities and golden tests
5. **Automated**: CI/CD handles testing, building, and deployment

## Related Documentation

- [Frontend SLOs](FRONTEND_SLOS.md): Client-side service level objectives
- [Incident Response](INCIDENT_RESPONSE.md): Incident handling procedures
- [README](../README.md): Getting started and project overview

