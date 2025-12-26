import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/permissions_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

class PermissionsSummaryScreen extends ConsumerStatefulWidget {
  const PermissionsSummaryScreen({super.key});

  @override
  ConsumerState<PermissionsSummaryScreen> createState() =>
      _PermissionsSummaryScreenState();
}

class _PermissionsSummaryScreenState
    extends ConsumerState<PermissionsSummaryScreen> {
  bool _isCompleting = false;
  String? _errorMessage;

  Future<void> _completeOnboarding() async {
    final profile = ref.read(userProfileProvider);
    final permissions = ref.read(permissionsProvider);

    // Validate required fields
    if (profile.name == null ||
        profile.name!.isEmpty ||
        profile.dateOfBirth == null ||
        profile.gender == null ||
        profile.height == null ||
        profile.weight == null ||
        profile.heightUnit == null ||
        profile.weightUnit == null ||
        profile.mainGoal == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCompleting = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();

      Logger.info(
        'Completing onboarding profile',
        feature: 'onboarding',
        screen: 'permissions_summary',
        extra: {
          'name': profile.name,
          'gender': profile.gender!.name,
          'has_blood_type': profile.bloodType != null,
        },
      );

      final response = await apiService.completeOnboarding(
        name: profile.name!,
        dateOfBirth: profile.dateOfBirth!,
        gender: profile.gender!.name, // Convert enum to string: "male" or "female"
        height: profile.height!,
        heightUnit: profile.heightUnit!,
        weight: profile.weight!,
        weightUnit: profile.weightUnit!,
        bloodType: profile.bloodType,
        mainGoal: profile.mainGoal!,
        permissions: {
          'notifications': permissions.notifications,
          'healthData': permissions.healthData,
        },
      );

      Logger.info(
        'Onboarding completed successfully',
        feature: 'onboarding',
        screen: 'permissions_summary',
        extra: {
          'user_id': response.userId,
          'onboarding_completed': response.onboardingCompleted,
        },
      );

      // Navigate to home after success
      if (!mounted) return;
      context.go('/home');
    } on UnauthorizedException catch (e) {
      Logger.error(
        'Onboarding completion failed: Unauthorized',
        feature: 'onboarding',
        screen: 'permissions_summary',
        error: e,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Please sign in again';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in again'),
          backgroundColor: Colors.red,
        ),
      );
    } on NetworkException catch (e) {
      Logger.error(
        'Onboarding completion failed: Network error',
        feature: 'onboarding',
        screen: 'permissions_summary',
        error: e,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.orange,
        ),
      );
    } on ServerException catch (e) {
      Logger.error(
        'Onboarding completion failed: Server error',
        feature: 'onboarding',
        screen: 'permissions_summary',
        error: e,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Server error. Please try again later.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Server error. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Onboarding completion failed: Unexpected error',
        feature: 'onboarding',
        screen: 'permissions_summary',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final permissions = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Mara logo
                const Center(child: MaraLogo(width: 140, height: 99)),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.reviewPermissions,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.permissionsSummarySubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColorsDark.textSecondary
                          : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Permission list
                _PermissionItem(
                  title: l10n.notifications,
                  isEnabled: permissions.notifications,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _PermissionItem(
                  title: l10n.healthData,
                  isEnabled: permissions.healthData,
                  isDark: isDark,
                ),
                const SizedBox(height: 40),
                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // Start using Mara button
                _isCompleting
                    ? SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.languageButtonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const SpinningMaraLogo(
                            width: 32,
                            height: 32,
                          ),
                        ),
                      )
                    : PrimaryButton(
                        text: l10n.startUsingMara,
                        onPressed: _completeOnboarding,
                      ),
                const SizedBox(height: 20),
                // Privacy note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.yourPrivacyIsAlwaysOurTopPriority,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (isDark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary)
                          .withOpacity( 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final bool isDark;

  const _PermissionItem({
    required this.title,
    required this.isEnabled,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isEnabled
            ? (isDark
                ? AppColors.languageButtonColor.withOpacity( 0.2)
                : const Color(0xFFC4F4FF))
            : (isDark ? AppColorsDark.cardBackground : const Color(0xFFA2BCC2)),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isEnabled
                ? AppColors.languageButtonColor
                : (isDark
                    ? AppColorsDark.textSecondary
                    : const Color(0xFFFCFEFF)),
            fontSize: 20,
            fontWeight: FontWeight.normal,
            height: 1,
          ),
        ),
      ),
    );
  }
}
