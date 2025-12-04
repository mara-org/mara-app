# Contributing to Mara

Thank you for your interest in contributing to the Mara mobile application! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Follow the project's coding standards

## Getting Started

### Prerequisites

- Flutter SDK 3.27.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Git

### Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/your-username/mara-app.git
   cd mara-app
   ```

2. **Run setup script:**
   ```bash
   bash scripts/setup-dev-environment.sh
   ```

3. **Verify setup:**
   ```bash
   flutter doctor
   flutter test
   ```

## Development Workflow

### Branching Strategy

- `main` - Production-ready code
- `staging` - Pre-production testing
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Making Changes

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Follow the coding style (see below)
   - Write tests for new functionality
   - Update documentation if needed

3. **Run checks locally:**
   ```bash
   # Format code
   dart format .
   
   # Run static analysis
   flutter analyze
   
   # Run tests
   flutter test
   
   # Run integration tests (if applicable)
   flutter test integration_test/
   ```

4. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format .` to format code
- Follow the project's `analysis_options.yaml` rules
- Prefer `const` constructors where possible
- Use meaningful variable and function names

### Code Organization

- **Features:** Organize code by feature in `lib/features/`
- **Core:** Shared utilities go in `lib/core/`
- **Tests:** Mirror the `lib/` structure in `test/`

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

### Documentation

- Document public APIs with Dart doc comments
- Include examples in documentation
- Update `CHANGELOG.md` for user-facing changes

## Testing

### Unit Tests

- Write unit tests for business logic
- Location: `test/`
- Run: `flutter test`

### Widget Tests

- Test UI components
- Use `test_utils.dart` helpers
- Run: `flutter test`

### Integration Tests

- Test end-to-end flows
- Location: `integration_test/`
- Run: `flutter test integration_test/`

### Coverage

- Aim for >60% coverage for new code
- Per-file coverage is checked in CI
- Run: `flutter test --coverage`

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No linter errors (`flutter analyze`)

### PR Description

Include:
- What changes were made
- Why these changes were made
- How to test the changes
- Screenshots (for UI changes)

### Review Process

1. CI checks must pass
2. At least one approval required
3. Address review feedback
4. Maintainer merges when ready

## CI Expectations

The following checks run automatically:

- **Code Formatting:** Code must be formatted
- **Static Analysis:** No errors or warnings
- **Tests:** All tests must pass
- **Coverage:** Per-file coverage check (60% threshold)
- **Build:** App must build for Android/iOS/Web

## Architecture Guidelines

### Frontend-Only Repository

- **This repo is frontend-only** (Flutter mobile app)
- Backend code lives in a separate repository
- Do not add backend/server code here

### Feature-Based Structure

```
lib/
  features/
    auth/
      presentation/  # UI
      domain/        # Business logic (future)
      data/          # Data access (future)
    chat/
      presentation/
      domain/
      data/
  core/
    utils/           # Shared utilities
    network/         # HTTP client, retry, circuit breaker
    storage/         # Local cache
    feature_flags/   # Feature flags
```

### Dependency Injection

- Use Riverpod for state management and DI
- Services should be easily mockable for tests
- Avoid global singletons where possible

## Common Tasks

### Adding a New Feature

1. Create feature directory: `lib/features/your_feature/`
2. Add presentation layer (screens/widgets)
3. Add tests
4. Update navigation if needed
5. Document in `docs/ARCHITECTURE.md` if significant

### Fixing a Bug

1. Write a test that reproduces the bug
2. Fix the bug
3. Ensure test passes
4. Update documentation if behavior changed

### Updating Dependencies

1. Update `pubspec.yaml`
2. Run `flutter pub get`
3. Test thoroughly
4. Update `CHANGELOG.md`

## Getting Help

- **Documentation:** Check `docs/` directory
- **Architecture:** See `docs/ARCHITECTURE.md`
- **Issues:** Open a GitHub issue
- **Discussions:** Use GitHub Discussions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

