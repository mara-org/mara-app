// TODO: Re-enable when mockito package is added to dev_dependencies
/*
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mara_app/core/network/api_client.dart';
import 'package:mara_app/core/config/api_config.dart';
import 'package:mara_app/core/utils/firebase_auth_helper.dart';

@GenerateMocks(
    [Dio, InterceptorsWrapper, RequestOptions, ErrorInterceptorHandler])
void main() {
  group('ApiClient Authorization Header', () {
    test('should attach Authorization header with Firebase token', () async {
      // Mock Firebase token
      // In real test, you'd mock FirebaseAuthHelper.getFreshFirebaseToken()
      const testToken = 'firebase-id-token-123';

      // Verify that the interceptor adds Authorization header
      // This is tested through integration tests or by mocking Dio interceptors
    });

    test('should handle 401 by clearing tokens and signing out', () {
      // Test that 401 errors trigger:
      // 1. Clear tokens
      // 2. Sign out from Firebase
      // This is verified in the ApiClient interceptor
    });

    test('should refresh token if expired', () {
      // Test that getIdToken(true) is called to force refresh
      // This is handled by FirebaseAuthHelper.getFreshFirebaseToken()
    });
  });
}
*/
