import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/analyst_dashboard_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/presentation/forgot_password_email_screen.dart';
import '../../features/auth/presentation/forgot_password_verify_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_email_screen.dart';
import '../../features/auth/presentation/sign_up_choices_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/presentation/welcome_back_screen.dart';
import '../../features/chat/presentation/mara_chat_history_screen.dart';
import '../../features/chat/presentation/mara_chat_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/presentation/language_selector_screen.dart';
import '../../features/onboarding/presentation/onboarding_insights_screen.dart';
import '../../features/onboarding/presentation/onboarding_personalized_screen.dart';
import '../../features/onboarding/presentation/onboarding_privacy_screen.dart';
import '../../features/onboarding/presentation/welcome_intro_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/permissions/presentation/camera_permission_screen.dart';
import '../../features/permissions/presentation/health_data_permission_screen.dart';
import '../../features/permissions/presentation/microphone_permission_screen.dart';
import '../../features/permissions/presentation/notifications_permission_screen.dart';
import '../../features/permissions/presentation/permissions_summary_screen.dart';
import '../../features/profile/presentation/privacy_webview_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/delete_account/delete_account_code_screen.dart';
import '../../features/settings/presentation/delete_account/delete_account_email_screen.dart';
import '../../features/settings/presentation/delete_account/delete_account_verify_screen.dart';
import '../../features/settings/presentation/logout_confirmation_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/terms_of_service_screen.dart';
import '../../features/setup/presentation/blood_type_screen.dart';
import '../../features/setup/presentation/dob_input_screen.dart';
import '../../features/setup/presentation/gender_screen.dart';
import '../../features/setup/presentation/goals_screen.dart';
import '../../features/setup/presentation/height_screen.dart';
import '../../features/setup/presentation/name_input_screen.dart';
import '../../features/setup/presentation/ready_screen.dart';
import '../../features/setup/presentation/weight_screen.dart';
import '../../features/setup/presentation/welcome_personal_screen.dart';
import '../../features/setup/setup_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/subscription/presentation/subscription_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language-selector',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return LanguageSelectorScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/welcome-intro',
        builder: (context, state) => const WelcomeIntroScreen(),
      ),
      GoRoute(
        path: '/onboarding-insights',
        builder: (context, state) => const OnboardingInsightsScreen(),
      ),
      GoRoute(
        path: '/onboarding-privacy',
        builder: (context, state) => const OnboardingPrivacyScreen(),
      ),
      GoRoute(
        path: '/onboarding-personalized',
        builder: (context, state) => const OnboardingPersonalizedScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-up-choices',
        builder: (context, state) => const SignUpChoicesScreen(),
      ),
      GoRoute(
        path: '/sign-in-email',
        builder: (context, state) => const SignInEmailScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/welcome-back',
        builder: (context, state) => const WelcomeBackScreen(),
      ),
      GoRoute(
        path: '/forgot-password-email',
        builder: (context, state) => const ForgotPasswordEmailScreen(),
      ),
      GoRoute(
        path: '/forgot-password-verify',
        builder: (context, state) => const ForgotPasswordVerifyScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/ready', builder: (context, state) => const ReadyScreen()),
      GoRoute(
        path: '/name-input',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          final fromLanguageChange =
              state.uri.queryParameters['fromLanguageChange'] == 'true';
          final languageCode = state.uri.queryParameters['language'];
          return NameInputScreen(
            isFromProfile: isFromProfile,
            fromLanguageChange: fromLanguageChange,
            languageCode: languageCode,
          );
        },
      ),
      GoRoute(
        path: '/dob-input',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return DobInputScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/gender',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return GenderScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/height',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return HeightScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/weight',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return WeightScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/blood-type',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return BloodTypeScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) {
          final isFromProfile = state.uri.queryParameters['from'] == 'profile';
          return GoalsScreen(isFromProfile: isFromProfile);
        },
      ),
      GoRoute(
        path: '/welcome-personal',
        builder: (context, state) => const WelcomePersonalScreen(),
      ),
      GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
      GoRoute(
        path: '/camera-permission',
        builder: (context, state) => const CameraPermissionScreen(),
      ),
      GoRoute(
        path: '/microphone-permission',
        builder: (context, state) => const MicrophonePermissionScreen(),
      ),
      GoRoute(
        path: '/notifications-permission',
        builder: (context, state) => const NotificationsPermissionScreen(),
      ),
      GoRoute(
        path: '/health-data-permission',
        builder: (context, state) => const HealthDataPermissionScreen(),
      ),
      GoRoute(
        path: '/permissions-summary',
        builder: (context, state) => const PermissionsSummaryScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalystDashboardScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final conversationId = state.uri.queryParameters['id'];
          return MaraChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/chat-history',
        builder: (context, state) => const MaraChatHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/privacy-webview',
        builder: (context, state) => const PrivacyWebViewScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/logout-confirmation',
        builder: (context, state) => const LogoutConfirmationScreen(),
      ),
      GoRoute(
        path: '/delete-account/email',
        builder: (context, state) => const DeleteAccountEmailScreen(),
      ),
      GoRoute(
        path: '/delete-account/code',
        builder: (context, state) => const DeleteAccountCodeScreen(),
      ),
      GoRoute(
        path: '/delete-account/verify',
        builder: (context, state) => const DeleteAccountVerifyScreen(),
      ),
    ],
  );
}
