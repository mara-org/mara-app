# Health Tracking Feature Documentation

## Overview

The Health Tracking feature allows users to track their daily health metrics including steps, sleep duration, and water intake. The feature integrates with platform health services (HealthKit on iOS, Google Fit on Android) to automatically sync data from devices, while also supporting manual entry.

## Architecture

### Domain Models

**Location:** `lib/core/models/health/`

- **DailyStepsEntry**: Represents daily step count
  - `date`: DateTime (date only)
  - `steps`: int
  - `lastUpdatedAt`: DateTime

- **DailySleepEntry**: Represents daily sleep duration
  - `date`: DateTime (date only)
  - `hours`: double
  - `lastUpdatedAt`: DateTime

- **DailyWaterIntakeEntry**: Represents daily water intake
  - `date`: DateTime (date only)
  - `waterLiters`: double
  - `lastUpdatedAt`: DateTime

All models include:
- JSON serialization/deserialization
- Validation methods
- `copyWith()` for immutable updates
- Factory constructors for common cases

### Repository Layer

**Location:** `lib/features/health/`

#### Repository Interface

`lib/features/health/domain/repositories/health_tracking_repository.dart`

Defines the contract for health tracking operations:
- `getTodaySteps()`, `getTodaySleep()`, `getTodayWater()`
- `saveStepsEntry()`, `saveSleepEntry()`, `saveWaterIntakeEntry()`
- `getStepsHistory()`, `getSleepHistory()`, `getWaterHistory()`
- `syncWithRemoteStub()` (prepared for future backend integration)

#### Repository Implementation

`lib/features/health/data/repositories/health_tracking_repository_impl.dart`

Implements the repository interface using the local data source. Handles business logic and error handling.

### Data Source

**Location:** `lib/features/health/data/datasources/local_health_data_source.dart`

Handles local storage of health entries:
- Uses `LocalCache` (SharedPreferences) for persistence
- Stores entries as JSON strings keyed by date
- Maintains history lists for efficient retrieval
- Supports filtering by date range

### Health Data Service

**Location:** `lib/core/services/health_data_service.dart`

Abstract interface for platform-specific health data access:

```dart
abstract class IHealthDataService {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();
  Future<int?> getTodaySteps();
  Future<double?> getTodaySleepHours();
  Future<double?> getTodayWaterLiters();
}
```

Implementation uses the `health` package (v13.1.4) which provides:
- **iOS**: HealthKit integration
- **Android**: Google Fit integration

### Providers

**Location:** `lib/core/providers/health_tracking_providers.dart`

Riverpod providers for reactive health data access:

- `todayStepsProvider`: Today's steps entry
- `todaySleepProvider`: Today's sleep entry
- `todayWaterProvider`: Today's water intake entry
- `stepsHistoryProvider(days)`: Steps history (family provider)
- `sleepHistoryProvider(days)`: Sleep history (family provider)
- `waterHistoryProvider(days)`: Water intake history (family provider)

## User Interface

### Home Screen Cards

**Location:** `lib/features/home/presentation/home_screen.dart`

Three interactive cards display today's health data:
- **Steps Card**: Shows step count with goal progress
- **Sleep Card**: Shows sleep hours, tappable to log sleep
- **Water Card**: Shows water intake in liters, tappable to log water

### Input Dialogs

**Location:** `lib/features/home/presentation/widgets/`

- **SleepInputDialog**: Modal dialog to log sleep hours
  - Number input for hours (0-24)
  - Validation and error handling
  
- **WaterInputDialog**: Modal dialog to log water intake
  - Quick button for "One glass (250ml)"
  - Manual input for liters
  - Validation and error handling

### Analytics Dashboard

**Location:** `lib/features/analytics/presentation/analyst_dashboard_screen.dart`

Comprehensive analytics view with:
- Time period selector (Last 7 Days / Last 30 Days)
- Interactive charts for each metric
- Average calculations
- Empty states and loading indicators

#### Chart Widgets

**Location:** `lib/features/analytics/presentation/widgets/`

- **StepsChart**: Line chart showing steps trend
- **SleepChart**: Line chart showing sleep hours trend
- **WaterChart**: Bar chart showing water intake trend

Charts use `fl_chart` package (v0.69.0) for visualization.

## Health Data Integration

### Platform-Specific Setup

#### iOS (HealthKit)

1. **Info.plist Configuration**:

Add to `ios/Runner/Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Mara needs access to your health data to provide personalized health insights.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Mara needs to save your health data to track your progress.</string>
```

2. **Capabilities**:

Enable HealthKit capability in Xcode:
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target → Signing & Capabilities
- Click "+ Capability" → Add "HealthKit"

3. **Health Package Configuration**:

The `health` package automatically handles HealthKit permissions and data access.

#### Android (Google Fit)

1. **Manifest Permissions**:

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

2. **Google Fit API Setup**:

- Create a project in Google Cloud Console
- Enable Google Fit API
- Create OAuth 2.0 credentials
- Configure credentials in the app

3. **Health Package Configuration**:

The `health` package requires Google Fit API credentials to be configured.

### Implementation

The `HealthDataService` implementation (`lib/core/services/health_data_service.dart`) provides a placeholder structure. Full integration requires:

1. Configuring platform-specific permissions
2. Implementing actual health package calls
3. Handling permission requests and errors
4. Syncing device data to local storage

## Localization

All health tracking strings are localized in:
- `lib/l10n/app_en.arb` (English)
- `lib/l10n/app_ar.arb` (Arabic)

Key strings:
- `steps`, `sleep`, `water`
- `last7Days`, `last30Days`
- `averageSteps`, `averageSleep`, `averageWater`
- `stepsTrend`, `sleepTrend`, `waterTrend`
- `noHealthDataAvailable`
- Input dialog labels and messages

## Data Persistence

Health entries are stored locally using:
- **Storage Backend**: SharedPreferences (via `LocalCache`)
- **Format**: JSON strings
- **Key Pattern**: `daily_steps_YYYY-MM-DD`, `daily_sleep_YYYY-MM-DD`, `daily_water_YYYY-MM-DD`
- **History Tracking**: Maintains lists of dates with entries for efficient queries

## Testing

### Unit Tests

**Location:** `test/features/health/`

- `data/datasources/local_health_data_source_test.dart`: Data source operations
- `data/repositories/health_tracking_repository_test.dart`: Repository logic

**Location:** `test/core/services/`

- `health_data_service_test.dart`: Service interface and methods

### Widget Tests

**Location:** `test/ui/`

- `analytics/analytics_dashboard_test.dart`: Dashboard rendering and interactions
- Home screen tests include health card interactions

## Future Enhancements

1. **Backend Sync**: When backend is available, implement `syncWithRemoteStub()` to sync local data
2. **Health Goals**: Add goal tracking (daily targets for steps, sleep, water)
3. **Notifications**: Health reminder notifications
4. **Widgets**: Home screen widgets showing health metrics
5. **Export**: Export health data to CSV/JSON
6. **Insights**: AI-powered health insights based on tracked data

## Related Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Analytics Dashboard](../README.md#analytics)
- [Testing Strategy](ARCHITECTURE.md#testing-strategy)

