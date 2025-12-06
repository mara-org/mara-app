import 'package:local_auth/local_auth.dart';
import '../storage/local_cache.dart';
import '../utils/logger.dart';

/// Abstract interface for biometric authentication.
abstract class IBiometricAuthService {
  /// Check if biometric authentication is available on the device.
  Future<bool> isAvailable();

  /// Authenticate using biometrics.
  Future<bool> authenticate({String? reason});

  /// Check if biometric authentication is enabled by user.
  Future<bool> isEnabled();

  /// Enable or disable biometric authentication.
  Future<bool> setEnabled(bool enabled);
}

/// Service for biometric authentication (Face ID, Touch ID, Fingerprint).
class BiometricAuthService implements IBiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (e, stackTrace) {
      Logger.error(
        'BiometricAuthService: Error checking availability',
        error: e,
        stackTrace: stackTrace,
        feature: 'biometric_auth',
        screen: 'biometric_auth_service',
      );
      return false;
    }
  }

  @override
  Future<bool> authenticate({String? reason}) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access Mara',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error(
        'BiometricAuthService: Error during authentication',
        error: e,
        stackTrace: stackTrace,
        feature: 'biometric_auth',
        screen: 'biometric_auth_service',
      );
      return false;
    }
  }

  @override
  Future<bool> isEnabled() async {
    try {
      await LocalCache.init();
      return LocalCache.getBool('biometric_auth_enabled') ?? false;
    } catch (e, stackTrace) {
      Logger.error(
        'BiometricAuthService: Error checking if enabled',
        error: e,
        stackTrace: stackTrace,
        feature: 'biometric_auth',
        screen: 'biometric_auth_service',
      );
      return false;
    }
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    try {
      await LocalCache.init();
      return await LocalCache.saveBool('biometric_auth_enabled', enabled);
    } catch (e, stackTrace) {
      Logger.error(
        'BiometricAuthService: Error setting enabled state',
        error: e,
        stackTrace: stackTrace,
        feature: 'biometric_auth',
        screen: 'biometric_auth_service',
      );
      return false;
    }
  }
}
