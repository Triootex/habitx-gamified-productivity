import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ANIMATED PAGE TRANSITIONS - Every page change is beautiful!

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = AxisDirection.right,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    Offset begin;
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    switch (direction) {
      case AxisDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case AxisDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
      case AxisDirection.right:
        begin = const Offset(-1.0, 0.0);
        break;
      case AxisDirection.left:
        begin = const Offset(1.0, 0.0);
        break;
    }

    var tween = Tween(begin: begin, end: end);
    var curveTween = CurveTween(curve: curve);

    return SlideTransition(
      position: animation.drive(curveTween).drive(tween),
      child: child,
    );
  }
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  ScalePageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end);
    var curveTween = CurveTween(curve: curve);

    return ScaleTransition(
      scale: animation.drive(curveTween).drive(tween),
      child: child,
    );
  }
}

class RotationPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  RotationPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return RotationTransition(
      turns: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class SizePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SizePageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Align(
      child: SizeTransition(
        sizeFactor: animation,
        child: child,
      ),
    );
  }
}

// Animated Navigation Extensions
extension AnimatedNavigation on BuildContext {
  Future<T?> slideToPage<T extends Object?>(Widget page,
      {AxisDirection direction = AxisDirection.right}) {
    return Navigator.of(this).push<T>(
      SlidePageRoute(child: page, direction: direction),
    );
  }

  Future<T?> fadeToPage<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      FadePageRoute(child: page),
    );
  }

  Future<T?> scaleToPage<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      ScalePageRoute(child: page),
    );
  }

  Future<T?> rotateToPage<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      RotationPageRoute(child: page),
    );
  }

  Future<T?> sizeToPage<T extends Object?>(Widget page) {
    return Navigator.of(this).push<T>(
      SizePageRoute(child: page),
    );
  }
}

// Animated Bottom Sheet
class AnimatedBottomSheet extends StatelessWidget {
  final Widget child;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final ShapeBorder? shape;

  const AnimatedBottomSheet({
    Key? key,
    required this.child,
    this.isScrollControlled = false,
    this.backgroundColor,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    )
        .animate()
        .slideY(begin: 1, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 200.ms);
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedBottomSheet(
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        shape: shape,
        child: child,
      ),
    );
  }
}

// Animated Dialog
class AnimatedDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? insetPadding;
  final ShapeBorder? shape;
  final Color? backgroundColor;

  const AnimatedDialog({
    Key? key,
    required this.child,
    this.insetPadding,
    this.shape,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: insetPadding,
      shape: shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor,
      child: child,
    )
        .animate()
        .scale(
          begin: const Offset(0.7, 0.7),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 200.ms);
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? insetPadding,
    ShapeBorder? shape,
    Color? backgroundColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AnimatedDialog(
        insetPadding: insetPadding,
        shape: shape,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }
}

// Animated Snackbar
class AnimatedSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? Colors.white),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor ?? Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red,
      duration: duration,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.warning,
      backgroundColor: Colors.orange,
      duration: duration,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue,
      duration: duration,
    );
  }
}

// Animated Loading Overlay
class AnimatedLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Widget? loadingWidget;

  const AnimatedLoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.loadingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    loadingWidget ?? const CircularProgressIndicator(),
                    if (loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loadingText!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
      ],
    );
  }
}

// Animated Hero Transitions
class AnimatedHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;

  const AnimatedHero({
    Key? key,
    required this.tag,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
