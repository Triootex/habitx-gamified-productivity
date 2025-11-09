// ANIMATION INTEGRATION HUB
// This file ensures all animations are properly integrated across the app

export 'universal_animated_widgets.dart';
export 'page_transitions.dart';
export 'animated_widgets.dart';
export '../core/animations/animation_assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'universal_animated_widgets.dart';
import 'page_transitions.dart';

// Global Animation Mixins
mixin AnimatedScreenMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin {
  late List<AnimationController> animationControllers;
  
  @override
  void initState() {
    super.initState();
    initAnimationControllers();
    startEntryAnimations();
  }
  
  void initAnimationControllers() {
    animationControllers = [];
  }
  
  void startEntryAnimations() {
    // Override in implementing classes
  }
  
  @override
  void dispose() {
    for (var controller in animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  AnimationController createAnimationController({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final controller = AnimationController(duration: duration, vsync: this);
    animationControllers.add(controller);
    return controller;
  }
}

// Animated Widget Extensions
extension AnimatedWidgetExtensions on Widget {
  Widget withStaggeredAnimation({Duration delay = Duration.zero}) {
    return animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, duration: 400.ms);
  }
  
  Widget withScaleAnimation({Duration delay = Duration.zero}) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), duration: 300.ms);
  }
  
  Widget withSlideAnimation({
    Duration delay = Duration.zero,
    double begin = 0.3,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: begin, duration: 300.ms);
  }
  
  Widget withBounceAnimation({Duration delay = Duration.zero}) {
    return animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.1, 1.1),
          duration: 200.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1.0, 1.0),
          duration: 100.ms,
        );
  }
}

// Animation Timing Constants
class AnimationTimings {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

// Animation Curves Library
class AnimationCurves {
  static const Curve slideIn = Curves.easeOutCubic;
  static const Curve slideOut = Curves.easeInCubic;
  static const Curve scale = Curves.elasticOut;
  static const Curve fade = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
}

// Pre-configured Animation Presets
class AnimationPresets {
  static Widget cardEntrance(Widget child, {Duration delay = Duration.zero}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: AnimationTimings.normal)
        .slideY(begin: 0.3, duration: AnimationTimings.normal, curve: AnimationCurves.slideIn)
        .shimmer(delay: AnimationTimings.slow, duration: AnimationTimings.normal);
  }
  
  static Widget listItemEntrance(Widget child, {Duration delay = Duration.zero}) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: AnimationTimings.fast)
        .slideX(begin: -0.3, duration: AnimationTimings.normal);
  }
  
  static Widget buttonPress(Widget child) {
    return child
        .animate()
        .scaleXY(begin: 1, end: 0.95, duration: AnimationTimings.fast);
  }
  
  static Widget successFeedback(Widget child) {
    return child
        .animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: AnimationTimings.fast,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
          duration: AnimationTimings.fast,
        );
  }
  
  static Widget errorShake(Widget child) {
    return child
        .animate()
        .shake(duration: AnimationTimings.normal);
  }
}

// Screen Transition Manager
class ScreenTransitionManager {
  static Future<T?> pushWithAnimation<T extends Object?>(
    BuildContext context,
    Widget screen, {
    ScreenTransition transition = ScreenTransition.slide,
    AxisDirection direction = AxisDirection.right,
  }) {
    switch (transition) {
      case ScreenTransition.slide:
        return context.slideToPage<T>(screen, direction: direction);
      case ScreenTransition.fade:
        return context.fadeToPage<T>(screen);
      case ScreenTransition.scale:
        return context.scaleToPage<T>(screen);
      case ScreenTransition.rotation:
        return context.rotateToPage<T>(screen);
      case ScreenTransition.size:
        return context.sizeToPage<T>(screen);
    }
  }
}

enum ScreenTransition {
  slide,
  fade,
  scale,
  rotation,
  size,
}

// Animation State Manager
class AnimationStateManager extends ChangeNotifier {
  bool _animationsEnabled = true;
  double _animationSpeed = 1.0;
  
  bool get animationsEnabled => _animationsEnabled;
  double get animationSpeed => _animationSpeed;
  
  void toggleAnimations() {
    _animationsEnabled = !_animationsEnabled;
    notifyListeners();
  }
  
  void setAnimationSpeed(double speed) {
    _animationSpeed = speed.clamp(0.1, 3.0);
    notifyListeners();
  }
}

// Global Animation Utils
class AnimationUtils {
  static Duration scaleDuration(Duration duration, double speed) {
    return Duration(
      milliseconds: (duration.inMilliseconds / speed).round(),
    );
  }
  
  static List<Duration> generateStaggeredDelays({
    required int itemCount,
    Duration baseDelay = const Duration(milliseconds: 100),
    Duration increment = const Duration(milliseconds: 50),
  }) {
    return List.generate(
      itemCount,
      (index) => baseDelay + (increment * index),
    );
  }
}
