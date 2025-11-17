# Mara

**Mara** is an AI-powered health companion mobile app built with Flutter. It helps users track their health, get personalized insights, and interact with an intelligent health assistant.

## 🎯 Features

### Core Functionality
- **AI Health Assistant**: Chat with Mara to get instant, accurate medical insights powered by trusted health data
- **Personalized Insights**: Get health recommendations tailored to your daily patterns and goals
- **Health Tracking**: Monitor vital signs, mood, sleep, and hydration
- **Analytics Dashboard**: View detailed analytics about your health data
- **Multi-language Support**: Understands 100+ languages for natural conversation

### Key Screens

#### Onboarding & Setup
- **Splash Screen**: App introduction
- **Language Selector**: Choose preferred language (English/Arabic) with bold Roboto fonts
- **Welcome & Onboarding**: Introduction to Mara's features and privacy
- **User Profile Setup**: Collect name, DOB, gender, height, weight, blood type, and health goals
- **Permissions**: Request camera, microphone, notifications, and health data access
  - Camera permission with photo_camera.png icon
  - Microphone permission with mic.png icon
  - Notifications permission with notifications_active.png icon
  - Health data permission with monitor_heart.png icon

#### Authentication
- **Sign Up (Join Mara)**: Create account with email, Google, or Apple sign-in options
- **Enter Your Email**: Email and password sign-in with terms checkbox and Login link
- **Verify Email**: 6-digit code verification screen
- **Welcome Back**: Returning user experience with email/password fields and social sign-in

#### Main App
- **Home Screen**: 
  - Daily insights (mood, sleep, water intake)
  - Vital signs card (clickable with loading state - grey background and hourglass icon)
  - Summary card (clickable with loading state - grey background and hourglass icon)
  - Chat with Mara button
- **Mara Chat**: Interactive chat interface with the AI health assistant
- **Analytics Dashboard**: Health data visualization and insights
- **Profile**: 
  - User name and email display with Edit button
  - Back arrow navigation
  - Health Profile, Settings, Privacy Policy (opens in WebView), Terms of Service, and Logout options
- **Settings**: 
  - Language preferences (English/Arabic)
  - Notification toggles (Health reminders, Email notifications)
  - Privacy Policy (opens in external browser)
  - Terms of Service (opens in in-app WebView)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod (flutter_riverpod, hooks_riverpod)
- **Navigation**: GoRouter
- **UI Components**: Material Design
- **Assets**: SVG and PNG support
- **Internationalization**: intl package
- **External Links**: url_launcher
- **WebView**: webview_flutter (for in-app privacy policy and terms viewing)
- **Typography**: Roboto font family applied globally throughout the entire app

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/              # Data models (permissions, chat messages, user profile)
│   ├── providers/           # Riverpod providers (settings, permissions, language, user profile)
│   ├── routing/             # App routing configuration
│   ├── theme/               # App colors, text styles, theme (Roboto font configured globally)
│   ├── utils/               # Platform utilities
│   └── widgets/             # Reusable widgets (buttons, text fields, logo)
├── features/
│   ├── analytics/           # Analytics dashboard
│   ├── auth/                # Authentication screens
│   ├── chat/                # Mara chat interface
│   ├── home/                # Home screen
│   ├── onboarding/          # Onboarding flow
│   ├── permissions/         # Permission request screens
│   ├── profile/             # User profile
│   ├── settings/            # Settings screens
│   ├── setup/               # User profile setup flow
│   └── splash/              # Splash screen
└── main.dart                # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- iOS Simulator / Android Emulator or physical device
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mara-org/mara-app.git
   cd mara-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🎨 Design

- **App Name**: Mara
- **Primary Color**: #0EA5C6 (Teal/Cyan)
- **Font**: Roboto (applied globally to every single word in the app via theme configuration)
- **Design System**: Custom theme with consistent colors and typography
- **UI Elements**: Consistent use of rounded corners (16-20px radius), shadows, and spacing

### Design Details

#### Permission Screens
- All permission screens use custom icons with color filters
- Consistent button positioning and spacing across all permission screens
- SemiBold font weight for all headlines
- Centered images with consistent styling

#### Setup Screens
- Height and Weight screens with unit selectors (cm/in, kg/lb)
- Continuous blue line under unit selectors
- Custom picker styling with selected/unselected states
- Blood type and goals screens with updated button styling

## 📱 App Icons

App icons are located in the `AppIcon/` folder. Icons are configured for both Android and iOS platforms with all required sizes.

### Updating App Icons

1. Place your icon files in the `AppIcon/` folder
2. For Android: Icons should be copied to `android/app/src/main/res/mipmap-*/ic_launcher.png`
3. For iOS: Icons should be placed in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🔐 Permissions

The app requests the following permissions:

- **Camera**: For facial expression analysis and fatigue detection (processed locally)
- **Microphone**: For voice input and natural conversation
- **Notifications**: For health reminders and daily goals
- **Health Data**: For activity, sleep, and heart rate tracking

All data processing happens locally on the device for maximum privacy.

## 🌐 Navigation

The app uses GoRouter for navigation. Key routes include:

- `/splash` - Initial splash screen
- `/language-selector` - Language selection screen
- `/sign-up-choices` - Sign up options (Google, Apple, Email)
- `/sign-in-email` - Email and password sign in
- `/verify-email` - Email verification screen
- `/welcome-back` - Welcome back screen for returning users
- `/home` - Main home screen
- `/chat` - Mara chat interface
- `/analytics` - Analytics dashboard
- `/profile` - User profile
- `/settings` - App settings
- `/privacy-webview` - In-app privacy policy WebView
- `/onboarding-*` - Onboarding flow screens
- `/permissions-*` - Permission request screens

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📝 Version

- **Current Version**: 1.0.0+1

## 📄 License

This project is part of the Mara organization.

## 🤝 Contributing

Contributions are welcome! Please follow the existing code style and create pull requests for any improvements.

## 📞 Support

For support, please contact the Mara team or open an issue in the repository.

---

**Mara** - Your AI-powered health companion 🌱
