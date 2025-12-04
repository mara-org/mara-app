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

## Architecture Layers

The app follows a layered architecture pattern:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Widgets, Screens, Navigation)   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│    (Use Cases, Entities, Business)     │
│         (To be implemented)            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories, Data Sources, Cache)   │
│         (To be implemented)            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      External Services                  │
│  (Sentry, Firebase, Future Backend)    │
└─────────────────────────────────────────┘
```

### Presentation Layer

**Location:** `lib/features/*/presentation/`

- UI widgets and screens
- Navigation logic (GoRouter)
- State management (Riverpod)
- User interactions

### Domain Layer

**Location:** `lib/features/*/domain/` (to be implemented)

- Business logic
- Use cases
- Domain entities
- Validation rules

### Data Layer

**Location:** `lib/features/*/data/` (to be implemented)

- Repository implementations
- Data sources (network, local cache)
- Data models
- API clients

### Core Layer

**Location:** `lib/core/`

- Shared utilities (logging, crash reporting, analytics)
- Network layer (retry, circuit breaker, rate limiting)
- Storage (local cache)
- Feature flags
- Routing
- Theme
- Models

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
- Enables graceful degradation when offline

### Feature Flags

**Feature Flag Service**: `lib/core/feature_flags/feature_flag_service.dart`
- Enables canary deployments and staged rollouts
- Supports Firebase Remote Config
- Local defaults for development
- Implementation: `lib/core/feature_flags/firebase_remote_config_service.dart`

### State Management

- **Riverpod**: Primary state management solution
- Providers for: settings, permissions, language, user profile, chat topics

### Navigation

- **GoRouter**: Declarative routing
- Route definitions in `lib/core/routing/`

## CI/CD Pipeline

### Workflows

#### Core CI Workflows

1. **Frontend CI** (`.github/workflows/frontend-ci.yml`):
   - Multi-platform builds (Android, iOS, Web)
   - Code formatting checks
   - Static analysis
   - Test execution with coverage (parallel execution)
   - Flaky test detection with retry logic
   - Performance timing metrics
   - Test result caching
   - Per-file coverage gates
   - PR size-based test selection
   - CI failure root cause analysis

2. **Integration Tests** (`.github/workflows/integration-tests.yml`):
   - End-to-end integration tests
   - Multi-platform support (Android, iOS)
   - Web platform gracefully skipped

3. **Golden Tests** (`.github/workflows/golden-tests.yml`):
   - Visual regression testing
   - Uploads diffs as artifacts on failure
   - Light and dark mode support

4. **Performance Benchmarks** (`.github/workflows/performance-benchmarks.yml`):
   - Performance test execution
   - Metrics collection and tracking
   - Regression detection support

5. **Dart Metrics** (`.github/workflows/dart-metrics.yml`):
   - Code complexity analysis
   - File size warnings
   - Static analysis with `dart_code_metrics`

6. **Docs CI** (`.github/workflows/docs-ci.yml`):
   - Markdown linting
   - Documentation quality checks
   - Triggered on docs changes only

#### Security Workflows

7. **Security PR Check** (`.github/workflows/security-pr-check.yml`):
   - Dependency vulnerability scanning
   - Outdated dependency detection
   - Basic secrets scanning
   - PR comments on security issues
   - **Note:** Requires `pull-requests: write` permission

8. **CodeQL Analysis** (`.github/workflows/codeql-analysis.yml`):
   - Static Application Security Testing (SAST)
   - Weekly scheduled scans

9. **Secrets Scan** (`.github/workflows/secrets-scan.yml`):
   - TruffleHog secrets detection
   - Weekly scheduled scans

10. **License Scan** (`.github/workflows/license-scan.yml`):
    - License compliance checking
    - Weekly scheduled scans

11. **SBOM Generation** (`.github/workflows/sbom-generation.yml`):
    - Generates SBOM on push to `main` and release tags
    - Uploads SBOM as artifact

#### Deployment Workflows

12. **Production Deploy** (`.github/workflows/frontend-deploy.yml`):
    - Production APK/AAB builds
    - Artifact signing (if configured)
    - GitHub Environments approval gates

13. **Staging Deploy** (`.github/workflows/staging-deploy.yml`):
    - Staging environment builds
    - Pre-production testing

14. **PR Preview Deploy** (`.github/workflows/pr-preview-deploy.yml`):
    - Debug APK builds for PRs
    - Automatic PR comments with download links
    - **Note:** Requires `pull-requests: write` permission

15. **Rollback** (`.github/workflows/rollback.yml`):
    - Rollback to previous versions
    - Manual trigger with version selection

16. **Smoke Tests** (`.github/workflows/smoke-tests.yml`):
    - Post-deployment validation
    - Critical test execution

17. **Release Automation** (`.github/workflows/release-automation.yml`):
    - Semantic versioning
    - Changelog generation
    - GitHub release creation

#### Automation Workflows

18. **Auto-Triage** (`.github/workflows/auto-triage.yml`):
    - Automatic issue/PR labeling
    - Assignee suggestions
    - **Note:** Uses `github-script` (context is built-in)

19. **Contributor Onboarding** (`.github/workflows/contributor-onboarding.yml`):
    - Welcomes first-time contributors
    - Provides helpful links and resources
    - **Note:** Uses `github-script` (context is built-in)

20. **Auto-Merge** (`.github/workflows/auto-merge.yml`):
    - Automatic PR merging when conditions met
    - Supports Dependabot PRs

21. **Auto-Rebase** (`.github/workflows/auto-rebase.yml`):
    - Automatic PR rebasing on main branch updates

22. **Branch Cleanup** (`.github/workflows/branch-cleanup.yml`):
    - Automatic deletion of merged branches

23. **PR Size** (`.github/workflows/pr-size.yml`):
    - PR size labeling
    - Warnings for large PRs

24. **Performance Regression Detection** (`.github/workflows/performance-regression-detection.yml`):
    - Compares benchmark results
    - Detects performance regressions
    - **Note:** Requires `pull-requests: write` permission for PR comments

25. **DORA Metrics** (`.github/workflows/dora-metrics.yml`):
    - Deployment frequency tracking
    - Change failure rate calculation
    - Lead time measurement

### Workflow Permissions

All workflows that interact with PRs/issues require explicit permissions:

- **PR Comments:** `pull-requests: write`
- **Issue Management:** `issues: write`
- **Code Access:** `contents: read` (or `contents: write` for deployments)
- **Security Events:** `security-events: write` (for CodeQL)

**Recent Fixes:**
- Added missing `pull-requests: write` permissions to workflows that comment on PRs
- Fixed duplicate `context` declarations in `github-script` workflows (context is built-in)

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

.