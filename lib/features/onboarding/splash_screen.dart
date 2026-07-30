import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/renderer/widgets/renderer/fractal_renderer.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Animated splash screen for Fractal Forge.
class FractalSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  final Duration duration;

  const FractalSplashScreen({
    super.key,
    required this.onFinished,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<FractalSplashScreen> createState() => _FractalSplashScreenState();
}

class _FractalSplashScreenState extends State<FractalSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  FractalController? _fractalController;
  bool _didPickSplashFractal = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    // Defer animation start to avoid competing with first-frame layout.
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.repeat();
    });

    Future<void>.delayed(widget.duration, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPickSplashFractal) return;
    _didPickSplashFractal = true;

    try {
      final registry = context.read<ModuleRegistry>();
      final controller = FractalController(registry);
      final modules = registry.modules
          .where((module) => module.dimension == FractalDimension.twoD)
          .toList(growable: false);
      if (modules.isNotEmpty) {
        controller.selectModule(
          modules[math.Random().nextInt(modules.length)],
          animate: false,
        );
        controller.randomizeParams();
      }
      _fractalController = controller;
    } catch (_) {
      // Standalone splash previews/tests can render the lightweight fallback.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fractalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final controller = _fractalController;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (controller == null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: _controller.value * math.pi,
                      endAngle: _controller.value * math.pi + (math.pi * 2),
                      colors: [
                        const Color(0xFF090A17),
                        AppColors.primary.withValues(alpha: 0.45),
                        const Color(0xFF0C2233),
                        AppColors.secondary.withValues(alpha: 0.30),
                        const Color(0xFF090A17),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _SplashFractalPainter(progress: _controller.value),
                  ),
                )
              else
                ChangeNotifierProvider.value(
                  value: controller,
                  child: const FractalRenderer(
                    gesturesEnabled: false,
                    showRendererIndicator: false,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),
              Center(
                child: Semantics(
                  header: true,
                  label: l10n.semanticSplashScreen,
                  child: Text(
                    'FRACTAL FORGE',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.4,
                      color: const Color(0xFFF2EEFF),
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withValues(alpha: 0.65),
                          blurRadius: 28,
                        ),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashFractalPainter extends CustomPainter {
  final double progress;

  _SplashFractalPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int branch = 0; branch < 7; branch++) {
      final angle = (math.pi * 2 / 7) * branch + progress * math.pi * 0.8;
      final path = Path()..moveTo(center.dx, center.dy);

      for (int i = 0; i < 55; i++) {
        final t = i / 55;
        final radius =
            (size.shortestSide * 0.08) + (size.shortestSide * 0.44 * t);
        final wobble = math.sin((t * 16) + progress * 8 + branch) * 18;
        final x =
            center.dx + math.cos(angle + t * 3.5 + wobble * 0.0025) * radius;
        final y =
            center.dy + math.sin(angle + t * 3.5 + wobble * 0.0025) * radius;
        path.lineTo(x, y);
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = (branch.isEven ? AppColors.primary : AppColors.secondary)
            .withValues(alpha: 0.16);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashFractalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
