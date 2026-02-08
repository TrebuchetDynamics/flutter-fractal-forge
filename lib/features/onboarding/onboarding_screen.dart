import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/services/onboarding_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

/// Onboarding screen shown to first-time users.
///
/// Presents the key features of the app in a paginated view:
/// - Welcome and app overview
/// - Fractal types available
/// - Gesture controls
/// - Key features (presets, export, AR)
class OnboardingScreen extends StatefulWidget {
  /// Service to mark onboarding as complete.
  final OnboardingService onboardingService;

  /// Callback when onboarding is completed.
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onboardingService,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.onboardingService.completeOnboarding();
    widget.onComplete();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: AppAnimations.normal,
        curve: AppAnimations.defaultCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    l10n.onboardingSkip,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _WelcomePage(l10n: l10n),
                  _FractalTypesPage(l10n: l10n),
                  _GesturesPage(l10n: l10n),
                  _FeaturesPage(l10n: l10n),
                ],
              ),
            ),

            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: AppAnimations.fast,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next/Get Started button
                  _PrimaryButton(
                    onPressed: _nextPage,
                    label: _currentPage == 3
                        ? l10n.onboardingGetStarted
                        : l10n.onboardingNext,
                    isLast: _currentPage == 3,
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

class _PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLast;

  const _PrimaryButton({
    required this.onPressed,
    required this.label,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isLast ? AppColors.primaryGradient : null,
        color: isLast ? null : AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        boxShadow: isLast
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLast ? AppSpacing.xxl : AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isLast) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Welcome page introducing the app.
class _WelcomePage extends StatelessWidget {
  final AppLocalizations l10n;

  const _WelcomePage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      iconGradient: AppColors.accentGradient,
      title: l10n.onboardingWelcomeTitle,
      description: l10n.onboardingWelcomeDescription,
      child: _AnimatedFractalPreview(),
    );
  }
}

/// Page showcasing different fractal types.
class _FractalTypesPage extends StatelessWidget {
  final AppLocalizations l10n;

  const _FractalTypesPage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      icon: Icons.category_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF7C4DFF)],
      ),
      title: l10n.onboardingFractalTypesTitle,
      description: l10n.onboardingFractalTypesDescription,
      child: _FractalTypesGrid(l10n: l10n),
    );
  }
}

/// Page explaining gesture controls.
class _GesturesPage extends StatelessWidget {
  final AppLocalizations l10n;

  const _GesturesPage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      icon: Icons.touch_app_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
      ),
      title: l10n.onboardingGesturesTitle,
      description: l10n.onboardingGesturesDescription,
      child: _GesturesList(l10n: l10n),
    );
  }
}

/// Page showcasing key features.
class _FeaturesPage extends StatelessWidget {
  final AppLocalizations l10n;

  const _FeaturesPage({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      icon: Icons.rocket_launch_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
      ),
      title: l10n.onboardingFeaturesTitle,
      description: l10n.onboardingFeaturesDescription,
      child: _FeaturesList(l10n: l10n),
    );
  }
}

/// Base layout for onboarding pages.
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String description;
  final Widget child;

  const _OnboardingPage({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          // Icon with gradient background
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            title,
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          Text(
            description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Custom content
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Animated fractal preview for welcome page.
class _AnimatedFractalPreview extends StatefulWidget {
  @override
  State<_AnimatedFractalPreview> createState() => _AnimatedFractalPreviewState();
}

class _AnimatedFractalPreviewState extends State<_AnimatedFractalPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.2),
              ],
              transform: GradientRotation(_controller.value * 6.28),
            ),
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: Stack(
              children: [
                // Animated gradient overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FractalPatternPainter(
                      progress: _controller.value,
                    ),
                  ),
                ),
                // Center icon
                Center(
                  child: Icon(
                    Icons.blur_circular_rounded,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.7),
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

/// Custom painter for animated fractal-like pattern.
class _FractalPatternPainter extends CustomPainter {
  final double progress;

  _FractalPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide / 2;

    for (int i = 0; i < 5; i++) {
      final radius = maxRadius * (0.3 + i * 0.15);
      final opacity = 0.1 + (i * 0.08);
      final rotation = progress * 3.14 * (i.isEven ? 1 : -1);

      final paint = Paint()
        ..color = AppColors.primary.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);

      canvas.drawCircle(center, radius, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FractalPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Grid showing available fractal types.
class _FractalTypesGrid extends StatelessWidget {
  final AppLocalizations l10n;

  const _FractalTypesGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final fractals = [
      _FractalTypeInfo(
        name: l10n.moduleMandelbrot,
        dimension: l10n.dimension2d,
        icon: Icons.filter_vintage_rounded,
        color: const Color(0xFF7C4DFF),
      ),
      _FractalTypeInfo(
        name: l10n.moduleJulia,
        dimension: l10n.dimension2d,
        icon: Icons.blur_on_rounded,
        color: const Color(0xFF00BCD4),
      ),
      _FractalTypeInfo(
        name: l10n.moduleBurningShip,
        dimension: l10n.dimension2d,
        icon: Icons.sailing_rounded,
        color: const Color(0xFFFF6B6B),
      ),
      _FractalTypeInfo(
        name: l10n.modulePhoenix,
        dimension: l10n.dimension2d,
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFFB74D),
      ),
      _FractalTypeInfo(
        name: l10n.moduleMandelbulb,
        dimension: l10n.dimension3d,
        icon: Icons.view_in_ar_rounded,
        color: const Color(0xFFE040FB),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
      ),
      itemCount: fractals.length,
      itemBuilder: (context, index) {
        final fractal = fractals[index];
        return _FractalTypeCard(info: fractal);
      },
    );
  }
}

class _FractalTypeInfo {
  final String name;
  final String dimension;
  final IconData icon;
  final Color color;

  const _FractalTypeInfo({
    required this.name,
    required this.dimension,
    required this.icon,
    required this.color,
  });
}

class _FractalTypeCard extends StatelessWidget {
  final _FractalTypeInfo info;

  const _FractalTypeCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: info.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            info.icon,
            size: 28,
            color: info.color,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            info.name,
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            info.dimension,
            style: AppTypography.labelSmall.copyWith(
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// List of gesture controls.
class _GesturesList extends StatelessWidget {
  final AppLocalizations l10n;

  const _GesturesList({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final gestures = [
      _GestureInfo(
        icon: Icons.pan_tool_rounded,
        title: l10n.onboardingGesturePan,
        description: l10n.onboardingGesturePanDesc,
      ),
      _GestureInfo(
        icon: Icons.pinch_rounded,
        title: l10n.onboardingGestureZoom,
        description: l10n.onboardingGestureZoomDesc,
      ),
      _GestureInfo(
        icon: Icons.rotate_right_rounded,
        title: l10n.onboardingGestureRotate,
        description: l10n.onboardingGestureRotateDesc,
      ),
      _GestureInfo(
        icon: Icons.touch_app_rounded,
        title: l10n.onboardingGestureDoubleTap,
        description: l10n.onboardingGestureDoubleTapDesc,
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gestures.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final gesture = gestures[index];
        return _GestureCard(info: gesture);
      },
    );
  }
}

class _GestureInfo {
  final IconData icon;
  final String title;
  final String description;

  const _GestureInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _GestureCard extends StatelessWidget {
  final _GestureInfo info;

  const _GestureCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              info.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: AppTypography.titleMedium,
                ),
                Text(
                  info.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// List of key features.
class _FeaturesList extends StatelessWidget {
  final AppLocalizations l10n;

  const _FeaturesList({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureInfo(
        icon: Icons.tune_rounded,
        title: l10n.onboardingFeaturePresets,
        description: l10n.onboardingFeaturePresetsDesc,
        color: const Color(0xFF7C4DFF),
      ),
      _FeatureInfo(
        icon: Icons.download_rounded,
        title: l10n.onboardingFeatureExport,
        description: l10n.onboardingFeatureExportDesc,
        color: const Color(0xFF00BCD4),
      ),
      _FeatureInfo(
        icon: Icons.camera_rounded,
        title: l10n.onboardingFeatureAr,
        description: l10n.onboardingFeatureArDesc,
        color: const Color(0xFFE040FB),
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final feature = features[index];
        return _FeatureCard(info: feature);
      },
    );
  }
}

class _FeatureInfo {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureInfo({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureInfo info;

  const _FeatureCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            info.color.withOpacity(0.15),
            info.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: info.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: info.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              info.icon,
              color: info.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: AppTypography.titleMedium,
                ),
                Text(
                  info.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
