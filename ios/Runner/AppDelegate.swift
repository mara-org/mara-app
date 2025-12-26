import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // CRITICAL: Initialize Firebase FIRST, before anything else
    // This must happen before Flutter plugins are registered
    // FirebaseApp.configure() will automatically find GoogleService-Info.plist
    // in the app bundle and configure Firebase
    
    // Always configure Firebase - don't check if it's already configured
    // This ensures Firebase is ready before any plugin tries to access it
    FirebaseApp.configure()
    
    // Verify configuration succeeded
    if let app = FirebaseApp.app() {
      print("✅ Firebase configured successfully in AppDelegate")
      print("   Project ID: \(app.options.projectID ?? "MISSING")")
      print("   Bundle ID: \(app.options.bundleID ?? "MISSING")")
      if let apiKey = app.options.apiKey {
        let apiKeyPrefix = String(apiKey.prefix(10))
        print("   API Key: \(apiKeyPrefix)...")
      } else {
        print("   API Key: MISSING")
      }
    } else {
      print("❌ ERROR: FirebaseApp.configure() returned but app() is nil")
      print("❌ Check that GoogleService-Info.plist exists and is added to Copy Bundle Resources")
    }
    
    // Now register Flutter plugins (they can safely access Firebase)
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
