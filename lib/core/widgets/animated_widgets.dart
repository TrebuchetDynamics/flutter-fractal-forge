import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card with glassmorphism effect and subtle animations.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final VoidCallback? onTap;
  final double blur;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showBorder = true,
    this.onTap,
    this.blur = 10,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(AppSpacing.cardRadius);

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blur,
                sigmaY: widget.blur,
              ),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                decoration: BoxDecoration(
                  color: _isPressed
                      ? AppColors.surfaceElevated.withValues(alpha: 0.9)
                      : AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: radius,
                  border: widget.showBorder
                      ? Border.all(
                          color: _isPressed
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium button with gradient and glow effect.
class GradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showGlow;

  const GradientButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.showGlow = true,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppColors.primaryGradient;
    final radius = widget.borderRadius ??
        BorderRadius.circular(AppSpacing.buttonRadius);
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      } : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      } : null,
      onTapCancel: isEnabled ? () {
        setState(() => _isPressed = false);
        _controller.reverse();
      } : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: AppAnimations.fast,
          opacity: isEnabled ? 1.0 : 0.5,
          child: Stack(
            children: [
              if (widget.showGlow && isEnabled)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: AppAnimations.normal,
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: _isPressed ? 0.5 : 0.3,
                          ),
                          blurRadius: _isPressed ? 16 : 12,
                          spreadRadius: _isPressed ? 2 : 0,
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: radius,
                ),
                child: DefaultTextStyle(
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated icon button with ripple and glow.
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? activeColor;
  final bool isActive;
  final double size;

  const AnimatedIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.activeColor,
    this.isActive = false,
    this.size = 24,
  }) : super(key: key);

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.snappyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? (widget.activeColor ?? AppColors.primary)
        : (widget.color ?? AppColors.textSecondary);

    Widget button = GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
      onTapCancel: widget.onPressed != null ? () => _controller.reverse() : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppAnimations.normal,
            style: TextStyle(color: color),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: color,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

/// Fade-in animation wrapper.
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeIn({
    Key? key,
    required this.child,
    this.duration = AppAnimations.normal,
    this.delay = Duration.zero,
    this.curve = AppAnimations.defaultCurve,
  }) : super(key: key);

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered list animation wrapper.
class StaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration itemDelay;

  const StaggeredItem({
    Key? key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 50),
    this.itemDelay = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      delay: baseDelay + (itemDelay * index),
      child: child,
    );
  }
}

/// Shimmer loading effect.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(AppSpacing.chipRadius),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                AppColors.surfaceVariant,
                AppColors.surfaceElevated,
                AppColors.surfaceVariant,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Section header with animated line.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.border.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Premium slider with value indicator.
class PremiumSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String? valueLabel;
  final ValueChanged<double>? onChanged;
  final int? divisions;

  const PremiumSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    this.valueLabel,
    this.onChanged,
    this.divisions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                valueLabel ?? value.toStringAsFixed(2),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
