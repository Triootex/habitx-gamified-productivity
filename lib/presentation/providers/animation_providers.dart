import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/animation_integration.dart';

// Animation State Providers
final animationStateManagerProvider = ChangeNotifierProvider<AnimationStateManager>(
  (ref) => AnimationStateManager(),
);

final animationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(animationStateManagerProvider).animationsEnabled;
});

final animationSpeedProvider = Provider<double>((ref) {
  return ref.watch(animationStateManagerProvider).animationSpeed;
});

// Animation Timing Providers
final staggeredDelayProvider = Provider.family<List<Duration>, int>((ref, itemCount) {
  return AnimationUtils.generateStaggeredDelays(itemCount: itemCount);
});

final scaledDurationProvider = Provider.family<Duration, Duration>((ref, baseDuration) {
  final speed = ref.watch(animationSpeedProvider);
  return AnimationUtils.scaleDuration(baseDuration, speed);
});

// Screen Transition Providers
final screenTransitionProvider = StateProvider<ScreenTransition>((ref) {
  return ScreenTransition.slide;
});

// Animation Performance Providers
final animationFpsProvider = StateProvider<int>((ref) => 60);
final reduceAnimationsProvider = StateProvider<bool>((ref) => false);

// Animation Theme Providers
final animationThemeProvider = Provider<AnimationThemeData>((ref) {
  final speed = ref.watch(animationSpeedProvider);
  final enabled = ref.watch(animationsEnabledProvider);
  
  return AnimationThemeData(
    enabled: enabled,
    speed: speed,
    staggerDelay: const Duration(milliseconds: 50),
    defaultDuration: const Duration(milliseconds: 300),
  );
});

class AnimationThemeData {
  final bool enabled;
  final double speed;
  final Duration staggerDelay;
  final Duration defaultDuration;
  
  const AnimationThemeData({
    required this.enabled,
    required this.speed,
    required this.staggerDelay,
    required this.defaultDuration,
  });
}
