# Mara

**Mara** is an AI-powered health companion mobile app built with Flutter. It helps users track their health, get personalized insights, and interact with an intelligent health assistant.

## 📊 Engineering Maturity Progress

| Category | Previous | Current | Target | Status |
|----------|----------|---------|--------|--------|
| **CI** | 68% | **82%** ⬆️ | 85% | 🟢 Near Target |
| **CD** | 35% | **75%** ⬆️ | 80% | 🟢 Near Target |
| **Security** | 62% | **68%** ⬆️ | 85% | 🟡 In Progress |
| **DevOps** | 78% | **85%** ⬆️ | 85% | 🟢 Target Met |
| **Observability** | 45% | **65%** ⬆️ | 70% | 🟢 Near Target |
| **SRE** | 50% | **70%** ⬆️ | 75% | 🟢 Near Target |
| **Code Quality** | 45% | **70%** ⬆️ | 75% | 🟢 Near Target |
| **Frontend Best Practices** | 45% | **75%** ⬆️ | 80% | 🟢 Near Target |
| **Reliability** | 40% | **75%** ⬆️ | 80% | 🟢 Near Target |

**Overall Maturity:** 64% → **78%** ⬆️ +14% (Major Enterprise Upgrade Complete)

### Key Improvements (Latest Update - December 2025 - Major Enterprise Upgrade)

**CI/CD Enhancements:**
- ✅ **NEW:** Parallel test execution with configurable concurrency
- ✅ **ENHANCED:** Test result caching (pub cache, dart_tool, build artifacts)
- ✅ **NEW:** Integration tests workflow and test suite (`integration-tests.yml`)
- ✅ **NEW:** Performance benchmarks workflow (`performance-benchmarks.yml`)
- ✅ **NEW:** Per-file coverage gates script (`scripts/check-coverage-per-file.sh`)
- ✅ **ENHANCED:** Stricter lint rules (Airbnb-style strictness)
- ✅ **NEW:** PR size-based test selection (minimal/standard/full suites)
- ✅ **NEW:** CI failure root cause analysis and categorization
- ✅ **NEW:** Staging environment deployment (`staging-deploy.yml`)
- ✅ **NEW:** PR preview builds (`pr-preview-deploy.yml`)
- ✅ **NEW:** Rollback mechanism (`rollback.yml`)
- ✅ **NEW:** Post-deployment smoke tests (`smoke-tests.yml`)
- ✅ **NEW:** Release automation with semantic versioning (`release-automation.yml`)
- ✅ **NEW:** DORA metrics tracking (`dora-metrics.yml`)
- ✅ **NEW:** Deployment approval gates (GitHub Environments)
- ✅ **NEW:** Changelog generation script (`scripts/generate-changelog.sh`)

**DevOps Automation:**
- ✅ **NEW:** Auto-triage workflow for issues/PRs (`auto-triage.yml`)
- ✅ **NEW:** Contributor onboarding automation (`contributor-onboarding.yml`)
- ✅ **NEW:** Performance regression detection (`performance-regression-detection.yml`)
- ✅ **NEW:** Documentation generation (`docs-generation.yml`)
- ✅ **NEW:** Security patch auto-merge (`security-patch-auto-merge.yml`)
- ✅ **NEW:** Developer setup script (`scripts/setup-dev-environment.sh`)

**SRE & Observability:**
- ✅ **NEW:** Error budget tracking documentation (`docs/ERROR_BUDGET_REPORT.md`)
- ✅ **NEW:** Reliability dashboards documentation (`docs/RELIABILITY_DASHBOARDS.md`)
- ✅ **NEW:** On-call runbook (`docs/ONCALL.md`)
- ✅ **NEW:** SLO alerting rules documentation (`docs/OBSERVABILITY_ALERTS.md`)
- ✅ **ENHANCED:** Structured logging with context (screen, feature, session)
- ✅ **ENHANCED:** Crash reporter with structured tags (environment, app_version, build_number, screen, feature, error_type)

**Code Quality & Architecture:**
- ✅ **NEW:** Architecture documentation enhanced (`docs/ARCHITECTURE.md`)
- ✅ **NEW:** ADR process established (`docs/architecture/decisions/0001-record-architecture-decisions.md`)
- ✅ **NEW:** Contributing guidelines (`CONTRIBUTING.md`)
- ✅ **NEW:** Design system documentation (`docs/DESIGN_SYSTEM.md`)

**Frontend Best Practices:**
- ✅ **NEW:** Feature flags implementation (`lib/core/feature_flags/`)
- ✅ **NEW:** Performance instrumentation (SLO metrics in AnalyticsService)
- ✅ **NEW:** Integration tests suite (`integration_test/`)
- ✅ **NEW:** Performance benchmarks (`test/performance/`)

**Reliability:**
- ✅ **NEW:** Circuit breaker pattern (`lib/core/network/circuit_breaker.dart`)
- ✅ **NEW:** Client-side rate limiting (`lib/core/network/rate_limiter.dart`)
- ✅ **ENHANCED:** Graceful degradation (ErrorView widget, offline cache)

**Security:**
- ✅ **NEW:** Secrets rotation documentation (`docs/SECURITY.md`)
- ✅ **NEW:** Security incident response procedures
- ✅ **ENHANCED:** License compliance scanning

### Previous Improvements (Phase 2)
- ✅ Multi-platform CI (Android, iOS, Web)
- ✅ Coverage enforcement (70% threshold)
- ✅ CodeQL SAST scanning
- ✅ TruffleHog secrets scanning
- ✅ Golden test infrastructure
- ✅ PR automation (size labels, auto-rebase, stale bot)
- ✅ Enhanced test utilities and widget tests

### Links
- [CI Workflows](https://github.com/mara-org/mara-app/actions)
- [CodeQL Dashboard](https://github.com/mara-org/mara-app/security/code-scanning)
- [Security Scan Results](https://github.com/mara-org/mara-app/actions/workflows/secrets-scan.yml)

---



## 🎯 Features

### Core Functionality
- **AI Health Assistant**: Chat with Mara to get instant, accurate medical insights powered by trusted health data
- **Personalized Insights**: Get health recommendations tailored to your daily patterns and goals
- **Health Tracking**: Monitor vital signs, mood, sleep, and hydration
- **Analytics Dashboard**: View detailed analytics about your health data
- **Multi-language Support**: Understands 100+ languages for natural conversation

### Key Screens

#### Onboarding & Setup
- **Splash Screen**: App introduction
- **Language Selector**: Choose preferred language (English/Arabic) with bold Roboto fonts
- **Welcome & Onboarding**: Introduction to Mara's features and privacy
- **User Profile Setup**: Collect name, DOB, gender, height, weight, blood type, and health goals
- **Permissions**: Request camera, microphone, notifications, and health data access
  - Camera permission with photo_camera.png icon
  - Microphone permission with mic.png icon
  - Notifications permission with notifications_active.png icon
  - Health data permission with monitor_heart.png icon

#### Authentication
- **Sign Up (Join Mara)**: Create account with email, Google, or Apple sign-in options
- **Enter Your Email**: Email and password sign-in with terms checkbox and Login link
- **Verify Email**: 6-digit code verification screen
- **Welcome Back**: Returning user experience with email/password fields and social sign-in

#### Main App
- **Home Screen**: 
  - Daily insights (mood, sleep, water intake)
  - Vital signs card (clickable with loading state - grey background and hourglass icon)
  - Summary card (clickable with loading state - grey background and hourglass icon)
  - Chat with Mara button
- **Mara Chat**: Interactive chat interface with the AI health assistant
- **Analytics Dashboard**: Health data visualization and insights
- **Profile**: 
  - Single scrollable page with unified visual style
  - White header with back arrow (navigates to home screen)
  - User section with email display
  - Full Health Profile section (Name, Date of Birth, Gender, Height, Weight, Blood Type, Main Goal) - all editable using onboarding screens
  - Full App Settings section (Language preferences, Health reminders, Email notifications)
  - Privacy Policy (opens in WebView)
  - Terms of Service (opens in external browser)
  - Developer Settings (App Version, Device Info - dynamic data)
  - Logout option

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod (flutter_riverpod, hooks_riverpod)
- **Navigation**: GoRouter
- **UI Components**: Material Design
- **Assets**: SVG and PNG support
- **Internationalization**: intl package
- **External Links**: url_launcher
- **WebView**: webview_flutter (for in-app privacy policy and terms viewing)
- **System Info**: package_info_plus, device_info_plus (for dynamic app version and device information)
- **Typography**: Roboto font family applied globally throughout the entire app

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/              # Data models (permissions, chat messages, user profile)
│   ├── providers/           # Riverpod providers (settings, permissions, language, user profile)
│   ├── routing/             # App routing configuration
│   ├── theme/               # App colors, text styles, theme (Roboto font configured globally)
│   ├── utils/               # Platform utilities
│   └── widgets/             # Reusable widgets (buttons, text fields, logo)
├── features/
│   ├── analytics/           # Analytics dashboard
│   ├── auth/                # Authentication screens
│   ├── chat/                # Mara chat interface
│   ├── home/                # Home screen
│   ├── onboarding/          # Onboarding flow
│   ├── permissions/         # Permission request screens
│   ├── profile/             # User profile
│   ├── settings/            # Settings screens
│   ├── setup/               # User profile setup flow
│   └── splash/              # Splash screen
└── main.dart                # App entry point
```

## 🏗️ Architecture & Repositories

**Important:** This repository (`mara-app`) contains **only** the Flutter mobile client and its CI/CD infrastructure.

### Repository Separation

- **`mara-app` (this repo)**: Flutter client + mobile CI/CD
  - Mobile app code (Flutter/Dart)
  - Client-side observability (Sentry/Firebase)
  - Mobile testing and QA
  - GitHub Actions workflows for mobile CI/CD
  - SBOM generation for mobile dependencies

- **Backend/API (separate repository)**: Owned by another engineer
  - API endpoints
  - Backend services
  - Server-side observability
  - Backend SBOM generation
  - Database and infrastructure

**This repo is intentionally backend-agnostic.** No backend code, API endpoints, or `/health` endpoints exist in this repository by design.

**Related Documentation:**
- [Architecture](docs/ARCHITECTURE.md) - Detailed architecture documentation
- [Enterprise Audit Report](docs/ENTERPRISE_AUDIT_REPORT.md) - Comprehensive engineering maturity assessment

## 🔒 Security & SBOM

### Software Bill of Materials (SBOM)

This repository generates SBOMs for the Flutter mobile app dependencies:

- **Generation**: Automated via `.github/workflows/sbom-generation.yml`
- **Trigger**: On push to `main` and release tags (`v*`)
- **Output**: `sbom.json` (uploaded as artifact)
- **Location**: Generated in CI, available as workflow artifact

**Note**: Backend SBOM will be generated in a separate repository.

### Security Scanning

- **CodeQL**: Static analysis for security vulnerabilities
- **TruffleHog**: Secrets scanning
- **Dependabot**: Dependency updates and security advisories

See `.github/workflows/security-scan.yml` and `.github/workflows/codeql-analysis.yml` for details.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- iOS Simulator / Android Emulator or physical device
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mara-org/mara-app.git
   cd mara-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Common Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release

# Build iOS (requires macOS and Xcode)
flutter build ios --release

# Build Web
flutter build web --release

# Format code
dart format .

# Analyze code
flutter analyze

# Format and lint (recommended before committing)
sh tool/format_and_lint.sh
```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🎨 Design

- **App Name**: Mara
- **Primary Color**: #0EA5C6 (Teal/Cyan)
- **Font**: Roboto (applied globally to every single word in the app via theme configuration)
- **Design System**: Custom theme with consistent colors and typography
- **UI Elements**: Consistent use of rounded corners (16-20px radius), shadows, and spacing

### Design Details

#### Permission Screens
- All permission screens use custom icons with color filters
- Consistent button positioning and spacing across all permission screens
- SemiBold font weight for all headlines
- Centered images with consistent styling

#### Setup Screens
- Height and Weight screens with unit selectors (cm/in, kg/lb)
- Continuous blue line under unit selectors
- Custom picker styling with selected/unselected states
- Blood type and goals screens with updated button styling
- **Reusable for Profile Editing**: All setup screens (Name, Date of Birth, Gender, Height, Weight, Blood Type, Goals) can be used both for initial onboarding and for editing from the Profile screen

#### Profile Screen
- Unified visual style with white background (#FFFFFF)
- Simple AppBar-style header with back arrow and centered "Profile" title
- Consistent row styling across all sections:
  - Row title text: #0F172A, fontWeight w500
  - Row value text: #64748B
  - Brand blue dividers (#0EA5C6) between rows
- All sections in a single scrollable page for better UX
- Developer Settings section with dynamic app version and device info

## 📱 App Icons

App icons are located in the `AppIcon/` folder. Icons are configured for both Android and iOS platforms with all required sizes.

### Updating App Icons

1. Place your icon files in the `AppIcon/` folder
2. For Android: Icons should be copied to `android/app/src/main/res/mipmap-*/ic_launcher.png`
3. For iOS: Icons should be placed in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🔐 Permissions

The app requests the following permissions:

- **Camera**: For facial expression analysis and fatigue detection (processed locally)
- **Microphone**: For voice input and natural conversation
- **Notifications**: For health reminders and daily goals
- **Health Data**: For activity, sleep, and heart rate tracking

All data processing happens locally on the device for maximum privacy.

## 🌐 Navigation

The app uses GoRouter for navigation. Key routes include:

- `/splash` - Initial splash screen
- `/language-selector` - Language selection screen
- `/sign-up-choices` - Sign up options (Google, Apple, Email)
- `/sign-in-email` - Email and password sign in
- `/verify-email` - Email verification screen
- `/welcome-back` - Welcome back screen for returning users
- `/home` - Main home screen
- `/chat` - Mara chat interface
- `/analytics` - Analytics dashboard
- `/profile` - User profile (single scrollable page with all sections)
- `/settings` - App settings (legacy, now embedded in Profile)
- `/privacy-webview` - In-app privacy policy WebView
- `/onboarding-*` - Onboarding flow screens
- `/permissions-*` - Permission request screens
- `/name-input`, `/dob-input`, `/gender`, `/height`, `/weight`, `/blood-type`, `/goals` - Profile setup screens (can be accessed with `?from=profile` query parameter for editing)

### Navigation Behavior

- **Profile Screen**: Back arrow navigates to `/home` instead of going back in navigation history
- **Profile Editing**: When editing profile fields, screens check for `?from=profile` query parameter:
  - If present: After saving, navigates back to `/profile`
  - If absent: Continues normal onboarding flow

## 🧪 Testing

### Running Tests

Run all tests with:
```bash
flutter test
```

### Test Types

- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components and screens (see `test/ui/example_widget_test.dart`)
- **Golden Tests**: Visual regression tests (see `test/ui/example_golden_test.dart`)
  - TODO: Set up `golden_toolkit` package for proper golden testing
  - Golden tests capture widget snapshots and detect visual regressions

### Test Coverage

Test coverage is collected during CI runs. Coverage reports are available as artifacts in GitHub Actions.

**Current Coverage Goal:** 60%+ (warning threshold)  
**Future Goal:** 80%+ (enforcement threshold)

See the CI workflow for coverage collection and reporting.

## 🔧 Code Quality & Formatting

### Formatting and Linting

Before committing, run the format and lint script:

```bash
sh tool/format_and_lint.sh
```

This script will:
- Format all Dart code using `dart format .`
- Run static analysis using `flutter analyze`

The script will exit with a non-zero code if analysis fails, preventing commits with linting errors.

### Git Hooks

Git hooks automatically run code quality checks before each commit. All contributors are expected to install the hooks.

**Installation:**

Run the installation script:
```bash
sh tool/install_hooks.sh
```

This will:
- Copy the pre-commit hook to `.git/hooks/pre-commit`
- Make it executable
- Set up automatic formatting and linting checks

**What the hook does:**

The pre-commit hook automatically:
- Formats code with `dart format .`
- Analyzes code with `flutter analyze`
- Prevents the commit if any issues are found

**Bypassing the hook:**

You can bypass the hook with `git commit --no-verify` if needed, but this is **not recommended**. The hook ensures code quality and consistency across the project.

## 🚀 CI/CD Pipeline

### Continuous Integration (CI)

#### Main CI Workflow
The **Frontend CI** workflow (`.github/workflows/frontend-ci.yml`) runs automatically on:
- Push to any branch
- Pull request to `main`

It performs:
1. Code checkout
2. Flutter setup (version 3.27.0)
3. Dependency installation (`flutter pub get`)
4. Static analysis (`flutter analyze`)
5. Test execution (`flutter test`)

Results are sent to Discord via the `DISCORD_WEBHOOK_FRONTEND` secret.

#### Additional CI Workflows

**Dart Metrics** (`.github/workflows/dart-metrics.yml`):
- Code complexity analysis using `dart_code_metrics`
- File size warnings (detects files >500 lines)
- Cyclomatic complexity tracking
- Non-blocking info-level warnings (only fails on errors)
- Provides helpful summary of errors/warnings/info counts

**Documentation CI** (`.github/workflows/docs-ci.yml`):
- Lightweight CI for documentation-only changes
- Triggers only when `README.md` or `docs/**` files change
- Skips Flutter build for faster feedback
- Markdown validation
- Optional spell checking support

**Security PR Check** (`.github/workflows/security-pr-check.yml`):
- Checks for outdated dependencies (`dart pub outdated`)
- Basic secrets scanning (TruffleHog or pattern matching)
- Detects critical package updates (Flutter/Dart/Sentry/Firebase)
- Comments on PRs with outdated dependencies
- Provides security summary

### Continuous Deployment (CD)

The **Frontend Deploy** workflow (`.github/workflows/frontend-deploy.yml`) runs on:
- Push to `main` branch
- Manual trigger via `workflow_dispatch`

It performs:
1. Code checkout
2. Flutter setup
3. Dependency installation
4. Version extraction from `pubspec.yaml`
5. Android APK build (`flutter build apk --release`)
6. Placeholder deploy step (ready for Firebase App Distribution / Play Store / Web hosting)

Deployment notifications are sent to Discord with details including:
- Build status (success/failure)
- Environment (production)
- App version
- Commit hash
- Total build time
- Link to workflow run

### Discord Notifications

All workflows use the `DISCORD_WEBHOOK_FRONTEND` GitHub secret to send notifications to Discord.

**Setup Instructions:**
1. Create a Discord webhook in your server
2. Add the webhook URL as a GitHub secret named `DISCORD_WEBHOOK_FRONTEND`
3. Go to: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Notifications are sent for:
- ✅ CI pass/fail status
- 🚀 Deploy success/failure
- 🔀 Pull request events (opened, reopened, closed, merged)
- 🐛 Issue events (opened, reopened, closed)
- 🏷️ Release publications

### Dev Events Workflow

The **Dev Events** workflow (`.github/workflows/dev-events.yml`) handles:
- Pull request notifications (with merge detection)
- Issue notifications
- Release notifications
- Automatic PR labeling based on branch name:
  - `feat/*` → `feature` label
  - `fix/*` → `bug` label
  - `chore/*` → `chore` label

## 🐛 Crash Reporting & Observability

The app includes comprehensive observability infrastructure:

### Crash Reporting

**Implementation**: `lib/core/utils/crash_reporter.dart`

**Features**:
- ✅ Catches Flutter framework errors
- ✅ Handles async errors outside the Flutter framework
- ✅ Logs errors to console (debug mode)
- ✅ Sends to Sentry (release mode, if configured)
- ✅ Sends to Firebase Crashlytics (if enabled)
- ✅ Determines crash severity automatically

**Configuration**:
- Sentry: Set `SENTRY_DSN` environment variable or configure at runtime
- Firebase: Requires `Firebase.initializeApp()` at startup

**No backend needed**: Crashes go directly to Sentry/Firebase SaaS services.

### Analytics

**Implementation**: `lib/core/analytics/analytics_service.dart`

**Features**:
- Screen view tracking
- Custom event tracking
- User property tracking
- Firebase Analytics integration (if configured)

**Usage**:
```dart
AnalyticsService.logScreenView('home_screen');
AnalyticsService.logEvent('button_clicked', {'button_name': 'chat'});
```

**No backend needed**: Analytics go directly to Firebase Analytics.

## 🚨 Incident Response & SRE

### Monitoring & Alerting

**Current Monitoring:**
- ✅ CI/CD pipeline status (Discord `#mara-dev-events`)
- ✅ Deployment status (Discord `#mara-deploys`)
- ✅ Repeated failure detection (Discord `#mara-alerts`)
- ⚠️ Health checks (placeholder - needs backend)
- ⚠️ Crash reports (detection ready - needs backend integration)

**Workflows:**
- `frontend-ci.yml` - CI with failure notifications
- `frontend-deploy.yml` - Deployment with failure notifications
- `dev-events.yml` - PR/Issue/Release notifications
- `repeated-failures-alert.yml` - Detects and alerts on repeated failures
- `health-check.yml` - Health check monitoring (ready for backend)

**Discord Channels:**
- `#mara-deploys` - Deployment notifications
- `#mara-dev-events` - CI, PR, issue notifications
- `#mara-alerts` - Critical alerts and incidents
- `#mara-crashes` - Crash reports (when backend is integrated)

### Documentation

- **Architecture:** [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture and design
- **Frontend SLOs:** [docs/FRONTEND_SLOS.md](docs/FRONTEND_SLOS.md) - Service level objectives
- **Incident Response Runbook:** [docs/INCIDENT_RESPONSE.md](docs/INCIDENT_RESPONSE.md) - Incident handling procedures
- **Enterprise Audit Report:** [docs/ENTERPRISE_AUDIT_REPORT.md](docs/ENTERPRISE_AUDIT_REPORT.md) - Comprehensive engineering maturity audit

See the [Incident Response Runbook](docs/INCIDENT_RESPONSE.md) for detailed procedures on handling incidents, escalation, and post-mortems.

## 🔒 Branch Protection & Code Owners

### Branch Protection

The `main` branch is protected and requires:
- All changes must go through pull requests
- Required status checks must pass before merging
- Required reviews from code owners
- Force pushes and direct pushes are disabled

**Branch protection must require CODEOWNERS review** – configure in GitHub Settings manually:
1. Go to `Settings` → `Branches` → `Branch protection rules`
2. Add rule for `main` branch
3. Enable:
   - ✅ Require status checks to pass before merging
   - ✅ Require pull request reviews before merging (at least 1 approval)
   - ✅ Require review from code owners
   - ✅ Do not allow bypassing the above settings
   - ✅ Restrict pushes that create files larger than 100 MB
   - ✅ Do not allow force pushes
   - ✅ Do not allow deletions

### Code Owners

The `.github/CODEOWNERS` file automatically assigns reviewers for pull requests based on file paths.

**Current Code Owners:**
- `@justAbdulaziz10` and `@gqnxx` are owners for:
  - `/lib/**` - All application code
  - `/test/**` - All test files
  - `/.github/**` - GitHub workflows and configuration

**Specific Area Ownerships:**
- `/lib/core/` → `@justAbdulaziz10`
- `/lib/features/auth/` → `@justAbdulaziz10`
- `/lib/features/chat/` → `@justAbdulaziz10`
- `/test/` → `@justAbdulaziz10`

**Adding More Owners:**

To add more owners, edit `.github/CODEOWNERS` and add GitHub usernames (without @) to the appropriate paths. See the file header for instructions.

## 📋 Pull Requests & Issues

### Pull Request Template

When creating a PR, use the template that includes:
- Summary
- Changes list
- Screenshots (for UI changes)
- Testing checklist
- Code quality checklist

### Issue Templates

Three issue templates are available (YAML format):

1. **Bug Report** (`.github/ISSUE_TEMPLATE/bug_report.yml`):
   - Description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots
   - Device/OS info

2. **Feature Request** (`.github/ISSUE_TEMPLATE/feature_request.yml`):
   - Problem/context
   - Proposed solution
   - Alternatives considered
   - Additional context

3. **Technical Debt** (`.github/ISSUE_TEMPLATE/tech_debt.yml`) **NEW**:
   - Description of technical debt
   - Location (file paths/modules)
   - Impact assessment
   - Proposed solution
   - Priority level

## 🔄 Dependency Updates

Dependabot is configured (`.github/dependabot.yml`) to:
- Check GitHub Actions dependencies weekly
- Check Dart/Flutter pub dependencies weekly
- Create PRs with `dependencies` label
- Limit to 10 open PRs at a time

Review and merge dependency updates regularly to keep dependencies secure and up-to-date.

## 📝 Version

- **Current Version**: 1.0.0+1

## 📄 License

This project is part of the Mara organization.

## 🤝 Contributing

Contributions are welcome! Please follow the existing code style and create pull requests for any improvements.

## 📞 Support

For support, please contact the Mara team or open an issue in the repository.

---

**Mara** - Your AI-powered health companion 🌱
