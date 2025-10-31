# TaskFlow Mobile App

A beautiful, feature-rich mobile task management application built with Flutter, providing seamless task management on Android and iOS with local notifications and AI-powered insights.

## Features

- 🔐 **Secure Authentication**: JWT-based login/signup with persistent storage
- 📋 **Complete Task Management**: Full CRUD operations with real-time API integration
- 🔔 **Local Notifications**: Smart deadline reminders (60, 30, 15, 10, 5, 2 minutes before + overdue)
- 🤖 **AI-Powered Insights**: Get personalized productivity recommendations using Google Gemini
- 🌙 **Dark Mode Toggle**: Seamless light/dark theme switching with persistent storage
- 📊 **Dashboard Analytics**: Task statistics with visual cards
- 🔍 **Advanced Filtering**: Filter by status (all/completed/pending)
- 📈 **Smart Sorting**: Sort by creation date, deadline, or title
- 🎨 **Material Design 3**: Modern UI with consistent color palette and theming
- 💾 **Persistent Storage**: Auto-save authentication tokens and user preferences
- 🚀 **Native Performance**: Flutter's compiled performance on both platforms
- 📱 **Splash Screen**: Beautiful branded app launch experience
- ⚡ **Provider State Management**: Efficient, reactive state management

## Screenshots

The app features:
- **Login/Signup Screens**: Clean, gradient-based authentication UI
- **Dashboard**: Task statistics, AI insights, and filtered task list
- **Task Form**: Create/edit tasks with deadline picker and status toggle
- **Dark Mode**: Beautiful dark theme throughout the app

## Tech Stack

- **Flutter 3.9+** - Cross-platform UI framework
- **Provider** - State management
- **HTTP** - REST API client
- **Shared Preferences** - Local storage
- **Material Design Icons** - Icon library
- **Flutter Local Notifications** - Deadline reminders
- **Timezone** - Precise notification scheduling
- **Material Design 3** - Modern UI components

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** 3.9 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

## Setup Instructions

### 1. Clone the Repository

```bash
cd "Zylentrix App/mobile"
```

### 2. Install Dependencies

Install all required Flutter packages:

```bash
flutter pub get
```

This will download and install all dependencies specified in `pubspec.yaml`.

### 3. Run the App

#### For Android:

```bash
# Connect an Android device via USB or start an emulator
flutter run
```

#### For iOS (macOS only):

```bash
# Connect an iOS device or start the simulator
flutter run
```

#### For a Specific Device:

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

### 4. Build Release APK (Android)

To build a production APK:

```bash
# Clean previous builds
flutter clean

# Reinstall dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 5. Build Release App Bundle (Android)

For Google Play Store distribution:

```bash
flutter build appbundle --release
```

The bundle will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

### 6. Build Release IPA (iOS)

For iOS App Store distribution (macOS only):

```bash
flutter build ipa --release
```

## Project Structure

```
mobile/
├── android/                    # Android platform code
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml  # Permissions & config
│   │           ├── res/
│   │           │   ├── xml/
│   │           │   │   └── network_security_config.xml  # Network settings
│   │           │   └── mipmap-*/  # App icons
│   │           └── kotlin/       # Kotlin entry point
│   └── build.gradle.kts        # Gradle config
├── ios/                        # iOS platform code
├── lib/
│   ├── config/
│   │   ├── api_config.dart      # Backend API endpoints
│   │   └── app_colors.dart      # Color palette & gradients
│   ├── models/
│   │   ├── task.dart            # Task data model
│   │   └── user.dart            # User data model
│   ├── providers/
│   │   ├── auth_provider.dart   # Authentication state
│   │   ├── task_provider.dart   # Task management state
│   │   └── theme_provider.dart  # Theme state
│   ├── screens/
│   │   ├── dashboard_screen.dart  # Main dashboard
│   │   ├── login_screen.dart     # Login screen
│   │   ├── signup_screen.dart    # Signup screen
│   │   └── task_form_screen.dart # Create/edit task
│   ├── services/
│   │   ├── api_service.dart           # HTTP API client
│   │   ├── notification_service.dart  # Local notifications
│   │   └── storage_service.dart       # Local storage
│   ├── utils/
│   │   └── permission_handler.dart    # Android permissions
│   ├── widgets/
│   │   ├── ai_insights.dart     # AI insights widget
│   │   ├── task_filters.dart    # Filter controls
│   │   ├── task_list.dart       # Task list display
│   │   └── task_stats.dart      # Statistics cards
│   └── main.dart                # App entry point
├── assets/
│   └── icon.png                 # App icon source
├── test/
│   └── widget_test.dart         # Unit & widget tests
├── pubspec.yaml                 # Dependencies & assets
└── README.md                    # This file
```

## Backend API Integration

The app connects to the Zylentrix backend API:

**Base URL**: `https://zylentrix-backend.onrender.com`

### Endpoints Used:

- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User authentication
- `GET /api/auth/me` - Get current user
- `GET /api/tasks` - Fetch all tasks
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update existing task
- `DELETE /api/tasks/:id` - Delete task

All endpoints require JWT authentication (except signup/login).

## Environment Variables

The app uses the following configurations:

- **API Base URL**: Configured in `lib/config/api_config.dart`
- **Gemini AI Key**: Configured in backend service (see backend docs)

## Local Notifications

The app schedules local notifications for task deadlines:

- **Intervals**: 60, 30, 15, 10, 5, 2 minutes before deadline
- **Overdue**: 1 minute after deadline
- **Time Zone**: Asia/Kolkata (IST)
- **Auto-Cancel**: On task completion or deletion
- **Permissions**: Requested automatically on first launch

## Android Permissions

Required permissions (configured in `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

Network security configuration allows HTTP connections to the backend API.

## Troubleshooting

### Issue: "Failed host lookup" error

**Solution**: Ensure network security config is properly set up:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Issue: Notifications not working

**Solution**: 
1. Check device notification permissions
2. Verify exact alarm permission (Android 12+)
3. Check logs for timezone initialization

### Issue: Build errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter doctor  # Check for configuration issues
```

### Issue: API connection fails in release

**Solution**: Network security configuration is already set up in `network_security_config.xml`. Rebuild the APK if needed.

## Testing

Run tests:

```bash
flutter test
```

## Deployment

### Android

1. Build release APK:
   ```bash
   flutter build apk --release
   ```

2. Upload to Google Play Console

### iOS (macOS only)

1. Build release IPA:
   ```bash
   flutter build ipa --release
   ```

2. Upload to App Store Connect

## Development Commands

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Clean build cache
flutter clean

# Check for issues
flutter doctor

# Analyze code
flutter analyze

# Format code
flutter format .

# Get outdated dependencies
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is part of the Zylentrix TaskFlow suite.

## Contact

For issues, questions, or contributions, please contact the development team.
