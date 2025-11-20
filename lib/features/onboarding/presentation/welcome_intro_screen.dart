import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';

class WelcomeIntroScreen extends ConsumerWidget {
  const WelcomeIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale to force rebuild when it changes
    ref.watch(appLocaleProvider);
    final l10n = AppLocalizations.of(context)!;
    final h = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFC6ECFF), // #C6ECFF (top)
                  Color(0xFF339AD0), // #339AD0 (bottom)
                ],
              ),
            ),
          ),
          // Title positioned at Y = 324 (~38% of screen height)
          PositionedDirectional(
            top: h * 0.38,
            start: 24,
            end: 24,
            child: Text(
              l10n.welcomeTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0EA5C6), // #0EA5C6
              ),
            ),
          ),
          // Subtitle positioned at Y = 382 (~45% of screen height)
          PositionedDirectional(
            top: h * 0.45,
            start: 24,
            end: 24,
            child: Text(
              l10n.welcomeSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF10A9CC), // #10A9CC
                height: 1.5,
              ),
            ),
          ),
          // Bottom white card (fixed height ~22% of screen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: h * 0.22 + MediaQuery.of(context).padding.bottom,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 24,
                  end: 24,
                  top: 32,
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      text: l10n.continueButton,
                      width: 324,
                      height: 52,
                      borderRadius: 20,
                      onPressed: () {
                        context.go('/onboarding-insights');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
