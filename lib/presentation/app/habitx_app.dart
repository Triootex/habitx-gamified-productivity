import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../providers/user_providers.dart';
import '../providers/permission_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/fully_animated_main_navigation.dart';
import '../widgets/permission_onboarding.dart';
import '../widgets/animation_integration.dart';
import '../../core/theme/app_theme.dart';

class HabitXApp extends ConsumerWidget {
  const HabitXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'HabitX - Gamified Productivity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(ref),
      home: const AppInitializer(),
    );
  }

  ThemeMode _getThemeMode(WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitialization = ref.watch(appInitializationProvider);
    
    return appInitialization.when(
      data: (initialized) {
        if (!initialized) {
          return const SplashScreen();
        }
        
        return const FullyAnimatedMainNavigation();
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => ErrorScreen(error: error),
    );
  }
}

class AppNavigator extends ConsumerWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowPermissionOnboarding = ref.watch(shouldShowPermissionOnboardingProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    // Show permission onboarding first if needed
    if (shouldShowPermissionOnboarding) {
      return PermissionOnboardingScreen(
        onComplete: () {
          // After onboarding, navigate based on auth state
          if (isAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      );
    }
    
    // Navigate based on authentication state
    if (isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class ErrorScreen extends StatelessWidget {
  final Object error;
  
  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HabitXApp()),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Theme Mode enum for app providers
enum AppThemeMode {
  light,
  dark,
  system,
}
