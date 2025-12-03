import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Error view widget for displaying network and other errors
///
/// Provides a consistent error UI with:
/// - Error message
/// - Retry button
/// - "Check connection" message for network errors
///
/// Usage:
/// ```dart
/// ErrorView(
///   message: 'Failed to load data',
///   onRetry: () => _loadData(),
///   isNetworkError: true,
/// )
/// ```
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isNetworkError;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isNetworkError = false,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isNetworkError) ...[
              const SizedBox(height: 8),
              Text(
                'Please check your internet connection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.languageButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

