# Implementation Checklist: Exact Files & Code Changes

This document provides a detailed list of all files, workflows, and code pieces that need to be added or modified to reach enterprise-grade engineering standards.

---

## P0 (Critical) - Immediate Implementation

### 1. Multi-Platform CI Testing

**File:** `.github/workflows/frontend-ci.yml`

**Changes Required:**
- Add matrix strategy for platforms:
  ```yaml
  strategy:
    matrix:
      platform: [linux, macos, windows]
      include:
        - platform: linux
          os: ubuntu-latest
        - platform: macos
          os: macos-latest
        - platform: windows
          os: windows-latest
  ```
- Add iOS-specific job (requires macOS runner)
- Add Android-specific job
- Add Web-specific job
- Update test step to run platform-specific tests

**New Files:**
- `.github/workflows/ios-ci.yml` (iOS-specific CI)
- `.github/workflows/android-ci.yml` (Android-specific CI)
- `.github/workflows/web-ci.yml` (Web-specific CI)

**Effort:** M (Medium)

---

### 2. Test Coverage Enforcement

**File:** `.github/workflows/frontend-ci.yml`

**Changes Required:**
- Update coverage step to fail if coverage < 80%:
  ```yaml
  - name: Enforce coverage threshold
    run: |
      if [ "$COVERAGE_PERCENT" -lt 80 ]; then
        echo "❌ Coverage ${COVERAGE_PERCENT}% is below 80% threshold"
        exit 1
      fi
  ```
- Add coverage badge generation
- Add PR coverage comments (using Codecov or custom script)

**New Files:**
- `.github/workflows/coverage-badge.yml` (Generate coverage badge)
- `scripts/generate_coverage_badge.sh` (Badge generation script)

**Effort:** S (Small)

---

### 3. Branch Protection Rules

**File:** GitHub Repository Settings (not a file, but configuration)

**Changes Required:**
- Enable branch protection for `main` branch
- Require status checks:
  - `Flutter CI`
  - `Security Scan`
- Require pull request reviews (2 approvals)
- Require CODEOWNERS approval
- Disallow force pushes
- Disallow deletions

**Action:** Manual configuration in GitHub Settings → Branches → Branch protection rules

**Effort:** S (Small)

---

### 4. Secrets Scanning

**File:** `.github/workflows/security-scan.yml`

**Changes Required:**
- Replace placeholder with actual secrets scanning:
  ```yaml
  - name: Run TruffleHog secrets scan
    uses: trufflesecurity/trufflehog@main
    with:
      path: ./
      base: ${{ github.event.repository.default_branch }}
      head: HEAD
  ```
- Add GitGuardian integration:
  ```yaml
  - name: Run GitGuardian scan
    uses: GitGuardian/ggshield-action@master
    env:
      GITGUARDIAN_API_KEY: ${{ secrets.GITGUARDIAN_API_KEY }}
  ```

**New Files:**
- `.trufflehog.yaml` (TruffleHog configuration)
- `.gitguardian.yaml` (GitGuardian configuration)

**Effort:** S (Small)

---

### 5. SAST (Static Application Security Testing)

**New Files:**
- `.github/workflows/sast-scan.yml`
  ```yaml
  name: SAST Scan
  on: [push, pull_request]
  jobs:
    sast:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - name: Run SonarQube Scan
          uses: sonarsource/sonarqube-scan-action@master
          env:
            SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
            SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
  ```

**New Files:**
- `sonar-project.properties` (SonarQube configuration)
- `.github/workflows/sast-scan.yml`

**Effort:** M (Medium)

---

### 6. Structured Logging

**File:** `pubspec.yaml`

**Changes Required:**
- Add logging package:
  ```yaml
  dependencies:
    logger: ^2.0.2
  ```

**File:** `lib/core/utils/logger.dart` (NEW)

**Content:**
```dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message, [Map<String, dynamic>? context]) {
    _logger.d(message, error: null, stackTrace: null, context: context);
  }

  static void info(String message, [Map<String, dynamic>? context]) {
    _logger.i(message, error: null, stackTrace: null, context: context);
  }

  static void warning(String message, [Map<String, dynamic>? context]) {
    _logger.w(message, error: null, stackTrace: null, context: context);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _logger.e(message, error: error, stackTrace: stackTrace, context: context);
  }
}
```

**File:** `lib/core/utils/crash_reporter.dart`

**Changes Required:**
- Replace `debugPrint` with `AppLogger.error`
- Add structured context to logs

**Effort:** M (Medium)

---

### 7. Metrics Collection

**File:** `pubspec.yaml`

**Changes Required:**
- Add metrics package:
  ```yaml
  dependencies:
    prometheus_client: ^1.0.0
  ```

**File:** `lib/core/utils/metrics.dart` (NEW)

**Content:**
```dart
import 'package:prometheus_client/prometheus_client.dart';

class AppMetrics {
  static final Counter httpRequests = Counter(
    'http_requests_total',
    'Total number of HTTP requests',
    labelNames: ['method', 'status'],
  );

  static final Histogram httpDuration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    labelNames: ['method'],
  );

  static final Counter crashes = Counter(
    'app_crashes_total',
    'Total number of app crashes',
    labelNames: ['severity'],
  );

  static final Gauge activeUsers = Gauge(
    'active_users',
    'Number of active users',
  );
}
```

**Effort:** M (Medium)

---

### 8. Crash Reporting Backend Integration

**File:** `lib/core/utils/crash_reporter.dart`

**Changes Required:**
- Uncomment HTTP import
- Add Sentry integration:
  ```dart
  import 'package:sentry_flutter/sentry_flutter.dart';
  
  static Future<void> _sendToBackend({...}) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({'context': context}),
    );
  }
  ```

**File:** `pubspec.yaml`

**Changes Required:**
- Add Sentry package:
  ```yaml
  dependencies:
    sentry_flutter: ^7.0.0
  ```

**File:** `lib/main.dart`

**Changes Required:**
- Initialize Sentry:
  ```dart
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kDebugMode ? 'development' : 'production';
    },
    appRunner: () => runApp(...),
  );
  ```

**New Files:**
- `.sentryclirc` (Sentry CLI configuration)

**Effort:** M (Medium)

---

### 9. Uptime Monitoring

**New Files:**
- `.github/workflows/uptime-monitor.yml`
  ```yaml
  name: Uptime Monitor
  on:
    schedule:
      - cron: '*/5 * * * *'  # Every 5 minutes
  jobs:
    monitor:
      runs-on: ubuntu-latest
      steps:
        - name: Check application health
          run: |
            RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://api.mara.app/health)
            if [ "$RESPONSE" != "200" ]; then
              echo "Health check failed: HTTP $RESPONSE"
              exit 1
            fi
  ```

**Effort:** S (Small)

---

### 10. SLO/SLI Definitions

**New Files:**
- `docs/SLO_SLI.md`
  ```markdown
  # Service Level Objectives (SLOs) and Service Level Indicators (SLIs)

  ## SLIs (Service Level Indicators)

  ### Availability SLI
  - **Metric:** Uptime percentage
  - **Measurement:** Successful health checks / Total health checks
  - **Target:** 99.9%

  ### Latency SLI
  - **Metric:** P95 response time
  - **Measurement:** 95th percentile of API response times
  - **Target:** < 500ms

  ### Error Rate SLI
  - **Metric:** Error percentage
  - **Measurement:** Failed requests / Total requests
  - **Target:** < 0.1%

  ## SLOs (Service Level Objectives)

  ### Availability SLO
  - **Target:** 99.9% uptime (43 minutes downtime per month)
  - **Window:** 30 days rolling
  - **Measurement:** Health check success rate

  ### Latency SLO
  - **Target:** 95% of requests complete in < 500ms
  - **Window:** 30 days rolling
  - **Measurement:** P95 response time

  ### Error Rate SLO
  - **Target:** < 0.1% error rate
  - **Window:** 30 days rolling
  - **Measurement:** Error percentage
  ```

**Effort:** S (Small)

---

## P1 (High Priority) - Short-term Implementation

### 11. Staging Environment

**New Files:**
- `.github/workflows/staging-deploy.yml`
  ```yaml
  name: Deploy to Staging
  on:
    push:
      branches: [develop]
  jobs:
    deploy-staging:
      runs-on: ubuntu-latest
      steps:
        - name: Deploy to staging
          run: |
            # Deploy to staging environment
            echo "Deploying to staging..."
  ```

**File:** `.github/workflows/frontend-deploy.yml`

**Changes Required:**
- Add environment matrix:
  ```yaml
  strategy:
    matrix:
      environment: [staging, production]
  ```

**Effort:** L (Large)

---

### 12. Rollback Mechanism

**New Files:**
- `.github/workflows/rollback.yml`
  ```yaml
  name: Rollback Deployment
  on:
    workflow_dispatch:
      inputs:
        version:
          description: 'Version to rollback to'
          required: true
  jobs:
    rollback:
      runs-on: ubuntu-latest
      steps:
        - name: Rollback to version
          run: |
            echo "Rolling back to version ${{ inputs.version }}"
            # Rollback logic
  ```

**Effort:** M (Medium)

---

### 13. Build Signing

**File:** `.github/workflows/frontend-deploy.yml`

**Changes Required:**
- Add Android signing:
  ```yaml
  - name: Sign Android APK
    run: |
      jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
        -keystore ${{ secrets.ANDROID_KEYSTORE }} \
        -storepass ${{ secrets.ANDROID_KEYSTORE_PASSWORD }} \
        app-release-unsigned.apk \
        ${{ secrets.ANDROID_KEY_ALIAS }}
  ```

**New Files:**
- `android/app/keystore.properties` (Template, not committed)
- `.github/workflows/ios-sign.yml` (iOS signing workflow)

**Effort:** M (Medium)

---

### 14. Integration Tests

**New Files:**
- `integration_test/app_test.dart`
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:integration_test/integration_test.dart';
  import 'package:mara_app/main.dart' as app;

  void main() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('End-to-end test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test user flow
    });
  }
  ```

**File:** `pubspec.yaml`

**Changes Required:**
- Add integration test dependency:
  ```yaml
  dev_dependencies:
    integration_test:
      sdk: flutter
  ```

**File:** `.github/workflows/integration-tests.yml` (NEW)

**Effort:** L (Large)

---

### 15. Golden Tests

**File:** `pubspec.yaml`

**Changes Required:**
- Add golden toolkit:
  ```yaml
  dev_dependencies:
    golden_toolkit: ^0.15.0
  ```

**File:** `test/ui/example_golden_test.dart`

**Changes Required:**
- Uncomment golden test code
- Add more golden tests for all screens

**New Files:**
- `test/golden/` (Directory for golden files)
- `.gitattributes` (To handle golden files in Git)

**Effort:** M (Medium)

---

## P2 (Medium Priority) - Long-term Implementation

### 16. Feature Flags

**File:** `pubspec.yaml`

**Changes Required:**
- Add feature flag package:
  ```yaml
  dependencies:
    feature_flags: ^1.0.0  # Or use Firebase Remote Config
  ```

**New Files:**
- `lib/core/utils/feature_flags.dart`
  ```dart
  class FeatureFlags {
    static bool isFeatureEnabled(String feature) {
      // Check feature flag service
      return false;
    }
  }
  ```

**Effort:** M (Medium)

---

### 17. Distributed Tracing

**File:** `pubspec.yaml`

**Changes Required:**
- Add OpenTelemetry:
  ```yaml
  dependencies:
    opentelemetry: ^1.0.0
  ```

**New Files:**
- `lib/core/utils/tracing.dart`

**Effort:** L (Large)

---

### 18. On-Call Rotation

**New Files:**
- `.github/oncall-schedule.yml` (PagerDuty schedule)
- `docs/ONCALL.md` (On-call runbook)

**Effort:** M (Medium)

---

## Summary of Files to Create/Modify

### New Files (30+)

1. `.github/workflows/ios-ci.yml`
2. `.github/workflows/android-ci.yml`
3. `.github/workflows/web-ci.yml`
4. `.github/workflows/sast-scan.yml`
5. `.github/workflows/integration-tests.yml`
6. `.github/workflows/staging-deploy.yml`
7. `.github/workflows/rollback.yml`
8. `.github/workflows/uptime-monitor.yml`
9. `.github/workflows/coverage-badge.yml`
10. `lib/core/utils/logger.dart`
11. `lib/core/utils/metrics.dart`
12. `lib/core/utils/tracing.dart`
13. `lib/core/utils/feature_flags.dart`
14. `integration_test/app_test.dart`
15. `.trufflehog.yaml`
16. `.gitguardian.yaml`
17. `sonar-project.properties`
18. `.sentryclirc`
19. `docs/SLO_SLI.md`
20. `docs/ONCALL.md`
21. `.github/oncall-schedule.yml`
22. `scripts/generate_coverage_badge.sh`
23. `test/golden/` (Directory)
24. `.gitattributes`

### Files to Modify (10+)

1. `.github/workflows/frontend-ci.yml` (Multi-platform, coverage enforcement)
2. `.github/workflows/frontend-deploy.yml` (Staging, signing)
3. `.github/workflows/security-scan.yml` (Real secrets scanning)
4. `pubspec.yaml` (Add dependencies)
5. `lib/core/utils/crash_reporter.dart` (Structured logging, Sentry)
6. `lib/main.dart` (Sentry initialization)
7. `test/ui/example_golden_test.dart` (Implement golden tests)
8. `analysis_options.yaml` (Enhanced lint rules)
9. `README.md` (Update documentation)
10. `docs/INCIDENT_RESPONSE.md` (Update with new processes)

---

## Implementation Order

### Week 1-2: Critical Security & CI
1. Secrets scanning
2. SAST scanning
3. Branch protection
4. Multi-platform CI
5. Coverage enforcement

### Week 3-4: Observability
6. Structured logging
7. Metrics collection
8. Crash reporting backend
9. Uptime monitoring
10. SLO/SLI definitions

### Week 5-8: Testing & Deployment
11. Integration tests
12. Golden tests
13. Staging environment
14. Rollback mechanism
15. Build signing

### Week 9-12: Advanced Features
16. Feature flags
17. Distributed tracing
18. On-call rotation
19. Advanced monitoring
20. Documentation

---

**Total Estimated Effort:** ~40-60 engineering days  
**Recommended Team Size:** 2-3 engineers  
**Timeline:** 90 days (as per roadmap)
