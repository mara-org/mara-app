import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/spinning_mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/email_provider.dart';
import '../../../core/providers/temp_auth_provider.dart';
import '../../../core/session/session_service.dart';
import '../../../core/utils/firebase_auth_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/firebase_auth_helper.dart';

class WelcomeBackScreen extends ConsumerStatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  ConsumerState<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController(); // Controller for scrolling to error
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailPrefilled = false; // Track if email has been pre-filled

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourEmail;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return l10n.pleaseEnterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterYourPassword;
    }
    return null;
  }

  Future<void> _handleAppleSignIn() async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info(
        'Starting Sign in with Apple',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );

      // Step 1: Sign in with Apple (works for both new and existing users)
      await FirebaseAuthHelper.signInWithApple();

      // Step 2: Create backend session (send Firebase ID token for verification)
      Logger.info(
        'Apple sign-in successful, creating backend session',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );
      
      final sessionService = SessionService();
      try {
        await sessionService.createBackendSession();
        Logger.info(
          'Backend session created successfully',
          feature: 'auth',
          screen: 'welcome_back_screen',
        );
        
        // Step 3: Fetch user info and entitlements
        try {
          Logger.info(
            'Fetching user info',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
          await sessionService.fetchUserInfo();
          Logger.info(
            'User info fetched successfully',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
        } catch (e) {
          Logger.warning(
            'Failed to fetch user info: $e',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
        }
      } catch (e, stackTrace) {
        Logger.error(
          'Backend session failed',
          feature: 'auth',
          screen: 'welcome_back_screen',
          error: e,
          stackTrace: stackTrace,
        );
        
        // Backend session failed - check if it's a backend down error
        if (e.toString().contains('network') || 
            e.toString().contains('connection') ||
            e.toString().contains('timeout') ||
            e.toString().contains('unavailable')) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Service unavailable. Please try again later.';
          });
          
          // Scroll to show error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                600,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
          return;
        }
        // Other errors - allow Apple sign-in to proceed
        Logger.warning(
          'Allowing Apple sign-in to proceed despite backend error',
          feature: 'auth',
          screen: 'welcome_back_screen',
        );
      }

      if (!mounted) return;

      // Step 4: Get user email (if available) and navigate
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (email != null && email.isNotEmpty) {
        ref.read(emailProvider.notifier).setEmail(email);
      }
      
      Logger.info(
        'Apple sign-in successful, navigating to home',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      
      Logger.error(
        'Apple sign-in error: $e',
        feature: 'auth',
        screen: 'welcome_back_screen',
        error: e,
      );
      
      String errorMsg = 'Sign in with Apple failed. Please try again.';
      
      // Handle device limit error
      if (e is DeviceLimitException) {
        setState(() {
          _isLoading = false;
          if (e.plan == 'free') {
            _errorMessage = '${e.message}\n\nUpgrade to Premium to use up to 3 devices.';
          } else {
            _errorMessage = '${e.message}\n\nYou can remove a device from Settings to add this one.';
          }
        });
        return;
      }
      
      if (e.toString().contains('canceled')) {
        // User canceled - don't show error, just reset loading state
        setState(() {
          _isLoading = false;
        });
        return;
      } else if (e.toString().contains('network') || 
                 e.toString().contains('connection') ||
                 e.toString().contains('unavailable')) {
        errorMsg = 'Service unavailable. Please try again later.';
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;


    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      Logger.info(
        'Starting sign-in process',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );

      // Step 1: Sign in with Firebase
      // This authenticates the user with Firebase and gets Firebase ID token
      await FirebaseAuthHelper.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // CRITICAL: Check email verification BEFORE allowing any backend access
      // Backend is the source of truth - user MUST verify email via link before accessing app
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed. Please try again.';
        });
        return;
      }
      
      // Reload user to get latest verification status
      await firebaseUser.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      
      if (refreshedUser == null || !refreshedUser.emailVerified) {
        // Email not verified - sign out and redirect to verification
        Logger.warning(
          'Sign-in blocked: Email not verified',
          feature: 'auth',
          screen: 'welcome_back_screen',
        );
        
        await FirebaseAuth.instance.signOut();
        
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please verify your email address before signing in. Check your inbox for the verification link.';
        });
        
        // Save email and navigate to verification screen
        ref.read(emailProvider.notifier).setEmail(email);
        
        // Wait a moment to show error message, then navigate
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/verify-email');
        }
        return;
      }
      
      Logger.info(
        'Firebase sign-in successful, email verified - creating backend session',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );
      
      // Step 2: Create backend session (only after email verification confirmed)
      // Backend expects: Authorization header with Firebase token, device_id in body
      // Endpoint: POST /api/v1/auth/session
      final sessionService = SessionService();
      try {
        await sessionService.createBackendSession();
        Logger.info(
          'Backend session created successfully',
          feature: 'auth',
          screen: 'welcome_back_screen',
        );
        
        // Step 3: Fetch user info and entitlements
        // Endpoint: GET /api/v1/auth/me
        // Returns: user data, plan, entitlements, limits
        try {
          Logger.info(
            'Fetching user info',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
          await sessionService.fetchUserInfo();
          Logger.info(
            'User info fetched successfully',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
        } catch (e) {
          Logger.warning(
            'Failed to fetch user info: $e',
            feature: 'auth',
            screen: 'welcome_back_screen',
          );
          // Continue anyway - session is created, user info can be fetched later
        }
      } catch (e, stackTrace) {
        Logger.error(
          'Backend session failed',
          feature: 'auth',
          screen: 'welcome_back_screen',
          error: e,
          stackTrace: stackTrace,
        );
        
        if (!mounted) return;
        
        // Check error type and provide specific messages
        final errorString = e.toString().toLowerCase();
        
        // Network/connection errors (request didn't reach backend)
        if (errorString.contains('network') || 
            errorString.contains('connection') ||
            errorString.contains('timeout') ||
            errorString.contains('unavailable') ||
            errorString.contains('connectionerror') ||
            errorString.contains('connection timeout') ||
            errorString.contains('send timeout') ||
            errorString.contains('receive timeout')) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Network error. Please check your internet connection and try again.';
          });
          
          // Scroll to show error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                600,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
          return;
        }
        
        // Backend server errors (500 - request reached backend but server error)
        if (errorString.contains('backend server error') ||
            errorString.contains('500') ||
            errorString.contains('internal server error')) {
          // Extract error message from exception (may contain backend details)
          String errorMsg = e.toString();
          // Clean up exception wrapper if present
          if (errorMsg.contains('Exception: ')) {
            errorMsg = errorMsg.split('Exception: ').last;
          }
          
          // If backend provided a specific error message, use it
          if (errorMsg.isNotEmpty && 
              !errorMsg.toLowerCase().contains('backend server error') &&
              errorMsg.length < 200) {
            // Use backend's error message if it's specific
            setState(() {
              _isLoading = false;
              _errorMessage = errorMsg;
            });
          } else {
            // Generic error message
            setState(() {
              _isLoading = false;
              _errorMessage = 'Server error. The backend is experiencing issues. Please try again in a moment.\n\nIf this persists, please contact support with error code: 500';
            });
          }
          
          Logger.error(
            'Backend 500 error during session creation',
            feature: 'auth',
            screen: 'welcome_back_screen',
            error: e,
            stackTrace: stackTrace,
            extra: {
              'error_type': 'backend_500',
              'error_message': errorMsg,
              'full_error': e.toString(),
              'message': 'Backend server error - request format was correct, backend failed internally',
            },
          );
          
          // Scroll to show error message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                600,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
          return;
        }
        
        // Device limit error
        if (errorString.contains('device_limit') || 
            errorString.contains('device limit')) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Device limit exceeded. Please remove a device from Settings.';
          });
          return;
        }
        
        // Authentication errors
        if (errorString.contains('401') ||
            errorString.contains('authentication failed') ||
            errorString.contains('unauthorized')) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Authentication failed. Please sign in again.';
          });
          return;
        }
        
        // Generic error - show the actual error message if available
        String errorMsg = 'Failed to connect to server. Please try again.';
        if (e is Exception) {
          final exceptionMsg = e.toString();
          if (exceptionMsg.isNotEmpty && !exceptionMsg.contains('Exception:')) {
            // Try to extract meaningful error message
            errorMsg = exceptionMsg;
          }
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
        
        // Scroll to show error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              600,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
        return;
      }
      
      // Step 4: Save email and navigate
      ref.read(emailProvider.notifier).setEmail(email);
      
      if (!mounted) return;
      
      Logger.info(
        'Sign-in successful, navigating to home',
        feature: 'auth',
        screen: 'welcome_back_screen',
      );
      
      // Navigate to home (user is signed in and session is created)
      context.go('/home');
    } on FirebaseAuthException catch (e) {
        // Handle Firebase auth errors
        if (!mounted) return;
        
        Logger.error(
          'Firebase sign-in error: ${e.code}',
          feature: 'auth',
          screen: 'welcome_back_screen',
          error: e,
        );
        
        ref.read(tempAuthProvider.notifier).clearPassword();
        
        String errorMsg = 'Sign in failed. Please try again.';
        
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            errorMsg = 'Invalid email or password. Please try again.';
            break;
          case 'too-many-requests':
            errorMsg = 'Too many attempts. Please try again later.';
            break;
          case 'user-disabled':
            errorMsg = 'This account has been disabled.';
            break;
          case 'operation-not-allowed':
            // This error occurs when email domain is not allowlisted in Firebase Console
            if (e.message?.toLowerCase().contains('allowlisted') == true ||
                e.message?.toLowerCase().contains('domain') == true) {
              errorMsg = 'This email domain is not allowed. Please contact support or use a different email address.';
            } else {
              errorMsg = e.message ?? 'This operation is not allowed. Please contact support.';
            }
            break;
          default:
            // Check if error message contains domain restriction keywords
            if (e.message?.toLowerCase().contains('allowlisted') == true ||
                e.message?.toLowerCase().contains('domain not') == true) {
              errorMsg = 'This email domain is not allowed. Please contact support or use a different email address.';
            } else {
              errorMsg = e.message ?? errorMsg;
            }
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
        
        // Scroll to show error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.animateTo(
              600,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
    } catch (e, stackTrace) {
      // Handle other errors
      if (!mounted) return;
      
      Logger.error(
        'Sign-in error: $e',
        feature: 'auth',
        screen: 'welcome_back_screen',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Clear stored password on error
      ref.read(tempAuthProvider.notifier).clearPassword();
      
      // Extract error message from exception
      String errorMsg = e.toString();
      
      // Try to extract a more user-friendly message
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.split('Exception: ').last;
      }
      
      // Provide default message if extraction failed
      if (errorMsg.isEmpty || errorMsg == e.toString()) {
        errorMsg = 'Failed to send verification code. Please try again.';
      }
      
      // Enhance error messages for specific cases
      if (errorMsg.toLowerCase().contains('network') || 
          errorMsg.toLowerCase().contains('connection') ||
          errorMsg.toLowerCase().contains('unavailable')) {
        errorMsg = 'Service unavailable. Free-tier server may be waking up (takes 30-90 seconds). Please wait and try again.';
      } else if (errorMsg.toLowerCase().contains('timeout')) {
        errorMsg = 'Request timed out. Free-tier servers take 30-90 seconds to wake up. Please wait a moment and try again.';
      } else if (errorMsg.toLowerCase().contains('500') || 
                 errorMsg.toLowerCase().contains('internal server error') ||
                 errorMsg.toLowerCase().contains('backend server error')) {
        errorMsg = 'Backend server error. Please try again later or contact support.';
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
      
      // Scroll to show error message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            600,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        screenWidth - 56; // Same width as email and password fields
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Pre-fill email from provider if available (only once)
    final savedEmail = ref.watch(emailProvider);
    if (savedEmail != null && 
        savedEmail.isNotEmpty && 
        !_emailPrefilled &&
        _emailController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _emailController.text.isEmpty) {
          _emailController.text = savedEmail;
          _emailPrefilled = true;
        }
      });
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsDark.backgroundLight : AppColors.backgroundLight,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Scrollable content for buttons
              SingleChildScrollView(
                controller: _scrollController, // Use controller for programmatic scrolling
                child: Padding(
                  padding: PlatformUtils.getDefaultPadding(context),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Mara logo
                      const Center(child: MaraLogo(width: 180, height: 130)),
                      SizedBox(
                        height: _errorMessage != null ? 900 : 800, // Extra space if error shown
                      ), // Space for positioned elements
                    ],
                  ),
                ),
              ),

              // Positioned Email field at x28, y365
              PositionedDirectional(
                start: 28,
                top: 365,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: l10n.emailLabel,
                    hint: l10n.enterYourEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => _validateEmail(value, context),
                  ),
                ),
              ),

              // Positioned Password field at x28, y427
              PositionedDirectional(
                start: 28,
                top: 427,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width -
                      56, // Full width minus left and right padding
                  child: MaraTextField(
                    label: l10n.passwordLabel,
                    hint: l10n.enterYourPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) => _validatePassword(value, context),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Positioned Verify button at x28, y511 (same width as email/password fields)
              PositionedDirectional(
                start: 28,
                top: 511,
                child: SizedBox(
                  width: buttonWidth,
                  child: _isLoading
                      ? const Center(child: SpinningMaraLogo(width: 40, height: 40))
                      : PrimaryButton(
                          text: l10n.verify,
                          width: buttonWidth,
                          height: 52,
                          borderRadius: 20,
                          onPressed: _handleVerify,
                        ),
                ),
              ),
              
              // Error message - positioned ABOVE social buttons and BELOW verify button
              if (_errorMessage != null)
                PositionedDirectional(
                  start: 28,
                  top: 570, // Positioned between verify button (511) and social buttons (576)
                  child: Container(
                    width: buttonWidth,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Positioned "Continue with Google" button at x28, y576 (same width as email/password fields)
              // Adjusted top position to account for error message
              PositionedDirectional(
                start: 28,
                top: _errorMessage != null ? 640 : 576, // Move down if error is shown
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: l10n.continueWithGoogle,
                    iconImagePath: 'assets/icons/Sign in/Social media logo.png',
                    backgroundColor:
                        isDark ? AppColorsDark.cardBackground : Colors.white,
                    textColor: isDark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    width: buttonWidth,
                    height: 52,
                    isDark: isDark,
                    onPressed: () {
                      // TODO: Implement Google sign-in
                    },
                  ),
                ),
              ),

              // Positioned "Continue with Apple" button at x28, y640 (same width as email/password fields)
              // Adjusted top position to account for error message
              PositionedDirectional(
                start: 28,
                top: _errorMessage != null ? 704 : 640, // Move down if error is shown (640 + 64 for error)
                child: SizedBox(
                  width: buttonWidth,
                  child: _SocialButton(
                    text: l10n.continueWithApple,
                    iconImagePath: 'assets/icons/Sign in/Wrapper.png',
                    backgroundColor:
                        isDark ? Colors.black : AppColors.appleButtonColor,
                    textColor: Colors.white,
                    width: buttonWidth,
                    height: 52,
                    isDark: isDark,
                    onPressed: _isLoading ? null : () {
                      _handleAppleSignIn();
                    },
                  ),
                ),
              ),

              // Positioned "Welcome back" title at x38, y285
              PositionedDirectional(
                start: 38,
                top: 285,
                child: Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 38,
                    fontWeight: FontWeight.w600, // SemiBold
                    height: 1,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),

              // Positioned "Happy to have you again" at x40, y331
              PositionedDirectional(
                start: 40,
                top: 331,
                child: Text(
                  l10n.welcomeBackSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),

              // Positioned "Forget your password? Click here" directly under password field, direction-aware alignment
              PositionedDirectional(
                start: 28,
                top: 427 +
                    56 +
                    5, // Password field top (427) + field height (~56) + margin (5px)
                child: SizedBox(
                  width: screenWidth -
                      56, // Same width as password field - full width
                  child: Align(
                    alignment: AlignmentDirectional
                        .centerStart, // Left in LTR, right in RTL
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: GestureDetector(
                        onTap: () {
                          context.push('/forgot-password-email');
                        },
                        child: RichText(
                          textAlign:
                              TextAlign.start, // Left in LTR, right in RTL
                          text: TextSpan(
                            style: TextStyle(
                              color: isDark
                                  ? AppColorsDark.textSecondary
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                              decoration: TextDecoration.underline,
                            ),
                            children: [
                              TextSpan(text: '${l10n.forgotPassword} '),
                              TextSpan(
                                text: l10n.clickHere,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned "Don't have an account? Click here" centered horizontally
              PositionedDirectional(
                start: 0,
                end: 0,
                top: 740,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/sign-up-choices');
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color:
                              isDark ? AppColorsDark.textPrimary : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(text: '${l10n.dontHaveAccount} '),
                          TextSpan(
                            text: l10n.signUp,
                            style: TextStyle(
                              color: AppColors.languageButtonColor, // #0EA5C6
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String? iconImagePath;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final bool isDark;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.text,
    this.iconImagePath,
    required this.backgroundColor,
    required this.textColor,
    required this.width,
    required this.height,
    this.isDark = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {},
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
          border: Border.all(
              color: isDark ? AppColorsDark.borderColor : AppColors.borderColor,
              width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconImagePath != null) ...[
              SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(
                  iconImagePath!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, final error, stackTrace) {
                    debugPrint('Error loading image: $iconImagePath - $error');
                    return Icon(Icons.image, color: textColor, size: 28);
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500, // Medium
                height: 1,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
