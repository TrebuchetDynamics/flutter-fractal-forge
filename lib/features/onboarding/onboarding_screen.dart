import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Future<void>.delayed(widget.duration, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: _controller.value * math.pi,
                endAngle: _controller.value * math.pi + (math.pi * 2),
                colors: [
                  const Color(0xFF090A17),
                  AppColors.primary.withOpacity(0.45),
                  const Color(0xFF0C2233),
                  AppColors.secondary.withOpacity(0.30),
                  const Color(0xFF090A17),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SplashFractalPainter(progress: _controller.value),
                  ),
                ),
                Center(
                  child: Semantics(
                    header: true,
                    label: 'Fractal Forge splash screen',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Fractal Forge',
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [
                                  Color(0xFFF2EEFF),
                                  Color(0xFFC9B2FF),
                                  Color(0xFFA6F5FF),
                                ],
                              ).createShader(
                                  const Rect.fromLTWH(0, 0, 300, 60)),
                            shadows: [
                              Shadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Explore infinite mathematical patterns',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            .withOpacity(0.16);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashFractalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class OnboardingScreen extends StatefulWidget {
  final OnboardingService onboardingService;
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onboardingService,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Welcome to Fractal Forge',
      legacyTitle: 'Welcome to Flutter Fractals',
      description:
          'Explore infinite mathematical beauty through interactive fractals designed for discovery and learning.',
      icon: Icons.auto_awesome_rounded,
      highlightItems: [
        'Discover structure, recursion, and emergent patterns.',
        'Navigate from simple sets to complex chaotic systems.',
      ],
    ),
    _OnboardingPageData(
      title: '200+ Fractals',
      legacyTitle: 'Discover Fractal Types',
      description:
          'Browse a large catalog with Mandelbrot family sets, Newton fractals, strange attractors, and more.',
      icon: Icons.category_rounded,
      highlightItems: [
        'Mandelbrot',
        'Julia',
        'Newton fractals and root-finding maps',
        'Strange attractors and dynamic systems',
      ],
    ),
    _OnboardingPageData(
      title: 'Touch to Explore',
      legacyTitle: 'Intuitive Controls',
      description:
          'Use intuitive gestures to navigate the complex plane and examine local structure with precision.',
      icon: Icons.gesture_rounded,
      highlightItems: [
        'Pan',
        'Zoom',
        'Pinch to zoom into mathematical detail',
        'Drag to pan across regions quickly',
        'Auto-pilot mode for guided exploration',
      ],
    ),
    _OnboardingPageData(
      title: 'Share Your Discoveries',
      legacyTitle: 'Powerful Features',
      description:
          'Export high-resolution images and share the patterns you discover with students, colleagues, and friends.',
      icon: Icons.ios_share_rounded,
      highlightItems: [
        'Presets',
        'Export',
        'AR Mode',
        'Export renders for presentations and study',
        'Share directly to social apps and messaging',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.onboardingService.completeOnboarding();
    if (mounted) widget.onComplete();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.slow,
        curve: AppAnimations.smoothCurve,
      );
      return;
    }
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _pages.length,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(100),
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.primary,
                    ),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        l10n.onboardingSkip,
                        semanticsLabel: 'Skip onboarding',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: List.generate(_pages.length, (index) {
                        final selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: AppAnimations.normal,
                          curve: AppAnimations.defaultCurve,
                          width: selected ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                selected ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(isLastPage
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded),
                    label: Text(isLastPage
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String? legacyTitle;
  final String description;
  final IconData icon;
  final List<String> highlightItems;

  const _OnboardingPageData({
    required this.title,
    this.legacyTitle,
    required this.description,
    required this.icon,
    required this.highlightItems,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: '${data.title} section',
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(data.icon, color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            data.title,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          if (data.legacyTitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.legacyTitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: ListView.separated(
              itemCount: data.highlightItems.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = data.highlightItems[index];
                return Semantics(
                  label: item,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border:
                          Border.all(color: AppColors.border.withOpacity(0.7)),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
