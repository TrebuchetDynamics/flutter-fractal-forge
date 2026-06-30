import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/storage/onboarding_service.dart';
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
  // Page count is fixed at 2; updated lazily when l10n pages are built.
  int _pageCount = 2;

  List<_OnboardingPageData> _buildPages(AppLocalizations l10n) => [
        _OnboardingPageData(
          title: l10n.onboardingWelcomeTitle,
          description: l10n.onboardingWelcomeDescription,
          icon: Icons.auto_awesome_rounded,
          highlightItems: [
            l10n.onboardingWelcomeHighlight1,
            l10n.onboardingWelcomeHighlight2,
            l10n.onboardingWelcomeHighlight3,
          ],
        ),
        _OnboardingPageData(
          title: l10n.onboardingCreateTitle,
          description: l10n.onboardingCreateDescription,
          icon: Icons.ios_share_rounded,
          highlightItems: [
            l10n.onboardingCreateHighlight1,
            l10n.onboardingCreateHighlight2,
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
    if (_currentPage < _pageCount - 1) {
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
    final pages = _buildPages(l10n);
    _pageCount = pages.length;
    final isLastPage = _currentPage == pages.length - 1;

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
                    child: Semantics(
                      label: l10n.semanticOnboardingProgress(
                        _currentPage + 1,
                        pages.length,
                      ),
                      value:
                          '${((_currentPage + 1) / pages.length * 100).round()}%',
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / pages.length,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(100),
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        l10n.onboardingSkip,
                        semanticsLabel: l10n.semanticSkipOnboarding,
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
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: pages[index]),
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
                      children: List.generate(pages.length, (index) {
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
  final String description;
  final IconData icon;
  final List<String> highlightItems;

  const _OnboardingPageData({
    required this.title,
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
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return _buildLandscape(context);
        }
        return _buildPortrait(context);
      },
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildIcon(),
          const SizedBox(height: AppSpacing.xl),
          _buildTitle(),
          const SizedBox(height: AppSpacing.md),
          _buildDescription(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _buildHighlightList()),
        ],
      ),
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: _buildIcon(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                const SizedBox(height: AppSpacing.sm),
                _buildDescription(),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _buildHighlightList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Semantics(
      label: '${data.title} section',
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(data.icon, color: Colors.white, size: 34),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      data.title,
      style: AppTypography.displayMedium.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      data.description,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildHighlightList() {
    return ListView.separated(
      itemCount: data.highlightItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = data.highlightItems[index];
        return Semantics(
          label: item,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border:
                  Border.all(color: AppColors.border.withValues(alpha: 0.7)),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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
    );
  }
}
