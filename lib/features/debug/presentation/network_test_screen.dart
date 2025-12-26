import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/simple_api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import 'package:dio/dio.dart';

/// Network test screen for debugging.
/// 
/// Tests backend connectivity and displays health/version status.
class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  final SimpleApiClient _apiClient = SimpleApiClient();
  
  bool _isLoading = false;
  String? _healthStatus;
  String? _versionStatus;
  String? _verificationStatus;
  int? _healthLatency;
  int? _versionLatency;
  int? _verificationLatency;
  String? _error;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _healthStatus = null;
      _versionStatus = null;
      _healthLatency = null;
      _versionLatency = null;
    });

    try {
      // Test /health
      final healthStart = DateTime.now();
      try {
        final healthResponse = await _apiClient.get(AppConfig.healthEndpoint);
        final healthEnd = DateTime.now();
        final healthMs = healthEnd.difference(healthStart).inMilliseconds;
        
        setState(() {
          _healthStatus = healthResponse['status'] ?? 'OK';
          _healthLatency = healthMs;
        });
      } catch (e) {
        setState(() {
          _healthStatus = 'Error: ${e.toString()}';
        });
      }

      // Test /version
      final versionStart = DateTime.now();
      try {
        final versionResponse = await _apiClient.get(AppConfig.versionEndpoint);
        final versionEnd = DateTime.now();
        final versionMs = versionEnd.difference(versionStart).inMilliseconds;
        
        setState(() {
          _versionStatus = versionResponse['version'] ?? 
                          versionResponse['data']?.toString() ?? 
                          'Unknown';
          _versionLatency = versionMs;
        });
      } catch (e) {
        setState(() {
          _versionStatus = 'Error: ${e.toString()}';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testVerificationCode() async {
    // Verification code endpoint removed - Firebase handles email verification via links
    setState(() {
      _verificationStatus = 'ℹ️ Email verification is handled by Firebase via email links. No backend endpoint needed.';
      _verificationLatency = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Network Test'),
        backgroundColor: AppColors.homeHeaderBackground,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Environment info
              Card(
                color: isDark ? AppColorsDark.cardBackground : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Environment',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConfig.environmentName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Base URL',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConfig.baseUrl,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Health check
              Card(
                color: isDark ? AppColorsDark.cardBackground : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Health Check',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                            ),
                          ),
                          if (_healthLatency != null)
                            Text(
                              '${_healthLatency}ms',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading && _healthStatus == null)
                        const CircularProgressIndicator()
                      else if (_healthStatus != null)
                        Text(
                          _healthStatus!,
                          style: TextStyle(
                            fontSize: 14,
                            color: _healthStatus!.contains('Error')
                                ? Colors.red
                                : (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Version check
              Card(
                color: isDark ? AppColorsDark.cardBackground : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Version',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                            ),
                          ),
                          if (_versionLatency != null)
                            Text(
                              '${_versionLatency}ms',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading && _versionStatus == null)
                        const CircularProgressIndicator()
                      else if (_versionStatus != null)
                        Text(
                          _versionStatus!,
                          style: TextStyle(
                            fontSize: 14,
                            color: _versionStatus!.contains('Error')
                                ? Colors.red
                                : (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Verification code test
              Card(
                color: isDark ? AppColorsDark.cardBackground : AppColors.cardBackground,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Verification Code Test',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                            ),
                          ),
                          if (_verificationLatency != null)
                            Text(
                              '${_verificationLatency}ms',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'test@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? AppColorsDark.cardBackground 
                              : Colors.grey[100],
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _testVerificationCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.languageButtonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Test Verification Code'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_verificationStatus != null)
                        Text(
                          _verificationStatus!,
                          style: TextStyle(
                            fontSize: 14,
                            color: _verificationStatus!.contains('✅')
                                ? Colors.green
                                : _verificationStatus!.contains('❌')
                                    ? Colors.red
                                    : (isDark ? AppColorsDark.textPrimary : AppColors.textPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Refresh button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _runTests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.languageButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Refresh Tests'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

