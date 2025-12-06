# Health Tracking Implementation Plan

## Status: 🚧 IN PROGRESS

This document tracks the implementation of health tracking features for the Mara app.

## Phase 1: Core Health Tracking Models ✅ COMPLETE

- [x] Created `DailyStepsEntry` model
- [x] Created `DailySleepEntry` model  
- [x] Created `DailyWaterIntakeEntry` model
- [x] All models include validation and copyWith methods
- [x] NO mood/emotion tracking included

## Phase 2: Repository & Data Layer (IN PROGRESS)

### Files to Create:
1. `lib/features/health/domain/repositories/health_tracking_repository.dart` - Repository interface
2. `lib/features/health/data/datasources/local_health_data_source.dart` - Local storage implementation
3. `lib/features/health/data/repositories/health_tracking_repository_impl.dart` - Repository implementation
4. `lib/features/health/data/models/health_entry_json.dart` - JSON serialization helpers

### Implementation Details:
- Use JSON serialization for storing health entries
- Store entries by date key (YYYY-MM-DD format)
- Support history retrieval (last 7, 30 days)
- All storage is local-only (no backend calls)

## Phase 3: Providers (PENDING)

- Create Riverpod providers for health tracking
- Support loading/error states
- Reactive updates

## Phase 4: UI Updates (PENDING)

- Update Home screen cards
- Remove mood references
- Add quick input dialogs
- Empty states and CTAs

## Phase 5: Health Data Integration (PENDING)

- Add health package dependency
- Create HealthDataService abstraction
- Platform-specific implementations
- Permission handling

## Phase 6: Analytics Dashboard (PENDING)

- Chart integration
- Trend visualization
- Historical data display

## Phase 7: UX Enhancements (PENDING)

- Onboarding progress indicator
- Chat quick actions
- Notification service
- Error states
- Dark mode support

## Phase 8: Documentation & Tests (PENDING)

- Update ARCHITECTURE.md
- Create HEALTH_TRACKING.md
- Unit tests
- Widget tests
- Integration tests

