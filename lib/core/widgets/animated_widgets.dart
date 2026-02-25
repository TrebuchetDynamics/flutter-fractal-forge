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
                          color: AppColors.primary.withValues(alpha: _isPressed ? 0.5 : 0.3),
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
              colors: const [
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

/// Reusable press-to-scale wrapper that eliminates duplicate tap animation boilerplate.
///
/// Wraps a child in a [GestureDetector] + [ScaleTransition] that scales down
/// on press and springs back on release. The [builder] receives the current
/// `isPressed` state so consumers can adjust decoration (color, border, etc.).
class PressableScale extends StatefulWidget {
  /// Builder that receives the current pressed state.
  final Widget Function(bool isPressed) builder;

  /// Called when the user taps. If null, press animation is disabled.
  final VoidCallback? onTap;

  /// Scale factor at the deepest point of the press (default 0.95).
  final double scaleEnd;

  /// Animation curve (default [AppAnimations.snappyCurve]).
  final Curve curve;

  const PressableScale({
    Key? key,
    required this.builder,
    this.onTap,
    this.scaleEnd = 0.95,
    this.curve = AppAnimations.snappyCurve,
  }) : super(key: key);

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleEnd).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scaleEnd != oldWidget.scaleEnd || widget.curve != oldWidget.curve) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleEnd).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      } : null,
      onTapUp: enabled ? (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      } : null,
      onTapCancel: enabled ? () {
        setState(() => _isPressed = false);
        _controller.reverse();
      } : null,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.builder(_isPressed),
      ),
    );
  }
}

/// Premium slider with value indicator and smooth animations.
class PremiumSlider extends StatefulWidget {
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
  State<PremiumSlider> createState() => _PremiumSliderState();
}

class _PremiumSliderState extends State<PremiumSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDragging = false;
  double? _previousValue;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(PremiumSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isDragging) {
      _previousValue = oldWidget.value;
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getValueColor() {
    if (_previousValue == null) return AppColors.primary;
    
    final delta = widget.value - _previousValue!;
    final range = widget.max - widget.min;
    final normalizedDelta = (delta / range).abs();

    if (normalizedDelta > 0.05) {
      return delta > 0 ? AppColors.secondary : AppColors.primaryLight;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? _getValueColor().withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: _isDragging
                          ? Border.all(color: _getValueColor().withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Text(
                      widget.valueLabel ?? widget.value.toStringAsFixed(2),
                      style: AppTypography.labelSmall.copyWith(
                        color: _isDragging ? _getValueColor() : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: _AnimatedSliderThumbShape(
              enabledThumbRadius: 10,
              isActive: _isDragging,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            activeTrackColor: _isDragging ? _getValueColor() : AppColors.primary,
            inactiveTrackColor: AppColors.surfaceVariant,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChangeStart: (_) => setState(() => _isDragging = true),
            onChangeEnd: (_) => setState(() => _isDragging = false),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

/// Custom slider thumb with animation support.
class _AnimatedSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final bool isActive;

  const _AnimatedSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.isActive = false,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    final radius = enabledThumbRadius * (1 + activationAnimation.value * 0.15);
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), radius, shadowPaint);
    
    // Draw glow when active
    if (isActive || activationAnimation.value > 0) {
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3 * activationAnimation.value)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius * 1.5, glowPaint);
    }
    
    // Draw thumb
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
    
    // Draw inner circle accent
    final accentPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1 + activationAnimation.value * 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, accentPaint);
  }
}
