import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/platform/deep_link_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/features/catalog/fractal_catalog_screen.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/features/viewer/fractal_viewer_screen.dart';
import 'package:flutter_fractals/features/settings/settings_screen.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

const int kSafeMode = int.fromEnvironment('SAFE_MODE', defaultValue: 0);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final ModuleRegistry _registry;
  late final FractalController _exploreController;
  late final CatalogToolbarController _catalogToolbarController;

  StreamSubscription<DeepLinkData>? _deepLinkSubscription;
  bool _handledInitialLink = false;
  bool _handledPlaywrightSmokeModule = false;

  @override
  void initState() {
    super.initState();
    _registry = context.read<ModuleRegistry>();
    _exploreController = FractalController(_registry);
    _catalogToolbarController = CatalogToolbarController();

    // Set up deep link handling (skip in SAFE_MODE)
    if (kSafeMode == 0) {
      _initDeepLinks();
      _initBrowserDeepLink();
    }

    if (RuntimeModeService.playwrightCatalogSmoke) {
      _initPlaywrightCatalogSmoke();
    }
  }

  @override
  void dispose() {
    _exploreController.dispose();
    _catalogToolbarController.dispose();
    _deepLinkSubscription?.cancel();
    super.dispose();
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
      if (!mounted) return;
      if (!_handledInitialLink && deepLinkService?.initialLink != null) {
        _handledInitialLink = true;
        _handleDeepLink(deepLinkService!.initialLink!);
      }
    });

    // Listen for incoming deep links while the app is running
    _deepLinkSubscription = deepLinkService.linkStream.listen(_handleDeepLink);
  }

  void _initPlaywrightCatalogSmoke() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _handledPlaywrightSmokeModule) return;
      final moduleId = Uri.base.queryParameters['smokeModule'];
      if (moduleId == null || moduleId.isEmpty) return;
      _handledPlaywrightSmokeModule = true;
      _openSmokeModule(moduleId);
    });
  }

  void _initBrowserDeepLink() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _handledInitialLink) return;
      final data = DeepLinkService.parseUri(Uri.base);
      if (data == null) return;
      _handledInitialLink = true;
      _handleDeepLink(data);
    });
  }

  void _handleDeepLink(DeepLinkData data) {
    // Try to find the module by type
    try {
      final module = _registry.byId(data.type);

      _exploreController.loadState(
        module: module,
        params: data.toParams(),
        view: data.toViewState(),
        transparentBackground: data.transparentBackground ?? false,
        animateModule: false,
      );
      _applyDeepLinkVisualState(data);

      _pushViewer(transitionDuration: AppAnimations.normal);
    } catch (e) {
      // Module not found, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.homeUnknownFractalType(data.type)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _applyDeepLinkVisualState(DeepLinkData data) {
    if (data.rotationLocked != null) {
      _exploreController.setRotationLocked(data.rotationLocked!);
    }
    if (data.glowEnabled != null) {
      _exploreController.setGlowEnabled(data.glowEnabled!);
    }
    if (data.glowSigma != null) {
      _exploreController.setGlowSigma(data.glowSigma!);
    }
    if (data.glowIntensity != null) {
      _exploreController.setGlowIntensity(data.glowIntensity!);
    }
    if (data.kaleidoscopeEnabled != null) {
      _exploreController.setKaleidoscopeEnabled(data.kaleidoscopeEnabled!);
    }
    if (data.kaleidoscopeSectors != null) {
      _exploreController.setKaleidoscopeSectors(data.kaleidoscopeSectors!);
    }
    if (data.kaleidoscopeMirror != null) {
      _exploreController.setKaleidoscopeMirror(data.kaleidoscopeMirror!);
    }
    if (data.kaleidoscopeRotation != null) {
      _exploreController.setKaleidoscopeRotation(data.kaleidoscopeRotation!);
    }
    if (data.kaleidoscopeMirrorMode != null) {
      _exploreController.setKaleidoscopeMirrorMode(
        data.kaleidoscopeMirrorMode!,
      );
    }
  }

  void _openSmokeModule(String moduleId) {
    try {
      final module = _registry.byId(moduleId);
      final overrides = _smokeViewOverrides(moduleId);
      if (overrides != null) {
        // Apply curated framing/params from the query so launch-still captures
        // open on a deliberate view instead of the module default.
        _exploreController.loadState(
          module: module,
          params: overrides.toParams(),
          view: overrides.toViewState(),
          animateModule: false,
        );
      } else {
        _exploreController.selectModule(module, animate: false);
      }
      print('PLAYWRIGHT_CATALOG_SMOKE_OPENED:$moduleId');
      _pushViewer(
        transitionDuration: Duration.zero,
        captureMode: _smokeCaptureMode(),
      );
    } catch (e) {
      print('PLAYWRIGHT_CATALOG_SMOKE_UNKNOWN_MODULE:$moduleId');
      rethrow;
    }
  }

  /// Recognized deep-link view/param query keys (zoom, pan, rotation, render
  /// params). Presence of any of these in a `?smokeModule=` URL means the
  /// capture wants curated framing rather than the module's default.
  static const Set<String> _smokeOverrideKeys = {
    'zoom',
    'x',
    'y',
    'rotX',
    'rotY',
    'rotZ',
    'iterations',
    'bailout',
    'colorScheme',
    'power',
    'juliaX',
    'juliaY',
    'p',
  };

  /// Translates the current web query parameters into validated [DeepLinkData]
  /// for a smoke capture, reusing the deep-link bounds/validation. Returns null
  /// when no override keys are present (keep the module's default framing).
  DeepLinkData? _smokeViewOverrides(String moduleId) {
    final base = Uri.base.queryParameters;
    if (!base.keys.any(_smokeOverrideKeys.contains)) return null;
    final query = Map<String, String>.from(base)
      ..remove('smokeModule')
      ..['type'] = moduleId;
    final synthetic = Uri(
      scheme: DeepLinkService.scheme,
      host: DeepLinkService.host,
      queryParameters: query,
    );
    return DeepLinkService.parseUri(synthetic);
  }

  /// Whether the smoke capture should open chrome-free (`?capture=1`).
  bool _smokeCaptureMode() {
    final value = Uri.base.queryParameters['capture'];
    return value == '1' || value == 'true';
  }

  void _pushViewer({
    required Duration transitionDuration,
    bool captureMode = false,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _exploreController),
          ],
          child: FractalViewerScreen(captureMode: captureMode),
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
        transitionDuration: transitionDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final smokeModuleId = RuntimeModeService.playwrightCatalogSmoke
        ? Uri.base.queryParameters['smokeModule']
        : null;

    return Scaffold(
      extendBody: true,
      appBar: _PremiumAppBar(
        title: l10n.appTitle,
        catalogToolbarController: _catalogToolbarController,
        onSettingsTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      body: ChangeNotifierProvider.value(
        key: const ValueKey('explore'),
        value: _exploreController,
        child: smokeModuleId != null
            ? const SizedBox.expand()
            : Column(
                children: [
                  if (kSafeMode >= 1)
                    MaterialBanner(
                      backgroundColor:
                          AppColors.warning.withValues(alpha: 0.15),
                      content: Text(
                        'SAFE MODE: Shader rendering disabled for device crash triage.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.warning),
                      ),
                      actions: const [],
                    ),
                  Expanded(
                    child: Semantics(
                      label: 'Explore catalog',
                      child: FractalCatalogScreen(
                        toolbarController: _catalogToolbarController,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PremiumAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final CatalogToolbarController catalogToolbarController;
  final VoidCallback onSettingsTap;

  const _PremiumAppBar({
    required this.title,
    required this.catalogToolbarController,
    required this.onSettingsTap,
  });

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
                  // Logo + App name on the left
                  Positioned(
                    left: AppSpacing.lg,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/icon/logo_64.png',
                              cacheWidth: 64,
                              cacheHeight: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.blur_circular,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          widget.title,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.sm,
                    child: AnimatedBuilder(
                      animation: widget.catalogToolbarController,
                      builder: (context, _) {
                        final l10n = AppLocalizations.of(context)!;
                        final toolbar = widget.catalogToolbarController;
                        final showBadge =
                            MediaQuery.sizeOf(context).width >= 440;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showBadge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.28),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  l10n.homeFractalCountBadge,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            IconButton(
                              key: const Key('catalogSearchToggleButton'),
                              tooltip: l10n.catalogSearchHint,
                              style: IconButton.styleFrom(
                                foregroundColor: toolbar.isSearchVisible
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                backgroundColor: toolbar.isSearchVisible
                                    ? AppColors.primary.withValues(alpha: 0.16)
                                    : Colors.transparent,
                              ),
                              icon: const Icon(Icons.search_rounded, size: 20),
                              onPressed: toolbar.toggleSearch,
                            ),
                            IconButton(
                              key: const Key('catalogViewToggleButton'),
                              tooltip: switch (toolbar.viewMode) {
                                CatalogViewMode.grid =>
                                  l10n.catalogSwitchToList,
                                CatalogViewMode.list =>
                                  Localizations.localeOf(context)
                                              .languageCode ==
                                          'es'
                                      ? 'Cambiar a miniaturas'
                                      : 'Switch to miniatures',
                                CatalogViewMode.miniatures =>
                                  l10n.catalogSwitchToGrid,
                              },
                              icon: Icon(
                                switch (toolbar.viewMode) {
                                  CatalogViewMode.grid =>
                                    Icons.view_list_rounded,
                                  CatalogViewMode.list =>
                                    Icons.view_module_rounded,
                                  CatalogViewMode.miniatures =>
                                    Icons.grid_view_rounded,
                                },
                                size: 20,
                              ),
                              onPressed: toolbar.toggleViewMode,
                            ),
                            IconButton(
                              key: const ValueKey('homeSettingsButton'),
                              tooltip: l10n.tabSettings,
                              icon:
                                  const Icon(Icons.settings_rounded, size: 20),
                              onPressed: widget.onSettingsTap,
                            ),
                          ],
                        );
                      },
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
