import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rive/rive.dart';
import 'universal_animated_widgets.dart';
import 'rive_animated_widgets.dart';
import '../../core/animations/animation_assets.dart';
import '../../core/animations/rive_animation_assets.dart';

/// Hybrid Animation Widget that can display both Lottie and Rive animations
class HybridAnimatedWidget extends StatelessWidget {
  final String? lottieAssetPath;
  final String? riveAssetPath;
  final double? width;
  final double? height;
  final bool autoplay;
  final bool loop;
  final BoxFit fit;
  final Alignment alignment;

  const HybridAnimatedWidget({
    Key? key,
    this.lottieAssetPath,
    this.riveAssetPath,
    this.width,
    this.height,
    this.autoplay = true,
    this.loop = true,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  }) : assert(lottieAssetPath != null || riveAssetPath != null,
         'Either lottieAssetPath or riveAssetPath must be provided'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    // Prefer Rive animation if both are provided
    if (riveAssetPath != null) {
      return RiveAnimatedWidget(
        assetPath: riveAssetPath!,
        width: width,
        height: height,
        autoplay: autoplay,
        loop: loop,
        fit: fit,
        alignment: alignment,
      );
    } else if (lottieAssetPath != null) {
      return AnimatedWidget(
        assetPath: lottieAssetPath!,
        width: width,
        height: height,
      );
    }
    
    return SizedBox(width: width, height: height);
  }
}

/// Enhanced Hybrid Card with both Lottie and Rive support
class HybridAnimatedCard extends StatefulWidget {
  final Widget child;
  final String? lottieAssetPath;
  final String? riveAssetPath;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Duration delay;
  final bool showBackgroundAnimation;

  const HybridAnimatedCard({
    Key? key,
    required this.child,
    this.lottieAssetPath,
    this.riveAssetPath,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.delay = Duration.zero,
    this.showBackgroundAnimation = false,
  }) : super(key: key);

  @override
  State<HybridAnimatedCard> createState() => _HybridAnimatedCardState();
}

class _HybridAnimatedCardState extends State<HybridAnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              boxShadow: widget.boxShadow ?? [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
                  blurRadius: _isHovered ? 15 : 10,
                  offset: Offset(0, _isHovered ? 8 : 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background animation layer
                if (widget.showBackgroundAnimation && (widget.riveAssetPath != null || widget.lottieAssetPath != null))
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: HybridAnimatedWidget(
                        riveAssetPath: widget.riveAssetPath,
                        lottieAssetPath: widget.lottieAssetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Main content
                widget.child,
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: widget.delay).fadeIn().slideY(begin: 0.3);
  }
}

/// Hybrid FAB with animation switching
class HybridAnimatedFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? lottieAssetPath;
  final String? riveAssetPath;
  final Color backgroundColor;
  final Widget? child;
  final bool animateOnPress;

  const HybridAnimatedFAB({
    Key? key,
    this.onPressed,
    this.lottieAssetPath,
    this.riveAssetPath,
    this.backgroundColor = Colors.blue,
    this.child,
    this.animateOnPress = true,
  }) : super(key: key);

  @override
  State<HybridAnimatedFAB> createState() => _HybridAnimatedFABState();
}

class _HybridAnimatedFABState extends State<HybridAnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.animateOnPress) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (widget.animateOnPress) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
        widget.onPressed?.call();
      },
      onTapCancel: () {
        if (widget.animateOnPress) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.1),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: _isPressed ? 20 : 10,
                    offset: Offset(0, _isPressed ? 8 : 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background animation
                  if (widget.riveAssetPath != null || widget.lottieAssetPath != null)
                    HybridAnimatedWidget(
                      riveAssetPath: widget.riveAssetPath,
                      lottieAssetPath: widget.lottieAssetPath,
                      width: 30,
                      height: 30,
                    ),
                  // Main content
                  if (widget.child != null) widget.child!,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hybrid Button with animation effects
class HybridAnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? lottieAssetPath;
  final String? riveAssetPath;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showAnimationOnHover;

  const HybridAnimatedButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.lottieAssetPath,
    this.riveAssetPath,
    this.backgroundColor = Colors.blue,
    this.padding,
    this.borderRadius,
    this.showAnimationOnHover = true,
  }) : super(key: key);

  @override
  State<HybridAnimatedButton> createState() => _HybridAnimatedButtonState();
}

class _HybridAnimatedButtonState extends State<HybridAnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.showAnimationOnHover) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (widget.showAnimationOnHover) {
          setState(() => _isHovered = false);
        }
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(_isPressed ? 0.4 : 0.2),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 2 : 4),
              ),
            ],
          ),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background animation (subtle)
              if (_isHovered && (widget.riveAssetPath != null || widget.lottieAssetPath != null))
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: HybridAnimatedWidget(
                      riveAssetPath: widget.riveAssetPath,
                      lottieAssetPath: widget.lottieAssetPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              // Button content
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Hybrid List Item with animations
class HybridAnimatedListItem extends StatelessWidget {
  final Widget child;
  final String? lottieAssetPath;
  final String? riveAssetPath;
  final VoidCallback? onTap;
  final int index;
  final Duration animationDelay;

  const HybridAnimatedListItem({
    Key? key,
    required this.child,
    this.lottieAssetPath,
    this.riveAssetPath,
    this.onTap,
    this.index = 0,
    this.animationDelay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HybridAnimatedCard(
      delay: animationDelay * index,
      onTap: onTap,
      riveAssetPath: riveAssetPath,
      lottieAssetPath: lottieAssetPath,
      showBackgroundAnimation: false,
      child: Row(
        children: [
          // Leading animation
          if (riveAssetPath != null || lottieAssetPath != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: HybridAnimatedWidget(
                riveAssetPath: riveAssetPath,
                lottieAssetPath: lottieAssetPath,
                width: 24,
                height: 24,
              ),
            ),
          // Main content
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Animation category mapping for easy integration
class HybridAnimationMappings {
  // Productivity animations
  static const Map<String, Map<String, String>> productivity = {
    'task_complete': {
      'rive': RiveAnimationAssets.taskComplete,
      'lottie': AnimationAssets.successCelebration,
    },
    'progress': {
      'rive': RiveAnimationAssets.progressBar,
      'lottie': AnimationAssets.loadingSpinner,
    },
    'goal_setting': {
      'rive': RiveAnimationAssets.goalProgress,
      'lottie': AnimationAssets.rocket,
    },
  };

  // Health animations
  static const Map<String, Map<String, String>> health = {
    'heart_beat': {
      'rive': RiveAnimationAssets.mascotFlying,
      'lottie': AnimationAssets.healthyHabits,
    },
    'meditation': {
      'rive': RiveAnimationAssets.avatarPack,
      'lottie': AnimationAssets.meditation,
    },
    'fitness': {
      'rive': RiveAnimationAssets.mascotFlying,
      'lottie': AnimationAssets.healthyHabits,
    },
  };

  // UI animations
  static const Map<String, Map<String, String>> ui = {
    'button': {
      'rive': RiveAnimationAssets.downloadButton,
      'lottie': AnimationAssets.loadingSpinner,
    },
    'loading': {
      'rive': RiveAnimationAssets.loadingIndicator,
      'lottie': AnimationAssets.loadingSpinner,
    },
    'success': {
      'rive': RiveAnimationAssets.downloadButton,
      'lottie': AnimationAssets.successCelebration,
    },
  };

  // Get animation paths for a category and type
  static Map<String, String>? getAnimationPaths(String category, String type) {
    switch (category) {
      case 'productivity':
        return productivity[type];
      case 'health':
        return health[type];
      case 'ui':
        return ui[type];
      default:
        return null;
    }
  }
}
