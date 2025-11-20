import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Mara'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mara 👋'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered health companion is here to help you on your wellness journey.'**
  String get welcomeSubtitle;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @onboardingInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get instant, accurate medical insights'**
  String get onboardingInsightsTitle;

  /// No description provided for @onboardingInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by advanced AI trained on trusted health data from Mayo Clinic, WHO, and more.'**
  String get onboardingInsightsSubtitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays private'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Mara understands 100+ languages'**
  String get privacySubtitle1;

  /// No description provided for @privacySubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Speak freely in your own language — Mara listens and keeps your health data 100% private.'**
  String get privacySubtitle2;

  /// No description provided for @personalizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized health insights, made just for you'**
  String get personalizedTitle;

  /// No description provided for @personalizedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mara learns from your daily patterns to help you stay healthy, motivated, and consistent.'**
  String get personalizedSubtitle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @joinMara.
  ///
  /// In en, this message translates to:
  /// **'Join Mara'**
  String get joinMara;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a verification code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your email. Please enter it below to reset your password.'**
  String get forgotPasswordVerifySubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Enter the code below'**
  String get verifyEmailSubtitle2;

  /// No description provided for @verifyEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get verifyEmailError;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your health journey'**
  String get welcomeBackSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms'**
  String get agreeToTerms;

  /// No description provided for @termsCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms'**
  String get termsCheckbox;

  /// No description provided for @whatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get whatsYourName;

  /// No description provided for @nameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use it to personalize your experience.'**
  String get nameSubtitle;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @whenWereYouBorn.
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get whenWereYouBorn;

  /// No description provided for @tellUsYourGender.
  ///
  /// In en, this message translates to:
  /// **'Tell us your gender?'**
  String get tellUsYourGender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male 👨'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female 👩'**
  String get female;

  /// No description provided for @whatsYourHeight.
  ///
  /// In en, this message translates to:
  /// **'What\'s your height?'**
  String get whatsYourHeight;

  /// No description provided for @whatsYourWeight.
  ///
  /// In en, this message translates to:
  /// **'What\'s your weight?'**
  String get whatsYourWeight;

  /// No description provided for @whatsYourBloodType.
  ///
  /// In en, this message translates to:
  /// **'What\'s your blood type?'**
  String get whatsYourBloodType;

  /// No description provided for @whatsYourMainGoal.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main health goal?'**
  String get whatsYourMainGoal;

  /// No description provided for @stayActive.
  ///
  /// In en, this message translates to:
  /// **'🏃‍♂️ Stay active'**
  String get stayActive;

  /// No description provided for @reduceStress.
  ///
  /// In en, this message translates to:
  /// **'😌 Reduce stress'**
  String get reduceStress;

  /// No description provided for @sleepBetter.
  ///
  /// In en, this message translates to:
  /// **'💤 Sleep better'**
  String get sleepBetter;

  /// No description provided for @trackMyHealth.
  ///
  /// In en, this message translates to:
  /// **'❤️ Track my health'**
  String get trackMyHealth;

  /// No description provided for @pleaseSelectValidDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid date'**
  String get pleaseSelectValidDate;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @healthProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Profile'**
  String get healthProfileTitle;

  /// No description provided for @nameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameField;

  /// No description provided for @dateOfBirthField.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthField;

  /// No description provided for @genderField.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderField;

  /// No description provided for @heightField.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightField;

  /// No description provided for @weightField.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightField;

  /// No description provided for @bloodTypeField.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodTypeField;

  /// No description provided for @mainGoalField.
  ///
  /// In en, this message translates to:
  /// **'Main Goal'**
  String get mainGoalField;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @healthReminders.
  ///
  /// In en, this message translates to:
  /// **'Health reminders'**
  String get healthReminders;

  /// No description provided for @healthRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration, medication, and daily goals reminders.'**
  String get healthRemindersSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive important updates and reports by email.'**
  String get emailNotificationsSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @couldNotOpenTerms.
  ///
  /// In en, this message translates to:
  /// **'Could not open Terms of Service'**
  String get couldNotOpenTerms;

  /// No description provided for @couldNotOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Could not open Privacy Policy'**
  String get couldNotOpenPrivacy;

  /// No description provided for @developerSettings.
  ///
  /// In en, this message translates to:
  /// **'Developer Settings'**
  String get developerSettings;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get deviceInfo;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mara to access your camera'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mara uses your camera to analyze facial expressions and detect fatigue — all processed locally on your device.'**
  String get cameraPermissionSubtitle;

  /// No description provided for @cameraPermissionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters. Camera access stays local to your device.'**
  String get cameraPermissionPrivacy;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @microphonePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mara to access your microphone'**
  String get microphonePermissionTitle;

  /// No description provided for @microphonePermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mara uses your microphone to understand your voice and provide natural conversation — all processed locally on your device.'**
  String get microphonePermissionSubtitle;

  /// No description provided for @microphonePermissionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters. Your voice access stays local in your device.'**
  String get microphonePermissionPrivacy;

  /// No description provided for @notificationsPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mara to send you notifications'**
  String get notificationsPermissionTitle;

  /// No description provided for @notificationsPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get timely reminders for hydration, medication, and daily health goals.'**
  String get notificationsPermissionSubtitle;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// No description provided for @healthDataPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your health data'**
  String get healthDataPermissionTitle;

  /// No description provided for @healthDataPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mara can track your activity, sleep, and heart rate to provide personalized insights.'**
  String get healthDataPermissionSubtitle;

  /// No description provided for @healthDataPermissionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Stay connected to your health — the smart way.'**
  String get healthDataPermissionPrivacy;

  /// No description provided for @connectHealthData.
  ///
  /// In en, this message translates to:
  /// **'Connect Health Data'**
  String get connectHealthData;

  /// No description provided for @permissionsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions Summary'**
  String get permissionsSummaryTitle;

  /// No description provided for @permissionsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what Mara can access to personalize your experience'**
  String get permissionsSummarySubtitle;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// No description provided for @upgradeYourMaraAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your Mara account'**
  String get upgradeYourMaraAccount;

  /// No description provided for @upgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock premium insights, more reminders, and priority support.'**
  String get upgradeSubtitle;

  /// No description provided for @maraPro.
  ///
  /// In en, this message translates to:
  /// **'Mara Pro'**
  String get maraPro;

  /// No description provided for @maraProSubscription.
  ///
  /// In en, this message translates to:
  /// **'Mara Pro subscription'**
  String get maraProSubscription;

  /// No description provided for @highQualitySummaries.
  ///
  /// In en, this message translates to:
  /// **'High-quality health summaries.'**
  String get highQualitySummaries;

  /// No description provided for @deeperAIInsights.
  ///
  /// In en, this message translates to:
  /// **'Deeper AI insights and trends.'**
  String get deeperAIInsights;

  /// No description provided for @moreReminders.
  ///
  /// In en, this message translates to:
  /// **'More reminders and customization.'**
  String get moreReminders;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @subscribeWithAppleGoogle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe with Apple / Google'**
  String get subscribeWithAppleGoogle;

  /// No description provided for @byContinuingAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to Mara\'s {terms} and {privacy}.'**
  String byContinuingAgree(String terms, String privacy);

  /// No description provided for @termsOfServiceLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceLink;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLink;

  /// No description provided for @youAreOnMaraPro.
  ///
  /// In en, this message translates to:
  /// **'You are on Mara Pro'**
  String get youAreOnMaraPro;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to start?'**
  String get readyTitle;

  /// No description provided for @readySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your profile'**
  String get readySubtitle;

  /// No description provided for @areYouReady.
  ///
  /// In en, this message translates to:
  /// **'Are you ready?'**
  String get areYouReady;

  /// No description provided for @readySubtitleText.
  ///
  /// In en, this message translates to:
  /// **'To start your journey you need to answer few question'**
  String get readySubtitleText;

  /// No description provided for @readyButton.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get readyButton;

  /// No description provided for @joinMaraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your free account to start your health journey.'**
  String get joinMaraSubtitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @signUpWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get signUpWithEmail;

  /// No description provided for @alreadyAMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyAMember;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @passwordDoesNotMeetRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet all requirements'**
  String get passwordDoesNotMeetRequirements;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @atLeastOneUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter'**
  String get atLeastOneUppercase;

  /// No description provided for @atLeastOneLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter'**
  String get atLeastOneLowercase;

  /// No description provided for @atLeastOneNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get atLeastOneNumber;

  /// No description provided for @atLeastOneSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'At least one special character'**
  String get atLeastOneSpecialChar;

  /// No description provided for @between8And4096Chars.
  ///
  /// In en, this message translates to:
  /// **'Between 8 and 4096 characters'**
  String get between8And4096Chars;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeToThe;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get terms;

  /// No description provided for @clickHere.
  ///
  /// In en, this message translates to:
  /// **'Click here'**
  String get clickHere;

  /// No description provided for @verifyEmailSubtitleFull.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to your email. Please enter it below'**
  String get verifyEmailSubtitleFull;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get pricePerMonth;

  /// No description provided for @pricePerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get pricePerYear;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @inchUnit.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inchUnit;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get kg;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @continueButtonText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButtonText;

  /// No description provided for @whatsYourMainHealthGoal.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main health goal?'**
  String get whatsYourMainHealthGoal;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @there.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get there;

  /// No description provided for @whatHappenedToYourCough.
  ///
  /// In en, this message translates to:
  /// **'What happened to your cough?'**
  String get whatHappenedToYourCough;

  /// No description provided for @completeYourLastConversation.
  ///
  /// In en, this message translates to:
  /// **'complete your last conversation'**
  String get completeYourLastConversation;

  /// No description provided for @yourDailyInsights.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Insights'**
  String get yourDailyInsights;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @vitalSigns.
  ///
  /// In en, this message translates to:
  /// **'Vital signs'**
  String get vitalSigns;

  /// No description provided for @trackYourVariabilityAndRestingHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Track your variability and resting heart rate'**
  String get trackYourVariabilityAndRestingHeartRate;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @chatWithMara.
  ///
  /// In en, this message translates to:
  /// **'Chat with Mara'**
  String get chatWithMara;

  /// No description provided for @drinkGlassOfWaterEveryMorning.
  ///
  /// In en, this message translates to:
  /// **'Drink a glass of water every morning to boost your metabolism.'**
  String get drinkGlassOfWaterEveryMorning;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @analyst.
  ///
  /// In en, this message translates to:
  /// **'Analyst'**
  String get analyst;

  /// No description provided for @mara.
  ///
  /// In en, this message translates to:
  /// **'Mara'**
  String get mara;

  /// No description provided for @allowCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Camera Access'**
  String get allowCameraAccess;

  /// No description provided for @cameraAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Mara uses your camera to help analyze your facial expressions, detect fatigue, and support your well-being — directly on your device. No videos or images are stored or shared. Ever.'**
  String get cameraAccessDescription;

  /// No description provided for @allowMicrophoneAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow Microphone Access'**
  String get allowMicrophoneAccess;

  /// No description provided for @microphoneAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Mara listens when you talk — so you can describe your symptoms naturally, just like talking to a friend. Your voice is processed safely on your device and never stored or shared.'**
  String get microphoneAccessDescription;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your health routine with gentle reminders for hydration, medications, and daily goals. You control what to receive and when — always.'**
  String get notificationsDescription;

  /// No description provided for @healthDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Mara can read your activity, sleep, and heart rate from your device to give you personalized health insights. Your data stays encrypted and private used only to help you understand your well-being better.'**
  String get healthDataDescription;

  /// No description provided for @stayConnectedToYourHealth.
  ///
  /// In en, this message translates to:
  /// **'Stay connected to your health — the smart way.'**
  String get stayConnectedToYourHealth;

  /// No description provided for @reviewPermissions.
  ///
  /// In en, this message translates to:
  /// **'Review Permissions'**
  String get reviewPermissions;

  /// No description provided for @startUsingMara.
  ///
  /// In en, this message translates to:
  /// **'Start using Mara'**
  String get startUsingMara;

  /// No description provided for @yourPrivacyIsAlwaysOurTopPriority.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is always our top priority.'**
  String get yourPrivacyIsAlwaysOurTopPriority;

  /// No description provided for @maraChat.
  ///
  /// In en, this message translates to:
  /// **'Mara Chat'**
  String get maraChat;

  /// No description provided for @whatsInYourHead.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your head?'**
  String get whatsInYourHead;

  /// No description provided for @thanksForSharing.
  ///
  /// In en, this message translates to:
  /// **'Thanks for sharing, I\'ll help you track this.'**
  String get thanksForSharing;

  /// No description provided for @analystDashboard.
  ///
  /// In en, this message translates to:
  /// **'Analyst Dashboard'**
  String get analystDashboard;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @detailedAnalyticsAboutYourHealth.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics about your health will be available here soon.'**
  String get detailedAnalyticsAboutYourHealth;

  /// No description provided for @allowCameraAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Camera Access'**
  String get allowCameraAccessTitle;

  /// No description provided for @allowMicrophoneAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Microphone Access'**
  String get allowMicrophoneAccessTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Welcome message with user's name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 👋'**
  String welcomePersonalTitle(String name);

  /// No description provided for @welcomePersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your health preferences to personalize your experience'**
  String get welcomePersonalSubtitle;

  /// No description provided for @startSetup.
  ///
  /// In en, this message translates to:
  /// **'Start Setup'**
  String get startSetup;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
