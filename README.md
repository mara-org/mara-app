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
- **Language Selector**: Choose preferred language
- **Welcome & Onboarding**: Introduction to Mara's features and privacy
- **User Profile Setup**: Collect name, DOB, gender, height, weight, blood type, and health goals
- **Permissions**: Request camera, microphone, notifications, and health data access

#### Authentication
- **Sign Up**: Create account with email, Google, or Apple
- **Sign In**: Login with email and password
- **Welcome Back**: Returning user experience

#### Main App
- **Home Screen**: Daily insights, mood, sleep, water intake, vital signs summary
- **Mara Chat**: Interactive chat interface with the AI health assistant
- **Analytics Dashboard**: Health data visualization and insights
- **Profile**: User profile information and settings access
- **Settings**: Manage preferences, permissions, privacy policy, and terms of service

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod (flutter_riverpod, hooks_riverpod)
- **Navigation**: GoRouter
- **UI Components**: Material Design
- **Assets**: SVG and PNG support
- **Internationalization**: intl package
- **External Links**: url_launcher

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/              # Data models (permissions, chat messages, user profile)
│   ├── providers/           # Riverpod providers (settings, permissions, language, user profile)
│   ├── routing/             # App routing configuration
│   ├── theme/               # App colors, text styles, theme
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
- **Font**: Roboto
- **Design System**: Custom theme with consistent colors and typography

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
- `/home` - Main home screen
- `/chat` - Mara chat interface
- `/profile` - User profile
- `/settings` - App settings
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
