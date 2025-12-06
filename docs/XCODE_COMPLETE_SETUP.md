# Complete Xcode Setup Guide for Mara App

This comprehensive guide covers **ALL** Xcode configurations needed for the Mara app, including capabilities, entitlements, Info.plist settings, and signing.

## 📋 Table of Contents

1. [Opening the Project](#opening-the-project)
2. [Signing & Certificates](#signing--certificates)
3. [Capabilities](#capabilities)
4. [Info.plist Permissions](#infoplist-permissions)
5. [Build Settings](#build-settings)
6. [Entitlements](#entitlements)
7. [Firebase Configuration (Optional)](#firebase-configuration-optional)
8. [Testing & Verification](#testing--verification)

---

## 1. Opening the Project

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   ⚠️ **IMPORTANT:** Always open `.xcworkspace`, NOT `.xcodeproj`

2. **Wait for indexing** to complete (top bar shows progress)

3. **Select the Runner target** in the project navigator (left sidebar)

---

## 2. Signing & Certificates

### Step-by-Step:

1. **Select Runner target** → Click on **"Runner"** in the project navigator
2. **Go to "Signing & Capabilities" tab**
3. **Configure signing:**

   - **Automatically manage signing:** ✅ Check this box
   - **Team:** Select your Apple Developer Team (e.g., `HF8K3TK2U7`)
   - **Bundle Identifier:** Should be `com.iammara.app`
   - **Provisioning Profile:** Xcode will create/select automatically

4. **Verify for all configurations:**
   - Check that signing works for:
     - **Debug** configuration
     - **Release** configuration
     - **Profile** configuration

5. **If you see signing errors:**
   - Ensure you're logged into Xcode with your Apple Developer account
   - Go to **Xcode → Settings → Accounts**
   - Add your Apple ID if not present
   - Download certificates if prompted

---

## 3. Capabilities

Add the following capabilities by clicking **"+ Capability"** button:

### ✅ Required Capabilities:

#### 1. **HealthKit** (REQUIRED)
- **Why:** For health data integration (steps, sleep, water)
- **Steps:**
  1. Click **"+ Capability"**
  2. Search for **"HealthKit"**
  3. Add it
  4. Ensure it's enabled (you'll see a HealthKit section)
  5. The entitlements file will be automatically linked

#### 2. **Push Notifications** (RECOMMENDED)
- **Why:** For local notifications and health reminders
- **Steps:**
  1. Click **"+ Capability"**
  2. Search for **"Push Notifications"**
  3. Add it
  4. This enables background notification delivery

#### 3. **Background Modes** (RECOMMENDED)
- **Why:** For background notifications and health data updates
- **Steps:**
  1. Click **"+ Capability"**
  2. Search for **"Background Modes"**
  3. Add it
  4. Enable the following modes:
     - ✅ **Remote notifications**
     - ✅ **Background processing** (if needed for health sync)

#### 4. **Keychain Sharing** (OPTIONAL - if using shared keychain)
- **Why:** For secure credential sharing across app extensions
- **Steps:**
  1. Click **"+ Capability"**
  2. Search for **"Keychain Sharing"**
  3. Add it
  4. Add a keychain group (e.g., `com.iammara.app.keychain`)

### 📝 Optional Capabilities:

#### 5. **App Groups** (OPTIONAL - for widgets or extensions)
- Only needed if you plan to create widgets or app extensions

#### 6. **Associated Domains** (OPTIONAL - for universal links)
- Only needed if you want deep linking from web URLs

---

## 4. Info.plist Permissions

### Already Configured ✅

The following permissions are **already set** in `ios/Runner/Info.plist`:

```xml
<!-- Health Data -->
<key>NSHealthShareUsageDescription</key>
<string>Mara needs access to your health data to provide personalized health insights.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Mara needs to save your health data to track your progress.</string>
```

### Additional Permissions to Add (if not present)

If you need to add these permissions manually, edit `ios/Runner/Info.plist`:

#### Camera Permission (for future facial analysis)
```xml
<key>NSCameraUsageDescription</key>
<string>Mara needs camera access for facial expression analysis and fatigue detection.</string>
```

#### Microphone Permission (for voice input)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Mara needs microphone access for voice input and natural conversation.</string>
```

#### Photo Library Permission (if needed for profile pictures)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Mara needs photo library access to set your profile picture.</string>
```

#### Face ID Permission (for biometric authentication)
```xml
<key>NSFaceIDUsageDescription</key>
<string>Mara uses Face ID to securely authenticate you.</string>
```

#### Location Permission (if needed for location-based features)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Mara needs location access to provide location-based health insights.</string>
```

### How to Add:

1. **In Xcode:**
   - Select `Runner` target
   - Go to **"Info"** tab
   - Expand **"Custom iOS Target Properties"**
   - Click **"+"** to add new keys
   - Search for the permission key (e.g., `Privacy - Camera Usage Description`)
   - Add the description

2. **Or manually edit:**
   - Right-click `ios/Runner/Info.plist` → **Open As → Source Code**
   - Add the XML keys shown above

---

## 5. Build Settings

### Important Build Settings to Verify:

1. **Select Runner target** → **"Build Settings"** tab

2. **Search for these settings:**

   - **iOS Deployment Target:** Should be `14.0` or higher
   - **Swift Language Version:** Should be `Swift 5`
   - **Bitcode:** Should be `NO` (ENABLE_BITCODE = NO)
   - **Code Signing Style:** Should be `Automatic` (if using automatic signing)

3. **Architectures:**
   - **Architectures:** Should include `arm64` for modern devices
   - **Excluded Architectures:** Can exclude `armv7` if not needed

---

## 6. Entitlements

### Current Entitlements File

The entitlements file is located at: `ios/Runner/Runner.entitlements`

### Already Configured ✅

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.healthkit</key>
	<true/>
	<key>com.apple.developer.healthkit.access</key>
	<array/>
</dict>
</plist>
```

### Additional Entitlements (if needed)

After adding capabilities in Xcode, the entitlements file will be automatically updated. Common entitlements you might see:

- **HealthKit:** `com.apple.developer.healthkit`
- **Push Notifications:** `aps-environment` (development or production)
- **Background Modes:** `com.apple.developer.background-modes`
- **Keychain Sharing:** `keychain-access-groups`
- **App Groups:** `com.apple.security.application-groups`

### Verify Entitlements:

1. **Select Runner target** → **"Signing & Capabilities"** tab
2. Check that all added capabilities appear as sections
3. The entitlements file will show the corresponding keys

---

## 7. Firebase Configuration (Optional)

### If Using Firebase:

1. **Add GoogleService-Info.plist:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Drag it into `ios/Runner/` folder in Xcode
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **Runner** target

2. **Install Firebase CocoaPods:**
   - Already configured in `ios/Podfile`
   - Run `pod install` in `ios/` directory if needed

3. **Verify Firebase SDK:**
   - Check that Firebase packages are in `pubspec.yaml`:
     - `firebase_core: ^3.0.0`
     - `firebase_analytics: ^11.0.0`
     - `firebase_crashlytics: ^4.0.0`
     - `firebase_remote_config: ^5.0.0`

---

## 8. Testing & Verification

### Before Testing:

1. **Clean Build Folder:**
   - **Product → Clean Build Folder** (⇧⌘K)

2. **Verify Signing:**
   - Check for any signing errors in Xcode
   - All capabilities should show as enabled (green checkmarks)

3. **Check Build Settings:**
   - No warnings about missing configurations
   - Deployment target matches your device iOS version

### Testing Checklist:

- ✅ **Build succeeds** without errors
- ✅ **App launches** on simulator/device
- ✅ **HealthKit permissions** can be requested (on real device)
- ✅ **Notifications** work (check Settings → Notifications)
- ✅ **Biometric authentication** works (if implemented)
- ✅ **All features** function as expected

### Common Issues & Solutions:

#### Issue: "HealthKit is not available"
- **Solution:** HealthKit only works on **real devices**, not simulators
- **Action:** Test on a physical iPhone

#### Issue: Signing errors
- **Solution:** Ensure you're logged into Xcode with your Apple Developer account
- **Action:** Xcode → Settings → Accounts → Add Apple ID

#### Issue: Capability not working
- **Solution:** Ensure the capability is enabled and entitlements file is linked
- **Action:** Check "Signing & Capabilities" tab for the capability

#### Issue: Permission dialog doesn't appear
- **Solution:** Check that the permission description is in Info.plist
- **Action:** Verify the NS*UsageDescription key exists

---

## 📋 Quick Reference Checklist

Use this checklist to ensure everything is configured:

### Signing & Certificates
- [ ] Automatically manage signing is enabled
- [ ] Team is selected (e.g., HF8K3TK2U7)
- [ ] Bundle Identifier is `com.iammara.app`
- [ ] No signing errors

### Capabilities
- [ ] HealthKit capability added
- [ ] Push Notifications capability added (if needed)
- [ ] Background Modes capability added (if needed)
- [ ] All capabilities show as enabled

### Info.plist
- [ ] NSHealthShareUsageDescription present
- [ ] NSHealthUpdateUsageDescription present
- [ ] NSCameraUsageDescription present (if using camera)
- [ ] NSMicrophoneUsageDescription present (if using microphone)
- [ ] NSFaceIDUsageDescription present (if using biometrics)

### Build Settings
- [ ] iOS Deployment Target: 14.0+
- [ ] Swift Version: 5.0
- [ ] Bitcode: NO
- [ ] Code Signing: Automatic

### Testing
- [ ] App builds successfully
- [ ] App launches on device/simulator
- [ ] HealthKit permissions work (real device)
- [ ] Notifications work
- [ ] All features functional

---

## 🚀 Next Steps

After completing all Xcode configurations:

1. **Test on a real device** (HealthKit requires real device)
2. **Verify all permissions** work correctly
3. **Test notifications** and background modes
4. **Check App Store Connect** settings if preparing for release

---

## 📚 Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Push Notifications Guide](https://developer.apple.com/documentation/usernotifications)
- [Xcode Capabilities Guide](https://developer.apple.com/documentation/xcode/configuring-signing-and-capabilities)

---

## ⚠️ Important Notes

1. **Always open `.xcworkspace`**, not `.xcodeproj`
2. **HealthKit only works on real devices**, not simulators
3. **Some capabilities require Apple Developer Program membership**
4. **Test thoroughly** before submitting to App Store
5. **Keep signing certificates secure** and backed up

---

**Last Updated:** 2025-01-16  
**App Version:** 1.1.0+3

