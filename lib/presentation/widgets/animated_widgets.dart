import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/animations/animation_assets.dart';

class AnimatedWidget extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool autoPlay;
  final AnimationController? controller;
  final VoidCallback? onComplete;
  final BoxFit fit;

  const AnimatedWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.repeat = true,
    this.autoPlay = true,
    this.controller,
    this.onComplete,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      animate: autoPlay,
      controller: controller,
      onLoaded: (composition) {
        if (controller != null) {
          controller!
            ..duration = composition.duration
            ..forward().then((_) => onComplete?.call());
        }
      },
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.animation,
            color: Colors.grey[400],
            size: (width ?? 100) * 0.4,
          ),
        );
      },
    );
  }
}

class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const SuccessAnimationWidget({
    Key? key,
    this.onComplete,
    this.size = 100,
  }) : super(key: key);

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedWidget(
      assetPath: AnimationAssets.successCheck,
      width: widget.size,
      height: widget.size,
      repeat: false,
      controller: _controller,
      onComplete: widget.onComplete,
    );
  }
}

class LoadingAnimationWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingAnimationWidget({
    Key? key,
    this.size = 50,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedWidget(
      assetPath: AnimationAssets.loadingSpinner,
      width: size,
      height: size,
    );
  }
}

class CelebrationAnimationWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const CelebrationAnimationWidget({
    Key? key,
    this.onComplete,
    this.size = 200,
  }) : super(key: key);

  @override
  State<CelebrationAnimationWidget> createState() => _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedWidget(
      assetPath: AnimationAssets.confettiCelebration,
      width: widget.size,
      height: widget.size,
      repeat: false,
      controller: _controller,
      onComplete: widget.onComplete,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;
  final double animationSize;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.action,
    this.animationSize = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.emptyState,
              width: animationSize,
              height: animationSize,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final double animationSize;

  const ErrorStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.onRetry,
    this.animationSize = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedWidget(
              assetPath: AnimationAssets.errorState,
              width: animationSize,
              height: animationSize,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProgressAnimationWidget extends StatelessWidget {
  final double progress;
  final String animationAsset;
  final double size;

  const ProgressAnimationWidget({
    Key? key,
    required this.progress,
    required this.animationAsset,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedWidget(
          assetPath: animationAsset,
          width: size,
          height: size,
        ),
        SizedBox(
          width: size * 1.2,
          height: size * 1.2,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class MicroInteractionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? animationAsset;

  const MicroInteractionButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.animationAsset,
  }) : super(key: key);

  @override
  State<MicroInteractionButton> createState() => _MicroInteractionButtonState();
}

class _MicroInteractionButtonState extends State<MicroInteractionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class FloatingActionAnimationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String animationAsset;
  final Color? backgroundColor;
  final double size;

  const FloatingActionAnimationButton({
    Key? key,
    this.onPressed,
    required this.animationAsset,
    this.backgroundColor,
    this.size = 56,
  }) : super(key: key);

  @override
  State<FloatingActionAnimationButton> createState() => _FloatingActionAnimationButtonState();
}

class _FloatingActionAnimationButtonState extends State<FloatingActionAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _rotationController.forward().then((_) {
          _rotationController.reverse();
        });
        widget.onPressed?.call();
      },
      backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159,
            child: AnimatedWidget(
              assetPath: widget.animationAsset,
              width: widget.size * 0.6,
              height: widget.size * 0.6,
            ),
          );
        },
      ),
    );
  }
}

class CategoryIconAnimation extends StatelessWidget {
  final String category;
  final double size;
  final bool isSelected;

  const CategoryIconAnimation({
    Key? key,
    required this.category,
    this.size = 40,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationAsset = _getCategoryAnimation(category);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      child: AnimatedWidget(
        assetPath: animationAsset,
        width: size,
        height: size,
        repeat: isSelected,
      ),
    );
  }

  String _getCategoryAnimation(String category) {
    switch (category.toLowerCase()) {
      case 'meditation':
        return AnimationAssets.meditationPose;
      case 'fitness':
        return AnimationAssets.workoutSession;
      case 'tasks':
        return AnimationAssets.todoList;
      case 'habits':
        return AnimationAssets.habitCheck;
      case 'focus':
        return AnimationAssets.focusMode;
      case 'sleep':
        return AnimationAssets.sleepCycle;
      case 'mental_health':
        return AnimationAssets.mentalWellness;
      case 'language':
        return AnimationAssets.bookReading;
      case 'budget':
        return AnimationAssets.moneyManagement;
      case 'reading':
        return AnimationAssets.bookOpen;
      case 'journal':
        return AnimationAssets.writingJournal;
      case 'meals':
        return AnimationAssets.healthyFood;
      case 'flashcards':
        return AnimationAssets.brainTraining;
      case 'social':
        return AnimationAssets.socialConnection;
      case 'marketplace':
        return AnimationAssets.marketplaceShopping;
      default:
        return AnimationAssets.loadingSpinner;
    }
  }
}
