# HealthKit & Health Connect Setup Guide

This guide provides step-by-step instructions for setting up real HealthKit (iOS) and Health Connect (Android) integration in the Mara app.

## iOS - HealthKit Setup

### 1. Info.plist Configuration

The `Info.plist` file already includes the required permission descriptions:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Mara needs access to your health data to provide personalized health insights.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Mara needs to save your health data to track your progress.</string>
```

✅ **Already configured in:** `ios/Runner/Info.plist`

### 2. HealthKit Capability (REQUIRED - Manual Step)

**IMPORTANT:** You must enable the HealthKit capability in Xcode:

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select the **Runner** target in the project navigator

3. Go to the **Signing & Capabilities** tab

4. Click the **"+ Capability"** button

5. Search for and add **"HealthKit"**

6. Ensure the capability is enabled (you should see a HealthKit section appear)

7. The entitlements file (`ios/Runner/Runner.entitlements`) has been created automatically and will be linked when you add the capability in Xcode

### 3. Verify Setup

After adding the HealthKit capability:
- The `Runner.entitlements` file will be automatically linked
- HealthKit framework will be available in your app
- Permission requests will work when the app runs

## Android - Health Connect Setup

### 1. AndroidManifest.xml Configuration

The manifest already includes:
- ✅ Activity Recognition permission
- ✅ Health Connect package queries

**Location:** `android/app/src/main/AndroidManifest.xml`

### 2. Health Connect Installation

Health Connect must be installed on the Android device:

- **Android 14+**: Health Connect is pre-installed
- **Android 9-13**: Users need to install Health Connect from Google Play Store
- The app will automatically detect if Health Connect is available

### 3. Required Permissions

The `health` package handles runtime permissions automatically:
- Activity Recognition (for steps)
- Health data read/write permissions (handled by Health Connect)

## Testing the Integration

### On iOS Simulator

1. **Note**: HealthKit works on real devices, not simulators
2. For testing on a real iPhone:
   - Build and install the app on a physical device
   - Go to Settings → Health → Data Sources & Access
   - Grant permissions to Mara app
   - Test data sync in the app

### On Android

1. Ensure Health Connect is installed (download from Play Store if needed)
2. Run the app
3. When prompted, grant Health Connect permissions
4. Test data sync

## Data Types Supported

The app currently tracks:

- **Steps**: `HealthDataType.STEPS`
- **Sleep**: `HealthDataType.SLEEP_IN_BED` (primary), `HealthDataType.SLEEP_ASLEEP` (fallback)
- **Water**: `HealthDataType.WATER` (iOS only)

## Troubleshooting

### iOS Issues

**Problem**: HealthKit permission dialog doesn't appear
- **Solution**: Ensure HealthKit capability is enabled in Xcode

**Problem**: "HealthKit is not available"
- **Solution**: HealthKit only works on real iOS devices, not simulators

**Problem**: No data after granting permissions
- **Solution**: Check that the Health app has data sources configured (e.g., Apple Watch, iPhone)

### Android Issues

**Problem**: Health Connect not found
- **Solution**: Install Health Connect from Google Play Store

**Problem**: Permission request fails
- **Solution**: Ensure the app has the required permissions in AndroidManifest.xml

**Problem**: No sleep data available
- **Solution**: Health Connect requires sleep tracking apps (like Sleep Cycle, Sleep as Android) to sync data

## Implementation Details

### Service Location

Health data service: `lib/core/services/health_data_service.dart`

### Key Features

1. **Automatic Platform Detection**: Uses `health` package to detect iOS/Android
2. **Permission Management**: Requests and checks permissions automatically
3. **Data Aggregation**: Properly calculates totals (e.g., total steps, sleep duration)
4. **Error Handling**: Graceful fallbacks if data is unavailable

### Sleep Data Calculation

The service uses intelligent sleep calculation:
- Prioritizes `SLEEP_IN_BED` (most comprehensive)
- Falls back to `SLEEP_ASLEEP` if needed
- Merges overlapping sleep segments
- Calculates total duration accurately

## Next Steps

1. **Enable HealthKit in Xcode** (see iOS setup above)
2. **Test on real devices** (simulators have limited health data)
3. **Configure data sources** in Health/Health Connect apps
4. **Verify data sync** in the Mara app

For more information, see:
- [Health Package Documentation](https://pub.dev/packages/health)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Health Connect Documentation](https://developer.android.com/guide/health-and-fitness/health-connect)

