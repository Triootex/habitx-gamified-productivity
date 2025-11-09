# HabitX - Gamified Productivity RPG App

A comprehensive Flutter application that transforms habit tracking and productivity into an engaging RPG-style experience. Build better habits, track your progress, and level up your life!

## 🎮 Features

### Core Functionality
- **Habit Tracking**: Track daily habits with customizable goals and reminders
- **Gamification**: Earn XP, level up, and unlock achievements
- **Mood Tracking**: Monitor your emotional well-being with interactive mood sliders
- **Productivity Tools**: Pomodoro timer, task management, and focus sessions

### Health & Wellness
- **Fitness Tracking**: Exercise logging and fitness goal management
- **Sleep Monitoring**: Track sleep patterns and quality
- **Water Intake**: Daily water consumption tracking
- **Meditation**: Guided meditation sessions with progress tracking

### Learning & Development
- **Skill Development**: Track learning progress and skill acquisition
- **Language Learning**: Vocabulary building and practice tracking
- **Reading Goals**: Book tracking and reading habit formation
- **Creative Projects**: Monitor progress on creative endeavors

### Social Features
- **Community Challenges**: Participate in group challenges
- **Leaderboards**: Compete with friends and community members
- **Achievement Sharing**: Share milestones and progress
- **Social Accountability**: Connect with accountability partners

## 🎯 Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter
- **Material Design**: Google's design system for beautiful UIs

### Animations & Visuals
- **Lottie**: High-quality animations for engaging user experience
- **Rive**: Interactive animations and real-time graphics
- **Flutter Animate**: Smooth animation transitions

### State Management
- **Riverpod**: Modern state management solution for Flutter
- **GetIt**: Dependency injection container

### Backend & Data
- **Firebase**: Comprehensive backend services
  - **Firebase Auth**: User authentication
  - **Cloud Firestore**: NoSQL database
  - **Firebase Storage**: File storage
  - **Firebase Analytics**: User analytics
  - **Firebase Crashlytics**: Crash reporting
  - **Firebase Remote Config**: Feature flags and configuration

### Local Storage
- **Hive**: Lightweight key-value database
- **Shared Preferences**: Simple data persistence
- **SQLite**: Relational database for complex data

### External Services
- **Google Sign-In**: Social authentication
- **Google Mobile Ads**: Monetization
- **Health**: Health data integration
- **In-App Purchases**: Premium features

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.19.0)
- Dart SDK (>=3.9.2)
- Android Studio / Xcode (for mobile development)
- Firebase account for backend services

### Installation
1. Clone the repository
```bash
git clone https://github.com/Triootex/habitx-gamified-productivity.git
cd habitx-gamified-productivity
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add your Android and iOS apps
- Download configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)
- Place them in the appropriate directories

4. Run the app
```bash
flutter run
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 Assets & Resources

The app includes a rich set of assets:
- **Icons**: 30+ custom icons for different habit categories
- **Images**: Background images and mascot characters
- **Animations**: Lottie and Rive animations for engaging interactions
- **Sounds**: Audio feedback for user actions
- **Fonts**: Custom typography (Poppins, Inter, Roboto)

## 🏗️ Architecture

The project follows clean architecture principles:

```
lib/
├── core/           # Core functionality (theme, constants, utils)
├── data/           # Data layer (repositories, services)
├── domain/         # Business logic (entities, use cases)
└── presentation/   # UI layer (screens, widgets, providers)
```

## 🧪 Testing

The project includes comprehensive testing:
- **Unit Tests**: Business logic testing
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end testing

## 📈 Analytics & Monitoring

- **Firebase Analytics**: User behavior tracking
- **Firebase Crashlytics**: Crash reporting and analysis
- **Performance Monitoring**: App performance metrics

## 🔒 Security

- **Data Encryption**: Sensitive data protection
- **Secure Authentication**: Multiple authentication methods
- **Privacy-First**: User data protection compliance

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for comprehensive backend services
- The open-source community for various packages and tools

---

**Built with ❤️ using Flutter**
