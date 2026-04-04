import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

const int kSafeMode = int.fromEnvironment('SAFE_MODE', defaultValue: 0);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FractalController _exploreController;

  StreamSubscription<DeepLinkData>? _deepLinkSubscription;
  bool _handledInitialLink = false;

  @override
  void initState() {
    super.initState();
    final registry = context.read<ModuleRegistry>();
    _exploreController = FractalController(registry);

    // Set up deep link handling (skip in SAFE_MODE)
    if (kSafeMode == 0) {
      _initDeepLinks();
    }
  }

  void _initDeepLinks() {
    // Try to get the deep link service (may not exist in tests)
    DeepLinkService? deepLinkService;
    try {
      deepLinkService = context.read<DeepLinkService>();
    } catch (_) {
      // Deep link service not available
      return;
    }

    // Handle the initial link if the app was launched via deep link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_handledInitialLink && deepLinkService?.initialLink != null) {
        _handledInitialLink = true;
        _handleDeepLink(deepLinkService!.initialLink!);
      }
    });

    // Listen for incoming deep links while the app is running
    _deepLinkSubscription = deepLinkService.linkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(DeepLinkData data) {
    final registry = context.read<ModuleRegistry>();

    // Try to find the module by type
    try {
      final module = registry.byId(data.type);

      // Apply the configuration to the explore controller
      _exploreController.selectModule(module);

      // Apply view state from deep link
      final view = data.toViewState();
      _exploreController.updateZoom(view.zoom);
      _exploreController.updatePan(view.pan);
      _exploreController.updateRotation(view.rotation);

      // Apply fractal parameters
      final params = data.toParams();
      for (final entry in params.entries) {
        _exploreController.updateParam(entry.key, entry.value);
      }

      // Navigate to the viewer screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _exploreController),
            ],
            child: const FractalViewerScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: AppAnimations.defaultCurve,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
          transitionDuration: AppAnimations.normal,
        ),
      );
    } catch (e) {
      // Module not found, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.homeUnknownFractalType(data.type)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _exploreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = AnimatedSwitcher(
      duration: AppAnimations.normal,
      switchInCurve: AppAnimations.defaultCurve,
      switchOutCurve: AppAnimations.defaultCurve,
      transitionBuilder: (child, animation) {
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: ChangeNotifierProvider.value(
        key: const ValueKey('explore'),
        value: _exploreController,
        child: Column(
          children: [
            if (kSafeMode >= 1)
              MaterialBanner(
                backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                content: Text(
                  'SAFE MODE: Shader rendering disabled for device crash triage.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.warning),
                ),
                actions: const [],
              ),
            const Expanded(child: FractalCatalogScreen()),
          ],
        ),
      ),
    );

    return Scaffold(
      extendBody: true,
      appBar: _PremiumAppBar(title: l10n.catalogTitle),
      body: body,
      bottomNavigationBar: null,
    );
  }
}

class _PremiumAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const _PremiumAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<_PremiumAppBar> createState() => _PremiumAppBarState();
}

class _PremiumAppBarState extends State<_PremiumAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();
    _shimmerAnim = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (context, child) {
            // Shimmer sweeps left-to-right across the bottom border only.
            final sweep = _shimmerAnim.value;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.85),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              foregroundDecoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.lerp(
                      AppColors.border.withValues(alpha: 0.0),
                      AppColors.primaryLight.withValues(alpha: 0.55),
                      // Bell-curve brightness: peak at sweep == 0.5
                      (1.0 - (sweep - 0.5).abs() * 2.0).clamp(0.0, 1.0),
                    )!,
                    width: 1.0,
                  ),
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Title centred in bar
                  AnimatedSwitcher(
                    duration: AppAnimations.fast,
                    child: Text(
                      widget.title,
                      key: ValueKey(widget.title),
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  // "350+ fractals" badge — right-aligned
                  Positioned(
                    right: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.homeFractalCountBadge,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
