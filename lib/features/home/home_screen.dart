import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/accessibility_service.dart';
import 'package:flutter_fractals/core/services/deep_link_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
// AR entry lives in FractalViewer; home no longer hosts AR tab.
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

const bool kSafeMode = bool.fromEnvironment('SAFE_MODE', defaultValue: false);

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
    // Keep controller state scoped per tab so AR-specific tweaks (quality presets,
    // transparent background) don't leak into the Explore/catalog/viewer flow.
    _exploreController = FractalController(registry);
    // Home no longer animates tab transitions.

    // Set up deep link handling (skip in SAFE_MODE)
    if (!kSafeMode) {
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
          content: Text('Unknown fractal type: ${data.type}'),
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

  // AR tab removed: AR entry is inside FractalViewer app bar.

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = AnimatedSwitcher(
      duration: AppAnimations.normal,
      switchInCurve: AppAnimations.defaultCurve,
      switchOutCurve: AppAnimations.defaultCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: ChangeNotifierProvider.value(
        key: const ValueKey('explore'),
        value: _exploreController,
        child: Column(
          children: [
            if (kSafeMode)
              MaterialBanner(
                backgroundColor: AppColors.warning.withOpacity(0.15),
                content: Text(
                  'SAFE MODE: AR & shader rendering disabled for device crash triage.',
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

class _PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const _PremiumAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(
                color: AppColors.border.withOpacity(0.3),
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: AppTypography.titleLarge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
    final color = widget.isSelected ? AppColors.primary : AppColors.textMuted;
    final anim = AppAnimations.of(context);
    
    // Check if we should reduce motion
    final reduceMotion = context.shouldReduceMotion ||
        (context.read<AccessibilityService?>()?.reducedMotionEnabled ?? false);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      selected: widget.isSelected,
      child: GestureDetector(
        onTapDown: reduceMotion ? null : (_) => _controller.forward(),
        onTapUp: reduceMotion ? null : (_) => _controller.reverse(),
        onTapCancel: reduceMotion ? null : () => _controller.reverse(),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: reduceMotion
            ? _buildContent(color, anim)
            : ScaleTransition(
                scale: _scaleAnimation,
                child: _buildContent(color, anim),
              ),
      ),
    );
  }

  Widget _buildContent(Color color, AccessibleAnimations anim) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: anim.normal,
            curve: anim.curve,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: anim.normal,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: widget.isSelected
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}
