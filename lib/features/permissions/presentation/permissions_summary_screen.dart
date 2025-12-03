import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/permissions_provider.dart';
import '../../../l10n/app_localizations.dart';

class PermissionsSummaryScreen extends ConsumerWidget {
  const PermissionsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Mara logo
                const Center(child: MaraLogo(width: 258, height: 202)),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.reviewPermissions,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Permission list
                _PermissionItem(
                  title: l10n.camera,
                  isEnabled: permissions.camera,
                ),
                const SizedBox(height: 16),
                _PermissionItem(
                  title: l10n.microphone,
                  isEnabled: permissions.microphone,
                ),
                const SizedBox(height: 16),
                _PermissionItem(
                  title: l10n.notifications,
                  isEnabled: permissions.notifications,
                ),
                const SizedBox(height: 16),
                _PermissionItem(
                  title: l10n.healthData,
                  isEnabled: permissions.healthData,
                ),
                const SizedBox(height: 40),
                // Start using Mara button
                PrimaryButton(
                  text: l10n.startUsingMara,
                  onPressed: () {
                    context.go('/home');
                  },
                ),
                const SizedBox(height: 20),
                // Privacy note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.yourPrivacyIsAlwaysOurTopPriority,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
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

  const _PermissionItem({required this.title, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isEnabled ? const Color(0xFFC4F4FF) : const Color(0xFFA2BCC2),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isEnabled
                ? const Color(0xFF10A9CC)
                : const Color(0xFFFCFEFF),
            fontSize: isEnabled ? 20 : 16,
            fontWeight: FontWeight.normal,
            height: 1,
          ),
        ),
      ),
    );
  }
}
