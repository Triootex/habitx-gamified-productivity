import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../providers/user_providers.dart';
import '../providers/permission_providers.dart';
import '../providers/animation_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/comprehensive_main_navigation.dart';
import '../screens/comprehensive_features_screen.dart';
import '../widgets/permission_onboarding.dart';
import '../widgets/animation_integration.dart';
import '../../core/theme/app_theme.dart';
import '../../core/animations/animation_assets.dart';

class FullyAnimatedHabitXApp extends ConsumerWidget {
  const FullyAnimatedHabitXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationTheme = ref.watch(animationThemeProvider);
    
    return MaterialApp(
      title: 'HabitX - Gamified Productivity with Full Animations',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        // Add animation theme extensions
        extensions: [
          animationTheme,
        ],
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        extensions: [
          animationTheme,
        ],
      ),
      home: const AnimatedAppRoot(),
      // Add custom page transitions for ALL navigation
      onGenerateRoute: (settings) {
        return _createAnimatedRoute(settings);
      },
    );
  }

  PageRoute _createAnimatedRoute(RouteSettings settings) {
    Widget page;
    ScreenTransition transition = ScreenTransition.slide;
    AxisDirection direction = AxisDirection.right;

    // Route-specific animations based on destination
    switch (settings.name) {
      case '/features':
        page = const ComprehensiveFeaturesScreen();
        transition = ScreenTransition.fade;
        break;
      case '/main':
        page = const FullyAnimatedMainNavigation();
        transition = ScreenTransition.scale;
        break;
      case '/login':
        page = const LoginScreen();
        transition = ScreenTransition.slide;
        direction = AxisDirection.up;
        break;
      default:
        page = const AnimatedAppRoot();
        transition = ScreenTransition.fade;
    }

    // Create animated route based on transition type
    switch (transition) {
      case ScreenTransition.slide:
        return SlidePageRoute(child: page, direction: direction);
      case ScreenTransition.fade:
        return FadePageRoute(child: page);
      case ScreenTransition.scale:
        return ScalePageRoute(child: page);
      case ScreenTransition.rotation:
        return RotationPageRoute(child: page);
      case ScreenTransition.size:
        return SizePageRoute(child: page);
    }
  }
}

class AnimatedAppRoot extends ConsumerStatefulWidget {
  const AnimatedAppRoot({Key? key}) : super(key: key);

  @override
  ConsumerState<AnimatedAppRoot> createState() => _AnimatedAppRootState();
}

class _AnimatedAppRootState extends ConsumerState<AnimatedAppRoot> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final appInitialization = ref.watch(appInitializationProvider);
        final user = ref.watch(currentUserProvider);
        final permissionsGranted = ref.watch(allPermissionsGrantedProvider);

        return appInitialization.when(
          data: (initialized) {
            if (!initialized) {
              return _buildAnimatedSplashScreen();
            }

            if (user == null) {
              return _buildAnimatedLoginFlow();
            }

            if (!permissionsGranted) {
              return _buildAnimatedPermissionOnboarding();
            }

            return _buildMainApp();
          },
          loading: () => _buildAnimatedSplashScreen(),
          error: (error, stackTrace) => _buildAnimatedErrorScreen(error),
        );
      },
    );
  }

  Widget _buildAnimatedSplashScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main logo with complex animation (Real MCP)
              AnimatedWidget(
                assetPath: AnimationAssets.rocket, // Real MCP Animation
                width: 120,
                height: 120,
              )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 1000.ms,
                  curve: Curves.elasticOut,
                )
                .rotate(duration: 2000.ms)
                .then()
                .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),

              const SizedBox(height: 40),

              // App name with staggered letters
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: 'HabitX'.split('').asMap().entries.map((entry) {
                  return Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                    .animate(delay: Duration(milliseconds: 100 * entry.key))
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.5, duration: 800.ms)
                    .then()
                    .shake(duration: 200.ms);
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Subtitle with typewriter effect
              const Text(
                'Gamified Productivity & Wellness',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              )
                .animate()
                .fadeIn(delay: 1500.ms, duration: 1000.ms)
                .slideX(begin: -0.3, duration: 1000.ms),

              const SizedBox(height: 60),

              // Loading animation (Real MCP)
              AnimatedWidget(
                assetPath: AnimationAssets.loadingSpinner, // Real MCP Animation
                width: 60,
                height: 60,
              )
                .animate(delay: 2000.ms)
                .fadeIn(duration: 500.ms)
                .scale(duration: 500.ms),

              const SizedBox(height: 20),

              // Loading text
              const Text(
                'Preparing your experience...',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              )
                .animate(delay: 2500.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoginFlow() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.9),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Welcome animation (Real MCP)
                        AnimatedWidget(
                          assetPath: AnimationAssets.successCelebration, // Real MCP Animation
                          width: 100,
                          height: 100,
                        )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 1000.ms, curve: Curves.bounceOut)
                          .then()
                          .shake(duration: 500.ms),

                        const SizedBox(height: 40),

                        // Welcome text
                        Text(
                          'Welcome to HabitX',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(begin: -0.3, duration: 800.ms),

                        const SizedBox(height: 16),

                        Text(
                          'Transform your life with gamified productivity and wellness tracking',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 800.ms)
                          .slideY(begin: 0.3, duration: 800.ms),

                        const SizedBox(height: 60),

                        // Feature highlights with icons (All Real MCP)
                        _buildFeatureHighlight('Track Habits', AnimationAssets.successCelebration, 1000.ms),
                        _buildFeatureHighlight('Boost Productivity', AnimationAssets.workingHours, 1200.ms),
                        _buildFeatureHighlight('Enhance Wellness', AnimationAssets.meditation, 1400.ms),
                        _buildFeatureHighlight('Achieve Goals', AnimationAssets.successCelebration, 1600.ms),

                        const SizedBox(height: 60),

                        // Login button
                        AnimatedButton(
                          onPressed: _navigateToLogin,
                          backgroundColor: Colors.white,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedWidget(
                                  assetPath: AnimationAssets.rocket, // Real MCP Animation
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                          .animate()
                          .fadeIn(delay: 1800.ms, duration: 800.ms)
                          .slideY(begin: 0.5, duration: 800.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                      ],
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

  Widget _buildFeatureHighlight(String title, String animationAsset, Duration delay) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedWidget(
            assetPath: animationAsset,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
      .animate()
      .fadeIn(delay: delay, duration: 600.ms)
      .slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildAnimatedPermissionOnboarding() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withOpacity(0.9),
              Colors.red.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Permission icon with pulse animation (Real MCP)
                        AnimatedWidget(
                          assetPath: AnimationAssets.rocket, // Real MCP Animation
                          width: 120,
                          height: 120,
                        )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 1000.ms)
                          .then()
                          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3))
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.1, 1.1),
                            duration: 1500.ms,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1.0, 1.0),
                            duration: 1500.ms,
                          ),

                        const SizedBox(height: 40),

                        // Permission title
                        Text(
                          'Unlock Full Experience',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 800.ms)
                          .slideY(begin: -0.3, duration: 800.ms),

                        const SizedBox(height: 16),

                        Text(
                          'Grant permissions to enable all features and get the most out of HabitX',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 800.ms)
                          .slideY(begin: 0.3, duration: 800.ms),

                        const SizedBox(height: 60),

                        // Grant permissions button
                        AnimatedButton(
                          onPressed: _requestAllPermissions,
                          backgroundColor: Colors.white,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedWidget(
                                  assetPath: AnimationAssets.successCelebration, // Real MCP Animation
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Grant Permissions',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                          .animate()
                          .fadeIn(delay: 1200.ms, duration: 800.ms)
                          .slideY(begin: 0.5, duration: 800.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          ),
                      ],
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

  Widget _buildMainApp() {
    return const ComprehensiveMainNavigation()
      .animate()
      .fadeIn(duration: 1000.ms)
      .scale(
        begin: const Offset(0.9, 0.9),
        duration: 1000.ms,
        curve: Curves.easeOutBack,
      );
  }

  Widget _buildAnimatedErrorScreen(Object error) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedWidget(
                assetPath: AnimationAssets.loadingSpinner, // Real MCP Animation
                width: 100,
                height: 100,
              )
                .animate()
                .fadeIn(duration: 800.ms)
                .shake(duration: 1000.ms),

              const SizedBox(height: 40),

              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .slideY(begin: 0.3, duration: 800.ms),

              const SizedBox(height: 16),

              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              )
                .animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .slideY(begin: 0.3, duration: 800.ms),

              const SizedBox(height: 40),

              AnimatedButton(
                onPressed: _retryInitialization,
                backgroundColor: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
                .animate()
                .fadeIn(delay: 1200.ms, duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _requestAllPermissions() {
    // Implement permission requests with animated feedback
    AnimatedSnackbar.showInfo(
      context: context,
      message: 'Requesting permissions...',
    );
  }

  void _retryInitialization() {
    // Retry app initialization
    ref.refresh(appInitializationProvider);
  }
}
