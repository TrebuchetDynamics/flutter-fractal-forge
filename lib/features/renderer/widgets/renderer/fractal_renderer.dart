import 'dart:collection';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/shaders/shader_load_epoch.dart';
import 'package:flutter_fractals/core/shaders/shader_resource_cache.dart';
import 'package:flutter_fractals/core/services/diagnostics/crash_reporter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';
import 'package:flutter_fractals/core/services/diagnostics/app_logger_service.dart';
import 'package:flutter_fractals/core/services/platform/runtime_mode_service.dart';
import '../../cpu/cpu_fractal_renderer.dart';
import '../../models/fractal_render_snapshot.dart';
import 'input/gesture_view_bounds.dart';
import 'input/gesture_tap_classification.dart';
import '../../palette_transition.dart';
import '../../renderer_ticker_policy.dart';
import '../../policy/precision_ladder_policy.dart';
import '../../policy/render_plan.dart';
import '../canvas/fractal_canvas.dart';
import '../effects/fluid_warp_effect.dart';
import 'shaders/shader_error_policy.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

export 'shaders/shader_error_policy.dart' show ShaderErrorType;

part 'input/gesture_handler.dart';
part 'shaders/shader_loader.dart';
part 'errors/shader_error_display.dart';

final ShaderResourceCache<ui.FragmentShader> _rendererShaderCache =
    ShaderResourceCache<ui.FragmentShader>(
  maximumSize: 24,
  disposeResource: (shader) => shader.dispose(),
);

class GpuIterationPolicy {
  static const int webMaxGpuIterations = 160;
  static const int mobileMaxGpuIterations = 160;

  const GpuIterationPolicy._();

  static int effectiveGpuIterations({
    required int scaledIterations,
    required bool isWeb,
    required bool isMobile,
    required bool playwrightSmoke,
    required int playwrightSmokeMaxGpuIterations,
  }) {
    if (playwrightSmoke) {
      return math.min(
        scaledIterations,
        math.max(4, playwrightSmokeMaxGpuIterations),
      );
    }
    if (isWeb) {
      return math.min(scaledIterations, webMaxGpuIterations);
    }
    if (isMobile) {
      return math.min(scaledIterations, mobileMaxGpuIterations);
    }
    return scaledIterations;
  }
}

/// A widget that renders fractals using GPU-accelerated shaders.
///
/// [FractalRenderer] is the core rendering component of the app. It:
/// - Loads and compiles GLSL fragment shaders dynamically
/// - Renders fractals at 60 FPS using [CustomPainter]
/// - Handles gesture input (pan, zoom, rotate)
/// - Adapts to the current [FractalController] state
///
/// The renderer requires a [FractalController] to be available via Provider.
/// It automatically loads the appropriate shader when the module changes.
///
/// ## Gesture Support
///
/// - **Single-finger drag**: Pan (2D) or rotate (3D)
/// - **Pinch-to-zoom**: Smooth zoom with momentum/inertia
/// - **Two-finger rotation**: Rotate around Z-axis (3D fractals)
/// - **Double-tap**: Reset view to default
/// - **Long-press**: Show context menu
///
/// {@category Rendering}
///
/// Example:
/// ```dart
/// ChangeNotifierProvider.value(
///   value: myController,
///   child: FractalRenderer(
///     boundaryKey: _captureKey,
///     gesturesEnabled: true,
///   ),
/// )
/// ```
class FractalRenderer extends StatefulWidget {
  /// Current reusable shader cache health, exposed for diagnostics and tests.
  static ShaderCacheMetrics get shaderCacheMetrics =>
      _rendererShaderCache.metrics;

  /// Releases idle GPU shader instances after an OS low-memory notification.
  ///
  /// Instances leased by an actively painting renderer are retired when that
  /// renderer next releases them, never while they may still be on a canvas.
  static void clearShaderCacheForMemoryPressure() {
    _ShaderLoaderMixin.clearProgramCache();
    _rendererShaderCache.clear(ShaderCacheClearReason.memoryPressure);
  }

  /// Optional key for a [RepaintBoundary] that wraps the renderer.
  ///
  /// When provided, can be used to capture the rendered fractal
  /// as an image for export or thumbnail generation.
  final GlobalKey? boundaryKey;

  /// Whether gesture input (pan, zoom, rotate) is enabled.
  ///
  /// Set to false to display a non-interactive fractal view.
  /// Defaults to true.
  final bool gesturesEnabled;

  /// Callback for when controls should be opened.
  final VoidCallback? onOpenControls;

  /// Callback for when presets should be opened.
  final VoidCallback? onOpenPresets;

  /// Callback for when export should be opened.
  final VoidCallback? onOpenExport;

  /// One-shot callback for user corrections (mouse wheel, keyboard-triggered
  /// zoom, double-tap, etc).
  final VoidCallback? onUserInteraction;

  /// Called when the user starts a continuous gesture (drag/pinch).
  final VoidCallback? onUserInteractionStart;

  /// Called when the user ends a continuous gesture (drag/pinch).
  final VoidCallback? onUserInteractionEnd;

  /// Whether time-based animation should advance.
  ///
  /// When false, rendering uses a fixed time (frame is frozen).
  final bool animationEnabled;

  /// Optional child override that keeps full gesture handling while
  /// replacing the visual renderer content.
  final Widget? overrideChild;

  /// Optional render plan supplied by the viewer.
  ///
  /// When absent, the renderer computes the pure immediate decision itself.
  final RendererPlan? renderPlan;

  /// Whether to show backend/high-precision badges over the rendered image.
  final bool showRendererIndicator;

  /// Stable sink for the effective base-field state used by visible GPU frames.
  final FractalRenderSnapshotSink? renderSnapshotSink;

  /// Creates a [FractalRenderer] widget.
  const FractalRenderer({
    Key? key,
    this.boundaryKey,
    this.gesturesEnabled = true,
    this.onOpenControls,
    this.onOpenPresets,
    this.onOpenExport,
    this.onUserInteraction,
    this.onUserInteractionStart,
    this.onUserInteractionEnd,
    this.animationEnabled = true,
    this.overrideChild,
    this.renderPlan,
    this.showRendererIndicator = true,
    this.renderSnapshotSink,
  }) : super(key: key);

  @override
  State<FractalRenderer> createState() => _FractalRendererState();
}

class _FractalRendererState extends State<FractalRenderer>
    with
        TickerProviderStateMixin<FractalRenderer>,
        _GestureHandlerMixin,
        _ShaderLoaderMixin {
  static const PrecisionLadderPolicy _precisionLadderPolicy =
      PrecisionLadderPolicy();

  bool get _isAutomatedTest => RuntimeModeService.isAutomatedTest;

  bool get _usePlaceholderSurface =>
      RuntimeModeService.useRendererPlaceholderSurface;

  late AnimationController _animationController;
  final RendererPlanModuleResolver _moduleResolver =
      RendererPlanModuleResolver();

  // Frame metrics for sampled performance logging.
  int _gpuFrameCount = 0;
  DateTime? _gpuLastFrameAt;
  FractalController? _gestureController;
  String? _lastGestureModuleId;
  final PaletteTransition _paletteTransition = PaletteTransition();
  bool _tickerSyncScheduled = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    );
  }

  void _syncAnimationTicker({
    required FractalModule module,
    required FractalController controller,
    required bool paletteTransitionActive,
  }) {
    final shouldTick = !_isAutomatedTest &&
        RendererTickerPolicy.shouldTick(
          animationEnabled: widget.animationEnabled,
          moduleUsesTime: module.animationCapability ==
              FractalAnimationCapability.timeDriven,
          fluidEffectActive: controller.fluidModeEnabled,
          paletteTransitionActive: paletteTransitionActive,
          morphTransitionActive: controller.isMorphing,
          celebrationActive: controller.isCelebrating,
        );
    if (shouldTick) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
      return;
    }
    _stopAnimationTicker(reset: !widget.animationEnabled);
  }

  void _stopAnimationTicker({bool reset = false}) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    if (reset && _animationController.value != 0.0) {
      _animationController.value = 0.0;
    }
  }

  void _scheduleTickerSync({
    required FractalModule module,
    required FractalController controller,
  }) {
    if (_tickerSyncScheduled) return;
    _tickerSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tickerSyncScheduled = false;
      if (!mounted) return;
      _syncAnimationTicker(
        module: module,
        controller: controller,
        paletteTransitionActive: _paletteTransition.isActiveAt(DateTime.now()),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<FractalController>();
    if (_gestureController == controller) return;
    _gestureController?.removeListener(_handleControllerModuleChange);
    _gestureController = controller;
    _lastGestureModuleId = controller.module.id;
    controller.addListener(_handleControllerModuleChange);
  }

  void _handleControllerModuleChange() {
    final controller = _gestureController;
    if (controller == null) return;
    final moduleId = controller.module.id;
    if (_lastGestureModuleId != null && _lastGestureModuleId != moduleId) {
      _stopGestureAnimations();
    }
    _lastGestureModuleId = moduleId;
  }

  @override
  void dispose() {
    _gestureController?.removeListener(_handleControllerModuleChange);
    _animationController.dispose();
    super.dispose();
  }

  /// Wraps [content] with gesture detection when [widget.gesturesEnabled] is
  /// true. The optional [onTapUp] callback is forwarded to [GestureDetector]
  /// for module-specific tap handling (e.g. julia_dual).
  Widget _wrapWithGestures(Widget content, {GestureTapUpCallback? onTapUp}) {
    if (!widget.gesturesEnabled) return content;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n?.semanticFractalCanvas ?? 'Interactive fractal canvas',
      image: true,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerHover: _onPointerHover,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerUp,
        onPointerSignal: _onPointerSignal,
        child: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: _onDoubleTapGesture,
          onLongPressStart: _onLongPress,
          onSecondaryTapUp: _onSecondaryTap,
          onTapUp: onTapUp,
          child: content,
        ),
      ),
    );
  }

  Widget _withRendererIndicator({
    required Widget child,
    required String mode,
    required bool highPrecisionActive,
  }) {
    if (!widget.showRendererIndicator || !highPrecisionActive) return child;
    final highPrecisionLabel = mode == 'CPU' ? 'High precision (CPU)' : mode;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 12,
          top: 12,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                highPrecisionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FractalController>();
    final module = controller.module;

    // Widget tests run on a stripped-down engine that doesn't support GPU shaders.
    // Provide a lightweight placeholder surface so gesture + UI behavior can be
    // exercised in CI without a device/emulator.
    if (_usePlaceholderSurface) {
      _stopAnimationTicker(reset: !widget.animationEnabled);
      final content = RepaintBoundary(
        key: widget.boundaryKey,
        child: const SizedBox.expand(
          child: ColoredBox(
            key: Key('fractalTestSurface'),
            color: Colors.black,
          ),
        ),
      );
      return _wrapWithGestures(content);
    }

    if (widget.overrideChild != null) {
      _stopAnimationTicker(reset: !widget.animationEnabled);
      return _wrapWithGestures(widget.overrideChild!);
    }

    final renderPlan = widget.renderPlan ??
        RendererPlan.gpu(
          _precisionLadderPolicy.decide(
            moduleId: module.id,
            dimension: module.dimension,
            zoom: controller.view.zoom,
          ),
        );
    final precisionDecision = renderPlan.precision;

    if (precisionDecision.usesCpuRenderer &&
        module.dimension == FractalDimension.twoD) {
      _stopAnimationTicker(reset: !widget.animationEnabled);
      final cpuContent = _withRendererIndicator(
        mode: 'CPU',
        highPrecisionActive: true,
        child: RepaintBoundary(
          key: widget.boundaryKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dpr = kIsWeb
                  ? 1.0
                  : MediaQuery.of(context).devicePixelRatio.clamp(1.0, 2.0);
              // CPU renderer internal resolution:
              // - Preview/refine logic will further downscale while interacting.
              // - Web browsers already pay CanvasKit/compositor overhead; avoid
              //   high-DPI CPU fallbacks there.
              // - Keep a cap to avoid blowing up render cost on high-DPI screens.
              final w = (constraints.maxWidth * dpr).round().clamp(320, 900);
              final h = (constraints.maxHeight * dpr).round().clamp(320, 900);
              return CpuFractalRenderer(
                module: module,
                state: FractalRenderState(
                  params: controller.params,
                  view: controller.view,
                  transparentBackground: controller.transparentBackground,
                ),
                width: w,
                height: h,
              );
            },
          ),
        ),
      );
      return _wrapWithGestures(cpuContent);
    }

    final effectiveModule = _moduleResolver.resolve(
      plan: renderPlan,
      module: module,
    );

    // Check if we need to load a new shader. The previous module's snapshot
    // must not be replayed while this asset is loading; retaining the displayed
    // spectrum is truthful, but resubmitting stale pixels as current is not.
    if (_shaderAsset != effectiveModule.shaderAsset) {
      widget.renderSnapshotSink?.snapshot = null;
      if (!_loading) _loadShader(effectiveModule.shaderAsset);
    }

    // Show error if shader failed to load
    if (_shaderError != null) {
      _stopAnimationTicker(reset: !widget.animationEnabled);
      return _ShaderErrorDisplay(
        errorMessage: _shaderError!,
        errorDetails: _shaderErrorDetails,
        errorType: _shaderErrorType,
        retryCount: _shaderRetryCount,
        maxRetries: _ShaderLoaderMixin._maxShaderRetries,
        onRetry: _retryShaderLoad,
        onGoBack: () => Navigator.of(context).maybePop(),
      );
    }

    // Wait for shader to load before rendering
    // This prevents race condition where shader is used before it's ready
    if (_program == null || _loading) {
      _stopAnimationTicker(reset: !widget.animationEnabled);
      if (!widget.showRendererIndicator) return const SizedBox.expand();
      final l10n = AppLocalizations.of(context);
      return Center(
        child: FractalLoadingIndicator(
          size: 80,
          message: l10n?.loadingShaders ?? 'Loading shaders…',
        ),
      );
    }

    final controllerParams = controller.params;
    final controllerView = controller.view;
    final baseIterations =
        (controllerParams['iterations'] as num?)?.toInt() ?? 160;
    final scaledIterations = _precisionLadderPolicy.scaledGpuIterations(
      baseIterations: baseIterations,
      zoom: controllerView.zoom,
    );
    final effectiveIterations = GpuIterationPolicy.effectiveGpuIterations(
      scaledIterations: scaledIterations,
      isWeb: kIsWeb,
      isMobile: !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS),
      playwrightSmoke: RuntimeModeService.playwrightCatalogSmoke,
      playwrightSmokeMaxGpuIterations:
          RuntimeModeService.playwrightCatalogSmokeMaxGpuIterations,
    );
    final gpuParams = Map<String, Object>.from(controllerParams)
      ..['iterations'] = effectiveIterations;
    var hasColorParam = false;
    var colorMin = 0.0;
    var colorMax = 0.0;
    for (final param in module.parameters) {
      if (param.id == 'colorScheme') {
        hasColorParam = true;
        colorMin = param.min;
        colorMax = param.max;
        break;
      }
    }

    final paletteTransitionActive = hasColorParam &&
        widget.animationEnabled &&
        (_paletteTransition.wouldAnimateTo(controllerParams['colorScheme']) ||
            _paletteTransition.isActiveAt(DateTime.now()));
    _syncAnimationTicker(
      module: module,
      controller: controller,
      paletteTransitionActive: paletteTransitionActive,
    );

    final staticRenderState = hasColorParam
        ? null
        : FractalRenderState(
            params: gpuParams,
            view: controllerView,
            transparentBackground: controller.transparentBackground,
          );

    // Create the base fractal content. Keep stable controller-derived values
    // outside the animation tick closure; render-only palette lerp is per frame.
    Widget fractalContent = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final now = DateTime.now();
          if (!_firstFrameLogged) {
            _firstFrameLogged = true;
            final dt =
                now.difference(_shaderLoadStartedAt ?? now).inMilliseconds;
            if (kDebugMode) {
              AppLogger.instance.debug('perf', 'gpu_first_frame', data: {
                'first_frame_ms': dt,
                'module': controller.module.id,
                'backend': 'gpu',
              });
            }
            if (RuntimeModeService.playwrightCatalogSmoke) {
              print(
                  'PLAYWRIGHT_CATALOG_SMOKE_FIRST_FRAME:${controller.module.id}');
            }
          }

          // Sampled frame-time logging: measure and log every 10th GPU frame.
          _gpuFrameCount++;
          final prev = _gpuLastFrameAt;
          _gpuLastFrameAt = now;
          if (kDebugMode && _gpuFrameCount % 60 == 0 && prev != null) {
            final frameMs = now.difference(prev).inMicroseconds / 1000.0;
            AppLogger.instance.debug('perf', 'gpu_frame', data: {
              'frame_ms': frameMs.toStringAsFixed(2),
              'frame': _gpuFrameCount,
              'module': controller.module.id,
            });
          }

          final renderState = staticRenderState ??
              FractalRenderState(
                params: Map<String, Object>.from(gpuParams)
                  ..['colorScheme'] = _paletteTransition.valueFor(
                    target: controllerParams['colorScheme'],
                    now: now,
                    min: colorMin,
                    max: colorMax,
                    animate: widget.animationEnabled && !_isAutomatedTest,
                  ),
                view: controllerView,
                transparentBackground: controller.transparentBackground,
              );

          if (paletteTransitionActive &&
              !_paletteTransition.isActiveAt(now) &&
              !_paletteTransition.wouldAnimateTo(
                controllerParams['colorScheme'],
              )) {
            _scheduleTickerSync(module: module, controller: controller);
          }

          final frameTime = _animationController.value * 1000.0;
          final snapshotSink = widget.renderSnapshotSink;
          if (snapshotSink != null) {
            snapshotSink.snapshot = FractalRenderSnapshot(
              module: effectiveModule,
              state: renderState,
              time: frameTime,
              glowEnabled: controller.glowEnabled,
              glowSigma: controller.glowSigma,
              glowIntensity: controller.glowIntensity,
              kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
              kaleidoscopeSectors: controller.kaleidoscopeSectors,
              kaleidoscopeMirror: controller.kaleidoscopeMirror,
              kaleidoscopeRotation: controller.kaleidoscopeRotation,
              kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
            );
          }
          final paint = CustomPaint(
            painter: FractalCanvas(
              module: effectiveModule,
              state: renderState,
              time: frameTime,
              shader: _currentFragmentShader(_program!),
              glowEnabled: controller.glowEnabled,
              glowSigma: controller.glowSigma,
              glowIntensity: controller.glowIntensity,
              kaleidoscopeEnabled: controller.kaleidoscopeEnabled,
              kaleidoscopeSectors: controller.kaleidoscopeSectors,
              kaleidoscopeMirror: controller.kaleidoscopeMirror,
              kaleidoscopeRotation: controller.kaleidoscopeRotation,
              kaleidoscopeMirrorMode: controller.kaleidoscopeMirrorMode,
            ),
            child: const SizedBox.shrink(),
          );

          return FluidWarpEffect(
            enabled: controller.fluidModeEnabled,
            strength: controller.fluidStrength,
            time: frameTime,
            touchPosition: _fluidPointerLocal,
            touchVelocity: _fluidPointerVelocity,
            secondaryTouchPosition: _fluidSecondaryPointer,
            secondaryTouchActive: _fluidSecondaryActive,
            touchActive: _fluidPointerActive,
            child: paint,
          );
        },
      ),
    );

    // Wrap with morph transition effect
    if (controller.isMorphing) {
      fractalContent = FractalMorphTransition(
        currentFractalType: controller.module.id,
        child: fractalContent,
      );
    }

    // Wrap with celebration effect
    fractalContent = CelebrationEffect(
      isActive: controller.isCelebrating,
      child: fractalContent,
    );

    final content = _withRendererIndicator(
      mode: precisionDecision.statusLabel,
      highPrecisionActive: precisionDecision.usesExtendedGpu,
      child: RepaintBoundary(
        key: widget.boundaryKey,
        child: fractalContent,
      ),
    );

    return _wrapWithGestures(
      content,
      onTapUp: (module.id == 'julia_dual')
          ? (details) {
              _onJuliaDualTap(details.localPosition, controller);
            }
          : null,
    );
  }
}
