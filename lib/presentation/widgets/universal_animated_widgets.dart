import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/animations/animation_assets.dart';

// ANIMATED EVERYTHING - Every component has animations!

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const AnimatedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.bottom,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title.animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
      actions: actions?.map((action) => 
        action.animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8))
      ).toList(),
      bottom: bottom,
      backgroundColor: backgroundColor,
    ).animate().slideY(begin: -1, duration: 500.ms);
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0)
  );
}

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final Duration delay;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    )
    .animate(delay: delay)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.3, duration: 600.ms)
    .animate(onPlay: (controller) => controller.repeat())
    .shimmer(delay: 2000.ms, duration: 800.ms);
  }
}

class AnimatedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Duration delay;

  const AnimatedListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading?.animate().fadeIn().scale(),
      title: title,
      subtitle: subtitle,
      trailing: trailing?.animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),
      onTap: onTap,
    )
    .animate(delay: delay)
    .fadeIn(duration: 500.ms)
    .slideX(begin: -0.3, duration: 500.ms);
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final String? animationAsset;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.animationAsset,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_controller.value * 0.05),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1 - (_controller.value * 0.05)),
                    blurRadius: 8 - (_controller.value * 2),
                    offset: Offset(0, 4 - (_controller.value * 2)),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.child,
                  if (widget.animationAsset != null)
                    Positioned.fill(
                      child: AnimatedWidget(
                        assetPath: widget.animationAsset!,
                        width: 24,
                        height: 24,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn().scale();
  }
}

class AnimatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Duration delay;

  const AnimatedTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon?.animate().fadeIn().scale(),
          suffixIcon: widget.suffixIcon?.animate().fadeIn(delay: 200.ms).scale(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    )
    .animate(delay: widget.delay)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.2, duration: 600.ms)
    .animate(target: _isFocused ? 1 : 0)
    .scaleXY(begin: 1, end: 1.02, duration: 200.ms);
  }
}

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Duration delay;

  const AnimatedCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.value) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: widget.value 
                ? Theme.of(context).primaryColor 
                : Colors.grey,
            width: 2,
          ),
          color: widget.value 
              ? Theme.of(context).primaryColor 
              : Colors.transparent,
        ),
        child: widget.value
            ? AnimatedWidget(
                assetPath: AnimationAssets.successCheck,
                width: 16,
                height: 16,
              )
            : null,
      ),
    )
    .animate(delay: widget.delay)
    .fadeIn()
    .scale()
    .animate(target: widget.value ? 1 : 0)
    .scaleXY(begin: 1, end: 1.1, duration: 200.ms);
  }
}

class AnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Duration delay;

  const AnimatedSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  State<AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.value) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color.lerp(
                Colors.grey[300],
                Theme.of(context).primaryColor,
                _animation.value,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: widget.value ? 28 : 4,
                  top: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate(delay: widget.delay).fadeIn().scale();
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final Duration delay;
  final String? animationAsset;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.delay = Duration.zero,
    this.animationAsset,
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: widget.backgroundColor ?? Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.progressColor ?? Theme.of(context).primaryColor,
              ),
            ),
            if (widget.animationAsset != null)
              AnimatedWidget(
                assetPath: widget.animationAsset!,
                width: 30,
                height: 30,
              ),
          ],
        );
      },
    ).animate(delay: widget.delay).fadeIn().slideX();
  }
}

class AnimatedChip extends StatelessWidget {
  final Widget label;
  final Widget? avatar;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Duration delay;

  const AnimatedChip({
    Key? key,
    required this.label,
    this.avatar,
    this.onPressed,
    this.onDeleted,
    this.backgroundColor,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: label,
      avatar: avatar,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      deleteIcon: onDeleted != null ? const Icon(Icons.close) : null,
      onDeleted: onDeleted,
    )
    .animate(delay: delay)
    .fadeIn(duration: 400.ms)
    .scale(begin: const Offset(0.8, 0.8))
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scaleXY(begin: 1, end: 1.02, duration: 2000.ms);
  }
}

class AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final Duration delay;
  final String? animationAsset;

  const AnimatedIcon({
    Key? key,
    required this.icon,
    this.size,
    this.color,
    this.delay = Duration.zero,
    this.animationAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return animationAsset != null
        ? AnimatedWidget(
            assetPath: animationAsset!,
            width: size ?? 24,
            height: size ?? 24,
          )
        : Icon(
            icon,
            size: size,
            color: color,
          )
          .animate(delay: delay)
          .fadeIn()
          .scale()
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .rotate(begin: 0, end: 0.05, duration: 1000.ms);
  }
}

class AnimatedBadge extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  final Color? badgeColor;
  final Duration delay;

  const AnimatedBadge({
    Key? key,
    required this.child,
    this.badgeText,
    this.badgeColor,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badgeText != null)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .animate(delay: delay)
            .fadeIn()
            .scale()
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(begin: 1, end: 1.2, duration: 800.ms),
          ),
      ],
    );
  }
}

class AnimatedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final Duration delay;

  const AnimatedAvatar({
    Key? key,
    this.imageUrl,
    this.initials,
    this.radius = 20,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && initials != null
          ? Text(
              initials!,
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    )
    .animate(delay: delay)
    .fadeIn()
    .scale()
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scaleXY(begin: 1, end: 1.05, duration: 2000.ms);
  }
}

class AnimatedFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? animationAsset;
  final Color? backgroundColor;

  const AnimatedFAB({
    Key? key,
    this.onPressed,
    required this.child,
    this.animationAsset,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: animationAsset != null
          ? AnimatedWidget(
              assetPath: animationAsset!,
              width: 32,
              height: 32,
            )
          : child,
    )
    .animate()
    .fadeIn(delay: 500.ms)
    .scale(delay: 500.ms)
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scaleXY(begin: 1, end: 1.1, duration: 1500.ms);
  }
}

class AnimatedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final Duration delay;

  const AnimatedContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      child: child,
    )
    .animate(delay: delay)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.3, duration: 600.ms);
  }
}
