import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

class WelcomePersonalScreen extends ConsumerWidget {
  const WelcomePersonalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);
    final name = profile.name ?? l10n.there;
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
                // Back button
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.languageButtonColor
                            .withOpacity( 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.languageButtonColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mara logo
                const Center(child: MaraLogo(width: 140, height: 99)),
                const SizedBox(height: 40),
                // Title
                Text(
                  l10n.welcomePersonalTitle(name),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 20),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.welcomePersonalSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.languageButtonColor,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Start Setup button
                PrimaryButton(
                  text: l10n.startSetup,
                  onPressed: () {
                    // Navigate directly to notifications permission (camera and microphone removed)
                    context.push('/notifications-permission');
                  },
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
