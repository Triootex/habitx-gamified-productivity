import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Universal Rive Widget for playing Rive animations
class RiveAnimatedWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? artboard;
  final String? stateMachine;
  final List<String>? animations;
  final void Function(Artboard)? onInit;
  final bool autoplay;
  final bool loop;
  final Alignment alignment;
  final Color? backgroundColor;
  final bool interactive;
  final void Function(String, bool)? onStateChanged;

  const RiveAnimatedWidget({
    Key? key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.artboard,
    this.stateMachine,
    this.animations,
    this.onInit,
    this.autoplay = true,
    this.loop = true,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.interactive = false,
    this.onStateChanged,
  }) : super(key: key);

  @override
  State<RiveAnimatedWidget> createState() => _RiveAnimatedWidgetState();
}

class _RiveAnimatedWidgetState extends State<RiveAnimatedWidget> {
  late RiveAnimationController _controller;
  SMIInput<bool>? _trigger;
  SMIInput<double>? _number;
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _setupController() {
    if (widget.stateMachine != null) {
      _controller = StateMachineController.fromArtboard(
        _artboard!,
        widget.stateMachine!,
      )!;
    } else if (widget.animations?.isNotEmpty == true) {
      _controller = SimpleAnimation(
        widget.animations!.first,
        autoplay: widget.autoplay,
      );
    } else {
      _controller = SimpleAnimation('idle', autoplay: widget.autoplay);
    }
  }

  void _onRiveInit(Artboard artboard) {
    _artboard = artboard;
    
    if (widget.stateMachine != null) {
      final controller = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachine!,
      );
      
      if (controller != null) {
        artboard.addController(controller);
        
        // Get common inputs
        _trigger = controller.findInput<bool>('trigger');
        _number = controller.findInput<double>('number');
      }
    }
    
    widget.onInit?.call(artboard);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.backgroundColor != null
          ? BoxDecoration(color: widget.backgroundColor)
          : null,
      child: RiveAnimation.asset(
        widget.assetPath,
        artboard: widget.artboard,
        fit: widget.fit,
        alignment: widget.alignment,
        onInit: _onRiveInit,
      ),
    );
  }

  // Public methods to control the animation
  void trigger() {
    _trigger?.value = true;
  }

  void setNumber(double value) {
    _number?.value = value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Interactive Rive Button with hover and press states
class RiveInteractiveButton extends StatefulWidget {
  final String assetPath;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String stateMachine;

  const RiveInteractiveButton({
    Key? key,
    required this.assetPath,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.stateMachine = 'State Machine 1',
  }) : super(key: key);

  @override
  State<RiveInteractiveButton> createState() => _RiveInteractiveButtonState();
}

class _RiveInteractiveButtonState extends State<RiveInteractiveButton> {
  StateMachineController? _controller;
  SMIInput<bool>? _hoverInput;
  SMIInput<bool>? _pressInput;

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachine,
    );
    
    if (_controller != null) {
      artboard.addController(_controller!);
      _hoverInput = _controller!.findInput<bool>('hover');
      _pressInput = _controller!.findInput<bool>('press');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _pressInput?.value = true,
      onTapUp: (_) => _pressInput?.value = false,
      onTapCancel: () => _pressInput?.value = false,
      child: MouseRegion(
        onEnter: (_) => _hoverInput?.value = true,
        onExit: (_) => _hoverInput?.value = false,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RiveAnimation.asset(
                widget.assetPath,
                onInit: _onRiveInit,
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// Rive Progress Bar with interactive states
class RiveProgressBar extends StatefulWidget {
  final String assetPath;
  final double progress; // 0.0 to 1.0
  final double? width;
  final double? height;
  final String stateMachine;
  final Color? backgroundColor;

  const RiveProgressBar({
    Key? key,
    required this.assetPath,
    required this.progress,
    this.width,
    this.height,
    this.stateMachine = 'State Machine 1',
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<RiveProgressBar> createState() => _RiveProgressBarState();
}

class _RiveProgressBarState extends State<RiveProgressBar> {
  StateMachineController? _controller;
  SMIInput<double>? _progressInput;

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachine,
    );
    
    if (_controller != null) {
      artboard.addController(_controller!);
      _progressInput = _controller!.findInput<double>('progress');
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progressInput?.value = widget.progress * 100; // Convert to percentage
  }

  @override
  void didUpdateWidget(RiveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _updateProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: widget.backgroundColor != null
          ? BoxDecoration(color: widget.backgroundColor)
          : null,
      child: RiveAnimation.asset(
        widget.assetPath,
        onInit: _onRiveInit,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// Rive Toggle Switch with on/off states
class RiveToggleSwitch extends StatefulWidget {
  final String assetPath;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;
  final String stateMachine;

  const RiveToggleSwitch({
    Key? key,
    required this.assetPath,
    required this.value,
    this.onChanged,
    this.width,
    this.height,
    this.stateMachine = 'State Machine 1',
  }) : super(key: key);

  @override
  State<RiveToggleSwitch> createState() => _RiveToggleSwitchState();
}

class _RiveToggleSwitchState extends State<RiveToggleSwitch> {
  StateMachineController? _controller;
  SMIInput<bool>? _toggleInput;

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachine,
    );
    
    if (_controller != null) {
      artboard.addController(_controller!);
      _toggleInput = _controller!.findInput<bool>('toggle');
      _updateToggle();
    }
  }

  void _updateToggle() {
    _toggleInput?.value = widget.value;
  }

  @override
  void didUpdateWidget(RiveToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateToggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: Container(
        width: widget.width,
        height: widget.height,
        child: RiveAnimation.asset(
          widget.assetPath,
          onInit: _onRiveInit,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// Rive Character with multiple states
class RiveCharacter extends StatefulWidget {
  final String assetPath;
  final String currentState;
  final double? width;
  final double? height;
  final Map<String, dynamic>? parameters;
  final String stateMachine;

  const RiveCharacter({
    Key? key,
    required this.assetPath,
    required this.currentState,
    this.width,
    this.height,
    this.parameters,
    this.stateMachine = 'State Machine 1',
  }) : super(key: key);

  @override
  State<RiveCharacter> createState() => _RiveCharacterState();
}

class _RiveCharacterState extends State<RiveCharacter> {
  StateMachineController? _controller;
  Map<String, SMIInput> _inputs = {};

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachine,
    );
    
    if (_controller != null) {
      artboard.addController(_controller!);
      
      // Get all available inputs
      for (final input in _controller!.inputs) {
        _inputs[input.name] = input;
      }
      
      _updateState();
    }
  }

  void _updateState() {
    // Set the current state
    final stateInput = _inputs[widget.currentState];
    if (stateInput is SMIBool) {
      stateInput.value = true;
    } else if (stateInput is SMITrigger) {
      stateInput.fire();
    }
    
    // Set additional parameters
    widget.parameters?.forEach((key, value) {
      final input = _inputs[key];
      if (input is SMINumber && value is num) {
        input.value = value.toDouble();
      } else if (input is SMIBool && value is bool) {
        input.value = value;
      }
    });
  }

  @override
  void didUpdateWidget(RiveCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentState != widget.currentState ||
        oldWidget.parameters != widget.parameters) {
      _updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: RiveAnimation.asset(
        widget.assetPath,
        onInit: _onRiveInit,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

/// Rive Loading Indicator
class RiveLoadingIndicator extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? backgroundColor;

  const RiveLoadingIndicator({
    Key? key,
    required this.assetPath,
    this.size = 50.0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(size / 2),
            )
          : null,
      child: RiveAnimatedWidget(
        assetPath: assetPath,
        width: size,
        height: size,
        autoplay: true,
        loop: true,
      ),
    );
  }
}

/// Rive Animated Card with hover effects
class RiveAnimatedCard extends StatefulWidget {
  final Widget child;
  final String? riveAssetPath;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Duration delay;

  const RiveAnimatedCard({
    Key? key,
    required this.child,
    this.riveAssetPath,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<RiveAnimatedCard> createState() => _RiveAnimatedCardState();
}

class _RiveAnimatedCardState extends State<RiveAnimatedCard> {
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
                if (widget.riveAssetPath != null)
                  Positioned.fill(
                    child: RiveAnimatedWidget(
                      assetPath: widget.riveAssetPath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: widget.delay).fadeIn().slideY(begin: 0.3);
  }
}
