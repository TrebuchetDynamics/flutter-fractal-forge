import 'dart:collection';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/mandelbrot_df2_module.dart';
import 'package:flutter_fractals/core/modules/julia_perturb_module.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';
import 'package:flutter_fractals/core/services/app_logger_service.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import './providers/fractal_provider.dart';
import 'cpu_fractal_renderer.dart';
import 'deep_zoom_precision_policy.dart';
import 'fractal_canvas.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

part 'gesture_handler.dart';
part 'shader_loader.dart';
part 'fractal_painter.dart';

/// Types of shader errors for categorization and display.
enum ShaderErrorType {
  /// Shader code failed to compile on the GPU.
  compilation,

  /// The shader asset file was not found.
  assetNotFound,

  /// GPU ran out of memory.
  outOfMemory,

  /// GPU does not support required features.
  gpuUnsupported,

  /// Unknown or uncategorized error.
  unknown,
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
  }) : super(key: key);

  @override
  State<FractalRenderer> createState() => _FractalRendererState();
}

class _FractalRendererState extends State<FractalRenderer>
    with
        TickerProviderStateMixin<FractalRenderer>,
        _GestureHandlerMixin,
        _ShaderLoaderMixin {
  static const DeepZoomPrecisionPolicy _precisionPolicy =
      DeepZoomPrecisionPolicy();

  bool get _isAutomatedTest => RuntimeModeService.isAutomatedTest;

  bool get _usePlaceholderSurface =>
      RuntimeModeService.useRendererPlaceholderSurface;

  late AnimationController _animationController;
  FractalModule? _df2Module;
  FractalModule? _juliaPerturbModule;
  FractalModule? _escapeTimePerturbModule;
  String _escapeTimePerturbModuleId = '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    );

    // Avoid an always-running ticker in widget tests; it makes `pumpAndSettle`
    // time out.
    if (!_isAutomatedTest) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _withRendererIndicator({
    required Widget child,
    required String mode,
    required bool fallbackActive,
    required bool highPrecisionActive,
  }) {
    if (!kDebugMode && !highPrecisionActive) return child;

    return Stack(
      children: [
        Positioned.fill(child: child),

        // Ship-visible indicator: CPU == high precision path.
        if (highPrecisionActive)
          Positioned(
            left: 12,
            top: 12,
            child: IgnorePointer(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'High precision (CPU)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

        // Debug-only details. Keep this compact so it does not look like a
        // bottom band in debug builds.
        if (kDebugMode)
          Positioned(
            left: 12,
            bottom: 18,
            child: IgnorePointer(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  fallbackActive
                      ? 'Renderer: $mode (fallback)'
                      : 'Renderer: $mode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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
    if (widget.animationEnabled) {
      if (!_isAutomatedTest && !_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      if (_animationController.value != 0.0) {
        _animationController.value = 0.0;
      }
    }

    final controller = context.watch<FractalController>();
    final module = controller.module;

    // Widget tests run on a stripped-down engine that doesn't support GPU shaders.
    // Provide a lightweight placeholder surface so gesture + UI behavior can be
    // exercised in CI without a device/emulator.
    if (_usePlaceholderSurface) {
      final content = RepaintBoundary(
        key: widget.boundaryKey,
        child: const SizedBox.expand(
          child: ColoredBox(
            key: Key('fractalTestSurface'),
            color: Colors.black,
          ),
        ),
      );

      if (!widget.gesturesEnabled) {
        return content;
      }

      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
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
          child: content,
        ),
      );
    }

    if (widget.overrideChild != null) {
      final content = widget.overrideChild!;
      if (!widget.gesturesEnabled) {
        return content;
      }
      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
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
          child: content,
        ),
      );
    }

    final bool usesJuliaPerturb = module.id == 'julia' &&
        controller.view.zoom >= 5e6 &&
        controller.view.zoom < 1e30;

    final bool usesEscapeTimePerturb =
        kPerturbableEscapeTimeIds.contains(module.id) &&
            controller.view.zoom >= 5e6 &&
            controller.view.zoom < 1e30;

    final bool usesAnyPerturb = usesJuliaPerturb || usesEscapeTimePerturb;

    final shouldUseCpuFallback = !usesAnyPerturb &&
        _precisionPolicy.shouldUseCpuFallback(
          moduleId: module.id,
          zoom: controller.view.zoom,
        );

    if (shouldUseCpuFallback && module.dimension == FractalDimension.twoD) {
      final cpuContent = _withRendererIndicator(
        mode: 'CPU',
        fallbackActive: true,
        highPrecisionActive: true,
        child: RepaintBoundary(
          key: widget.boundaryKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dpr = MediaQuery.of(context).devicePixelRatio;
              // CPU renderer internal resolution:
              // - Preview/refine logic will further downscale while interacting.
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

      if (!widget.gesturesEnabled) {
        return cpuContent;
      }

      return Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
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
          child: cpuContent,
        ),
      );
    }

    // Select df2 shader for deep-zoom Mandelbrot.
    final bool usesDf2 = _precisionPolicy.shouldUseDoubleFloat(
      moduleId: module.id,
      zoom: controller.view.zoom,
    );
    // Cache the df2 wrapper; rebuild only when the standard module changes.
    if (usesDf2 && (module.id == 'mandelbrot')) {
      _df2Module ??= buildMandelbrotDf2Module(module);
    }
    // Cache the escape-time perturb wrapper; invalidate if module id changes.
    if (usesEscapeTimePerturb && _escapeTimePerturbModuleId != module.id) {
      _escapeTimePerturbModule = buildEscapeTimePerturbModule(module);
      _escapeTimePerturbModuleId = module.id;
    }
    final effectiveModule = usesJuliaPerturb
        ? (_juliaPerturbModule ??= buildJuliaPerturbModule(module))
        : usesEscapeTimePerturb
            ? (_escapeTimePerturbModule ??=
                buildEscapeTimePerturbModule(module))
            : ((usesDf2 && module.id == 'mandelbrot')
                ? (_df2Module ??= buildMandelbrotDf2Module(module))
                : module);

    // Check if we need to load a new shader
    if (_shaderAsset != effectiveModule.shaderAsset && !_loading) {
      _loadShader(effectiveModule.shaderAsset);
    }

    // Show error if shader failed to load
    if (_shaderError != null) {
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
      final l10n = AppLocalizations.of(context);
      return Center(
        child: FractalLoadingIndicator(
          size: 80,
          message: l10n?.loadingShaders ?? 'Loading shaders…',
        ),
      );
    }

    // Create the base fractal content
    Widget fractalContent = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final baseIterations =
              (controller.params['iterations'] as num?)?.toInt() ?? 160;
          final scaledIterations = _precisionPolicy.scaledGpuIterations(
            baseIterations: baseIterations,
            zoom: controller.view.zoom,
          );
          final gpuParams = Map<String, Object>.from(controller.params)
            ..['iterations'] = scaledIterations;

          final renderState = FractalRenderState(
            params: gpuParams,
            view: controller.view,
            transparentBackground: controller.transparentBackground,
          );
          if (!_firstFrameLogged) {
            _firstFrameLogged = true;
            final dt = DateTime.now()
                .difference(_shaderLoadStartedAt ?? DateTime.now())
                .inMilliseconds;
            debugPrint(
                '[renderer] first_frame_ms=$dt module=${controller.module.id} backend=gpu');
          }
          return CustomPaint(
            painter: FractalCanvas(
              module: effectiveModule,
              state: renderState,
              time: _animationController.value * 1000.0,
              shader: _currentFragmentShader(_program!),
              glowEnabled: controller.glowEnabled,
              glowSigma: controller.glowSigma,
              glowIntensity: controller.glowIntensity,
            ),
            child: Container(),
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
      mode: usesDf2 ? 'GPU-DF2' : 'GPU',
      fallbackActive: false,
      highPrecisionActive: usesDf2,
      child: RepaintBoundary(
        key: widget.boundaryKey,
        child: fractalContent,
      ),
    );

    if (!widget.gesturesEnabled) {
      return content;
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
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
        onTapUp: (module.id == 'julia_dual')
            ? (details) {
                _onJuliaDualTap(details.localPosition, controller);
              }
            : null,
        child: content,
      ),
    );
  }
}
