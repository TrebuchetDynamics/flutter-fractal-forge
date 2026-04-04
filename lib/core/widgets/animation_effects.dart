import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Particle effect for celebration when finding interesting fractal spots.
class CelebrationEffect extends StatefulWidget {
  /// Whether the celebration is active.
  final bool isActive;

  /// Callback when the celebration animation completes.
  final VoidCallback? onComplete;

  /// The child widget to display behind the celebration.
  final Widget? child;

  /// The number of particles to emit.
  final int particleCount;

  const CelebrationEffect({
    Key? key,
    this.isActive = false,
    this.onComplete,
    this.child,
    this.particleCount = 40,
  }) : super(key: key);

  @override
  State<CelebrationEffect> createState() => _CelebrationEffectState();
}

class _CelebrationEffectState extends State<CelebrationEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.celebration,
      vsync: this,
    );
    _particles = [];
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call();
    }
  }

  @override
  void didUpdateWidget(CelebrationEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    HapticFeedback.mediumImpact();
    _particles = List.generate(
        widget.particleCount,
        (_) => _Particle(
              color: _randomColor(),
              position: Offset.zero,
              velocity: Offset(
                (_random.nextDouble() - 0.5) * 8,
                -_random.nextDouble() * 10 - 5,
              ),
              size: _random.nextDouble() * 8 + 4,
              rotation: _random.nextDouble() * math.pi * 2,
              rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
              shape: _ParticleShape
                  .values[_random.nextInt(_ParticleShape.values.length)],
            ));
    _controller.forward(from: 0);
  }

  Color _randomColor() {
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.secondary,
      AppColors.secondaryLight,
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFF4ECDC4),
      const Color(0xFFC44569),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.isActive || _controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

enum _ParticleShape { circle, star, diamond, heart }

class _Particle {
  final Color color;
  final Offset position;
  final Offset velocity;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final _ParticleShape shape;

  _Particle({
    required this.color,
    required this.position,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const gravity = 15.0;

    for (final particle in particles) {
      final t = progress;
      final opacity = (1 - t).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      // Physics simulation
      final x =
          center.dx + particle.position.dx + particle.velocity.dx * t * 100;
      final y = center.dy +
          particle.position.dy +
          particle.velocity.dy * t * 100 +
          0.5 * gravity * t * t * 100;

      final scale = 1.0 - t * 0.5;
      final currentSize = particle.size * scale;
      final rotation = particle.rotation + particle.rotationSpeed * t * 10;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (particle.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, currentSize, paint);
          break;
        case _ParticleShape.star:
          _drawStar(canvas, currentSize, paint);
          break;
        case _ParticleShape.diamond:
          _drawDiamond(canvas, currentSize, paint);
          break;
        case _ParticleShape.heart:
          _drawHeart(canvas, currentSize, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    const points = 5;
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.7, 0)
      ..lineTo(0, size)
      ..lineTo(-size * 0.7, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final s = size * 0.8;
    path.moveTo(0, s * 0.3);
    path.cubicTo(-s, -s * 0.3, -s, s * 0.6, 0, s);
    path.cubicTo(s, s * 0.6, s, -s * 0.3, 0, s * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

/// Animated loading indicator with fractal-inspired design.
class FractalLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const FractalLoadingIndicator({
    Key? key,
    this.size = 64,
    this.color,
    this.message,
  }) : super(key: key);

  @override
  State<FractalLoadingIndicator> createState() =>
      _FractalLoadingIndicatorState();
}

class _FractalLoadingIndicatorState extends State<FractalLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _morphController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: AppAnimations.loadingRotation,
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: AppAnimations.loadingPulse,
      vsync: this,
    )..repeat(reverse: true);

    _morphController = AnimationController(
      duration: AppAnimations.morphTransition,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final color = widget.color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
              _morphController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: _FractalLoadingPainter(
                  rotation: _rotationController.value,
                  pulse: _pulseController.value,
                  morph: _morphController.value,
                  color: color,
                ),
              );
            },
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.6 + _pulseController.value * 0.4,
                child: Text(
                  widget.message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _FractalLoadingPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final double morph;
  final Color color;

  _FractalLoadingPainter({
    required this.rotation,
    required this.pulse,
    required this.morph,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 3;

    // Draw multiple rotating spirals
    for (var layer = 0; layer < 3; layer++) {
      final layerOpacity = 1.0 - layer * 0.25;
      final layerRotation = rotation * math.pi * 2 + layer * math.pi / 3;
      final layerRadius = baseRadius * (1 + pulse * 0.15) * (1 - layer * 0.15);

      final paint = Paint()
        ..color = color.withValues(alpha: layerOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 - layer * 0.5
        ..strokeCap = StrokeCap.round;

      // Draw spiral arm
      final path = Path();
      const points = 60;
      for (var i = 0; i < points; i++) {
        final t = i / points;
        final angle = layerRotation + t * math.pi * 2 * 1.5;
        final r = layerRadius *
            t *
            (1 + math.sin(morph * math.pi * 2 + t * math.pi * 4) * 0.1);
        final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);

        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    // Draw pulsing center
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4 + pulse * 2, centerPaint);

    // Draw orbiting dots
    for (var i = 0; i < 5; i++) {
      final angle = rotation * math.pi * 2 * 2 + i * math.pi * 2 / 5;
      final orbitRadius = baseRadius * 0.6;
      final dotPos = center +
          Offset(
            math.cos(angle) * orbitRadius,
            math.sin(angle) * orbitRadius,
          );
      final dotSize = 3 + math.sin(morph * math.pi * 2 + i) * 1.5;

      canvas.drawCircle(
        dotPos,
        dotSize,
        Paint()..color = color.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_FractalLoadingPainter oldDelegate) => true;
}

/// Smooth morphing transition between fractal types.
class FractalMorphTransition extends StatefulWidget {
  final String currentFractalType;
  final Widget child;
  final Duration duration;

  const FractalMorphTransition({
    Key? key,
    required this.currentFractalType,
    required this.child,
    this.duration = AppAnimations.slower,
  }) : super(key: key);

  @override
  State<FractalMorphTransition> createState() => _FractalMorphTransitionState();
}

class _FractalMorphTransitionState extends State<FractalMorphTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(FractalMorphTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFractalType != oldWidget.currentFractalType) {
      HapticFeedback.lightImpact();
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
      animation: _controller,
      builder: (context, child) {
        final glowValue = _glowAnimation.value;

        return Stack(
          children: [
            widget.child,

            // Glow overlay during transition
            if (glowValue > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: glowValue * 0.3),
                          AppColors.secondary
                              .withValues(alpha: glowValue * 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // Ripple effect
            if (glowValue > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _MorphRipplePainter(
                      progress: _controller.value,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MorphRipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _MorphRipplePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height);

    // Draw multiple expanding rings
    for (var i = 0; i < 3; i++) {
      final ringProgress = (progress - i * 0.15).clamp(0.0, 1.0);
      if (ringProgress <= 0) continue;

      final radius = maxRadius * ringProgress;
      final opacity = (1 - ringProgress) * 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MorphRipplePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Smooth parameter transition wrapper with visual feedback.
class ParameterTransition extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final Widget child;
  final Duration duration;

  const ParameterTransition({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    required this.child,
    this.duration = AppAnimations.valueChange,
  }) : super(key: key);

  @override
  State<ParameterTransition> createState() => _ParameterTransitionState();
}

class _ParameterTransitionState extends State<ParameterTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  double? _previousValue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ParameterTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTransitionColor() {
    if (_previousValue == null) return Colors.transparent;

    final delta = widget.value - _previousValue!;
    final range = widget.max - widget.min;
    final normalizedDelta = (delta / range).abs();

    if (normalizedDelta > 0.1) {
      return delta > 0 ? AppColors.secondary : AppColors.primary;
    }
    return AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isAnimating = _controller.isAnimating;

        return Stack(
          children: [
            Transform.scale(
              scale: isAnimating ? _pulseAnimation.value : 1.0,
              child: widget.child,
            ),
            if (isAnimating)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _getTransitionColor()
                            .withValues(alpha: (1 - _controller.value) * 0.5),
                        width: 2,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Sparkle effect for interesting spot discovery.
class SparkleEffect extends StatefulWidget {
  final bool isActive;
  final Widget child;
  final int sparkleCount;

  const SparkleEffect({
    Key? key,
    this.isActive = false,
    required this.child,
    this.sparkleCount = 12,
  }) : super(key: key);

  @override
  State<SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random();
  late List<_SparkleData> _sparkles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.loadingPulse,
      vsync: this,
    );
    _generateSparkles();
  }

  void _generateSparkles() {
    _sparkles = List.generate(widget.sparkleCount, (index) {
      return _SparkleData(
        angle: _random.nextDouble() * math.pi * 2,
        distance: 0.3 + _random.nextDouble() * 0.4,
        size: 4 + _random.nextDouble() * 8,
        delay: _random.nextDouble() * 0.3,
      );
    });
  }

  @override
  void didUpdateWidget(SparkleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateSparkles();
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
    return Stack(
      children: [
        widget.child,
        if (widget.isActive || _controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SparklePainter(
                      sparkles: _sparkles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SparkleData {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _SparkleData({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_SparkleData> sparkles;
  final double progress;

  _SparklePainter({
    required this.sparkles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxDist = math.min(size.width, size.height) / 2;

    for (final sparkle in sparkles) {
      final adjustedProgress =
          ((progress - sparkle.delay) / (1 - sparkle.delay)).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final dist = sparkle.distance * maxDist * adjustedProgress;
      final x = center.dx + math.cos(sparkle.angle) * dist;
      final y = center.dy + math.sin(sparkle.angle) * dist;

      final opacity = math.sin(adjustedProgress * math.pi);
      final currentSize = sparkle.size * opacity;

      _drawSparkle(
        canvas,
        Offset(x, y),
        currentSize,
        AppColors.secondary.withValues(alpha: opacity * 0.8),
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a 4-pointed star
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final outerPoint = Offset(
        center.dx + math.cos(angle) * size,
        center.dy + math.sin(angle) * size,
      );
      final innerAngle = angle + math.pi / 4;
      final innerPoint = Offset(
        center.dx + math.cos(innerAngle) * size * 0.3,
        center.dy + math.sin(innerAngle) * size * 0.3,
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, size * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Animated value display that shows changes smoothly.
class AnimatedValueDisplay extends StatefulWidget {
  final double value;
  final String Function(double) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedValueDisplay({
    Key? key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = AppAnimations.quickTransition,
  }) : super(key: key);

  @override
  State<AnimatedValueDisplay> createState() => _AnimatedValueDisplayState();
}

class _AnimatedValueDisplayState extends State<AnimatedValueDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.value,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AnimatedValueDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _oldValue = _animation.value;
      _animation = Tween<double>(
        begin: _oldValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
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
        return Text(
          widget.formatter(_animation.value),
          style: widget.style ?? AppTypography.bodyMedium,
        );
      },
    );
  }
}

/// Breathing animation wrapper for subtle ambient effects.
class BreathingAnimation extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  const BreathingAnimation({
    Key? key,
    required this.child,
    this.minScale = 0.98,
    this.maxScale = 1.02,
    this.duration = AppAnimations.loadingRotation,
  }) : super(key: key);

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
