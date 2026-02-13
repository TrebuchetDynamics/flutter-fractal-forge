import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/crash_reporter.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/core/widgets/animation_effects.dart';
import './providers/fractal_provider.dart';
import 'cpu_fractal_renderer.dart';
import 'deep_zoom_precision_policy.dart';
import 'fractal_canvas.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

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

  /// Called when the user manually starts pan/zoom interaction.
  final VoidCallback? onUserInteraction;

  /// Whether time-based animation should advance.
  ///
  /// When false, rendering uses a fixed time (frame is frozen).
  final bool animationEnabled;

  /// Creates a [FractalRenderer] widget.
  const FractalRenderer({
    Key? key,
    this.boundaryKey,
    this.gesturesEnabled = true,
    this.onOpenControls,
    this.onOpenPresets,
    this.onOpenExport,
    this.onUserInteraction,
    this.animationEnabled = true,
  }) : super(key: key);

  @override
  State<FractalRenderer> createState() => _FractalRendererState();
}

class _FractalRendererState extends State<FractalRenderer>
    with TickerProviderStateMixin {
  static const DeepZoomPrecisionPolicy _precisionPolicy =
      DeepZoomPrecisionPolicy();
  // `bool.fromEnvironment('FLUTTER_TEST')` isn't consistently set across all
  // runners. Using an assert-based check is reliable in debug/test and keeps
  // release builds unaffected.
  static final bool _isTest = (() {
    var v = false;
    assert(() {
      v = true;
      return true;
    }());
    return v || const bool.fromEnvironment('FLUTTER_TEST');
  })();

  /// Maximum number of shader load retries before showing error.
  static const int _maxShaderRetries = 3;

  late AnimationController _animationController;
  ui.FragmentProgram? _program;
  String? _shaderAsset;
  bool _loading = false;
  String? _shaderError;
  String? _shaderErrorDetails;
  ShaderErrorType _shaderErrorType = ShaderErrorType.unknown;
  int _shaderRetryCount = 0;

  // Gesture state for smooth interactions
  late AnimationController _zoomMomentumController;
  late AnimationController _panMomentumController;
  double _zoomVelocity = 0.0;
  Offset _panVelocity = Offset.zero;
  double _lastScale = 1.0;
  double _lastRotation = 0.0;


  // Gesture anchors so interactions feel 1:1 with fingers.
  double _startZoom = 1.0;
  Vector2 _startPan = Vector2.zero();
  Offset _startFocalPoint = Offset.zero;

  // For smooth zoom interpolation (kept for optional momentum only)



  DateTime? _shaderLoadStartedAt;
  bool _firstFrameLogged = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(days: 1),
      vsync: this,
    );

    // Momentum controllers for smooth deceleration
    _zoomMomentumController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(_applyZoomMomentum);

    _panMomentumController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(_applyPanMomentum);

    // Avoid an always-running ticker in widget tests; it makes `pumpAndSettle`
    // time out.
    if (!_isTest) {
      _animationController.repeat();
    }
  }

  void _applyZoomMomentum() {
    if (!mounted) return;
    final controller = context.read<FractalController>();
    final view = controller.view;

    // Decay the velocity with easing
    final progress =
        Curves.easeOutCubic.transform(_zoomMomentumController.value);
    final decayedVelocity = _zoomVelocity * (1.0 - progress);

    if (decayedVelocity.abs() > 0.001) {
      final newZoom = view.zoom * (1.0 + decayedVelocity * 0.02);
      controller.updateZoom(newZoom);
    }
  }

  void _applyPanMomentum() {
    if (!mounted) return;
    final controller = context.read<FractalController>();
    final view = controller.view;
    final module = controller.module;

    // Decay the velocity with easing
    final progress =
        Curves.easeOutCubic.transform(_panMomentumController.value);
    final decayedVelocity = _panVelocity * (1.0 - progress);

    if (decayedVelocity.distance > 0.5) {
      if (module.dimension == FractalDimension.threeD) {
        controller.updateRotation(
          view.rotation +
              Vector3(
                decayedVelocity.dy * 0.001,
                decayedVelocity.dx * 0.001,
                0,
              ),
        );
      } else {
        final pan = Vector2(
          view.pan.x - decayedVelocity.dx * 0.0005,
          view.pan.y - decayedVelocity.dy * 0.0005,
        );
        controller.updatePan(pan);
      }
    }
  }

  /// Loads a shader with retry logic and error reporting.
  ///
  /// Attempts to load the shader up to [_maxShaderRetries] times before
  /// giving up. Reports all failures to [CrashReporter].
  Future<void> _loadShader(String asset) async {
    if (_loading) {
      return;
    }
    _loading = true;
    _shaderLoadStartedAt = DateTime.now();
    debugPrint('[renderer] shader_load_start asset=$asset');
    setState(() {
      _shaderError = null;
      _shaderErrorDetails = null;
    });

    for (var attempt = 1; attempt <= _maxShaderRetries; attempt++) {
      try {
        final program = await ui.FragmentProgram.fromAsset(asset);
        if (mounted) {
          setState(() {
            _program = program;
            _shaderAsset = asset;
            _shaderRetryCount = 0;
          });
        }
        final dt = DateTime.now()
            .difference(_shaderLoadStartedAt ?? DateTime.now())
            .inMilliseconds;
        debugPrint('[renderer] shader_load_ok asset=$asset compile_ms=$dt');
        return;
      } catch (e, stack) {
        final errorType = _categorizeShaderError(e);
        debugPrint(
            '[renderer] shader_load_fail asset=$asset attempt=$attempt type=$errorType err=$e');

        // Report to crash reporter
        CrashReporter.instance.record(
          e,
          stack,
          source: 'shader_load',
          fatal: false,
          context: 'Attempt $attempt/$_maxShaderRetries for $asset',
          tags: {
            'shader_asset': asset,
            'attempt': attempt.toString(),
            'error_type': errorType.name,
          },
        );

        if (attempt < _maxShaderRetries) {
          // Wait before retrying with exponential backoff
          await Future.delayed(Duration(milliseconds: 100 * attempt));
          continue;
        }

        // Final failure
        if (mounted) {
          setState(() {
            _shaderError = _getShaderErrorMessage(e, errorType);
            _shaderErrorDetails = e.toString();
            _shaderErrorType = errorType;
            _shaderRetryCount = attempt;
          });
        }
      }
    }

    _loading = false;
  }

  /// Categorizes shader errors for better error messages.
  ShaderErrorType _categorizeShaderError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('compile') || message.contains('glsl')) {
      return ShaderErrorType.compilation;
    }
    if (message.contains('not found') || message.contains('asset')) {
      return ShaderErrorType.assetNotFound;
    }
    if (message.contains('memory') || message.contains('oom')) {
      return ShaderErrorType.outOfMemory;
    }
    if (message.contains('gpu') || message.contains('driver')) {
      return ShaderErrorType.gpuUnsupported;
    }
    return ShaderErrorType.unknown;
  }

  /// Returns a user-friendly error message based on error type.
  String _getShaderErrorMessage(Object error, ShaderErrorType type) {
    switch (type) {
      case ShaderErrorType.compilation:
        return 'Shader compilation failed. This fractal may not be compatible with your device.';
      case ShaderErrorType.assetNotFound:
        return 'Shader file not found. Please reinstall the app.';
      case ShaderErrorType.outOfMemory:
        return 'Not enough GPU memory. Try closing other apps.';
      case ShaderErrorType.gpuUnsupported:
        return 'Your GPU does not support this fractal\'s shader requirements.';
      case ShaderErrorType.unknown:
        return 'Failed to load shader: ${error.toString().length > 100 ? '${error.toString().substring(0, 100)}...' : error}';
    }
  }

  /// Retries loading the current shader.
  void _retryShaderLoad() {
    if (_shaderAsset != null ||
        context.read<FractalController>().module.shaderAsset.isNotEmpty) {
      final asset =
          _shaderAsset ?? context.read<FractalController>().module.shaderAsset;
      _loading = false; // Reset loading flag to allow retry
      _loadShader(asset);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _zoomMomentumController.dispose();
    _panMomentumController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    widget.onUserInteraction?.call();

    _zoomMomentumController.stop();
    _panMomentumController.stop();

    _lastScale = 1.0;
    _lastRotation = 0.0;

    _zoomVelocity = 0.0;
    _panVelocity = Offset.zero;

    final controller = context.read<FractalController>();
    _startZoom = controller.view.zoom;
    _startPan = controller.view.pan;
    _startFocalPoint = details.focalPoint;



  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final controller = context.read<FractalController>();
    final view = controller.view;
    final module = controller.module;

    // Try to map screen pixels to fractal "world" units based on the shader's
    // coordinate transform:
    //   uv = (frag - 0.5*res)/scale
    //   c  = uv/zoom + center
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    final scalePx =
        (size == null) ? 1.0 : math.max(1.0, math.min(size.width, size.height));

    // Total finger movement since gesture start.
    final totalDelta = details.focalPoint - _startFocalPoint;

    // --- 1 finger: pan (2D) or rotate (3D) ---
    if (details.pointerCount == 1) {
      if (module.dimension == FractalDimension.threeD) {
        // Rotate with 1 finger in AR/3D mode.
        controller.updateRotation(
          view.rotation +
              Vector3(totalDelta.dy * 0.0009, totalDelta.dx * 0.0009, 0),
        );
      } else {
        // Convert pixels → complex-plane delta, accounting for rotation.
        // When the fractal is rotated, screen drag axes must rotate too
        // so panning always feels physically correct.
        final rot = view.rotation.z; // rotation angle in radians
        final cosR = math.cos(rot);
        final sinR = math.sin(rot);
        final rawDx = totalDelta.dx / scalePx;
        final rawDy = totalDelta.dy / scalePx;
        // Rotate screen delta by -rotation to get world delta
        final dxWorld =
            (rawDx * cosR + rawDy * sinR) / math.max(1e-9, _startZoom);
        final dyWorld =
            (-rawDx * sinR + rawDy * cosR) / math.max(1e-9, _startZoom);
        controller.updatePan(
          Vector2(
            _startPan.x - dxWorld,
            _startPan.y - dyWorld,
          ),
        );
      }

      // For momentum.
      _panVelocity = details.focalPointDelta;
      return;
    }

    // --- 2+ fingers: pinch zoom (and optional twist rotation for 3D) ---
    final newZoom = (_startZoom * details.scale).clamp(1e-9, 1e12);

    if (module.dimension == FractalDimension.threeD &&
        details.rotation != 0.0) {
      final rotationDelta = details.rotation - _lastRotation;
      controller.updateRotation(view.rotation + Vector3(0, 0, rotationDelta));
      _lastRotation = details.rotation;
    }

    if (module.dimension != FractalDimension.threeD && size != null) {
      // Keep the point under the fingers stable while zooming.
      final startN =
          (_startFocalPoint - Offset(size.width / 2, size.height / 2)) /
              scalePx;
      final curN =
          (details.focalPoint - Offset(size.width / 2, size.height / 2)) /
              scalePx;

      final worldX = startN.dx / _startZoom + _startPan.x;
      final worldY = startN.dy / _startZoom + _startPan.y;

      final newCenterX = worldX - (curN.dx / newZoom);
      final newCenterY = worldY - (curN.dy / newZoom);
      controller.updatePan(Vector2(newCenterX, newCenterY));
    }

    controller.updateZoom(newZoom);

    // Track velocity for momentum (after release).
    final scaleChange = details.scale / _lastScale;
    _zoomVelocity = (scaleChange - 1.0) * 10.0;
    _lastScale = details.scale;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Apply momentum/inertia based on final velocity
    if (_zoomVelocity.abs() > 0.05) {
      _zoomMomentumController.forward(from: 0);
    }
    if (_panVelocity.distance > 5) {
      _panMomentumController.forward(from: 0);
    }

  }


  void _onDoubleTap() {
    final controller = context.read<FractalController>();
    controller.resetView();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show snackbar feedback
    final l10n = AppLocalizations.of(context);
    if (l10n != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gestureDoubleTapReset),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _onLongPress(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    _showContextMenu(details.globalPosition);
  }

  void _showContextMenu(Offset position) {
    final controller = context.read<FractalController>();
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'reset',
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuResetView),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'controls',
          child: Row(
            children: [
              const Icon(Icons.tune_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuOpenControls),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'presets',
          child: Row(
            children: [
              const Icon(Icons.bookmark_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuOpenPresets),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'randomize',
          child: Row(
            children: [
              const Icon(Icons.shuffle_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuRandomize),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'export',
          child: Row(
            children: [
              const Icon(Icons.download_rounded, size: 20),
              const SizedBox(width: 12),
              Text(l10n.contextMenuExport),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'reset':
          controller.resetView();
          HapticFeedback.mediumImpact();
          break;
        case 'controls':
          widget.onOpenControls?.call();
          break;
        case 'presets':
          widget.onOpenPresets?.call();
          break;
        case 'randomize':
          controller.randomizeParams();
          HapticFeedback.mediumImpact();
          break;
        case 'export':
          widget.onOpenExport?.call();
          break;
      }
    });
  }

  Widget _withRendererIndicator({
    required Widget child,
    required String mode,
    required bool fallbackActive,
  }) {
    if (!kDebugMode) return child;
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 12,
          right: 12,
          bottom: 18,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black54),
              ),
              child: Text(
                'Renderer: $mode | fallback: $fallbackActive',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
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
      if (!_isTest && !_animationController.isAnimating) {
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
    if (_isTest) {
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

      return GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: (details) {
          final provider = context.read<FractalController>();
          final view = provider.view;

          if (details.scale != 1.0) {
            provider.updateZoom(view.zoom * details.scale);
          }

          if (details.focalPointDelta != Offset.zero) {
            final delta = details.focalPointDelta;
            if (module.dimension == FractalDimension.threeD) {
              provider.updateRotation(
                view.rotation + Vector3(delta.dy * 0.01, delta.dx * 0.01, 0),
              );
            } else {
              final pan = Vector2(
                view.pan.x - delta.dx * 0.005,
                view.pan.y - delta.dy * 0.005,
              );
              provider.updatePan(pan);
            }
          }
        },
        onScaleEnd: _onScaleEnd,
        onDoubleTap: _onDoubleTap,
        onLongPressStart: _onLongPress,
        child: content,
      );
    }

    final shouldUseCpuFallback = _precisionPolicy.shouldUseCpuFallback(
      moduleId: module.id,
      zoom: controller.view.zoom,
    );

    if (shouldUseCpuFallback && module.dimension == FractalDimension.twoD) {
      final cpuContent = _withRendererIndicator(
        mode: 'CPU',
        fallbackActive: true,
        child: RepaintBoundary(
          key: widget.boundaryKey,
          child: CpuFractalRenderer(
            module: module,
            state: FractalRenderState(
              params: controller.params,
              view: controller.view,
              transparentBackground: controller.transparentBackground,
            ),
          ),
        ),
      );

      if (!widget.gesturesEnabled) {
        return cpuContent;
      }

      return GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        onDoubleTap: _onDoubleTap,
        onLongPressStart: _onLongPress,
        child: cpuContent,
      );
    }

    if (_shaderAsset != module.shaderAsset && !_loading) {
      _loadShader(module.shaderAsset);
    }
    if (_shaderError != null) {
      return _ShaderErrorDisplay(
        errorMessage: _shaderError!,
        errorDetails: _shaderErrorDetails,
        errorType: _shaderErrorType,
        retryCount: _shaderRetryCount,
        maxRetries: _maxShaderRetries,
        onRetry: _retryShaderLoad,
        onGoBack: () => Navigator.of(context).maybePop(),
      );
    }
    if (_program == null) {
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
          final renderState = FractalRenderState(
            params: controller.params,
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
              module: controller.module,
              state: renderState,
              time: _animationController.value * 1000.0,
              program: _program!,
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
      mode: 'GPU',
      fallbackActive: false,
      child: RepaintBoundary(
        key: widget.boundaryKey,
        child: fractalContent,
      ),
    );

    if (!widget.gesturesEnabled) {
      return content;
    }

    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onDoubleTap: _onDoubleTap,
      onLongPressStart: _onLongPress,
      child: content,
    );
  }
}

/// Displays shader loading errors with recovery options.
class _ShaderErrorDisplay extends StatefulWidget {
  final String errorMessage;
  final String? errorDetails;
  final ShaderErrorType errorType;
  final int retryCount;
  final int maxRetries;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  const _ShaderErrorDisplay({
    required this.errorMessage,
    this.errorDetails,
    required this.errorType,
    required this.retryCount,
    required this.maxRetries,
    required this.onRetry,
    required this.onGoBack,
  });

  @override
  State<_ShaderErrorDisplay> createState() => _ShaderErrorDisplayState();
}

class _ShaderErrorDisplayState extends State<_ShaderErrorDisplay>
    with SingleTickerProviderStateMixin {
  bool _showDetails = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData get _errorIcon {
    switch (widget.errorType) {
      case ShaderErrorType.compilation:
        return Icons.code_off_rounded;
      case ShaderErrorType.assetNotFound:
        return Icons.folder_off_rounded;
      case ShaderErrorType.outOfMemory:
        return Icons.memory_rounded;
      case ShaderErrorType.gpuUnsupported:
        return Icons.desktop_access_disabled_rounded;
      case ShaderErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  Color get _errorColor {
    switch (widget.errorType) {
      case ShaderErrorType.compilation:
      case ShaderErrorType.unknown:
        return AppColors.error;
      case ShaderErrorType.assetNotFound:
        return AppColors.warning;
      case ShaderErrorType.outOfMemory:
      case ShaderErrorType.gpuUnsupported:
        return AppColors.error;
    }
  }

  bool get _canRetry => widget.retryCount < widget.maxRetries;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated error icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = 1.0 + (_pulseController.value * 0.1);
                  return Transform.scale(
                    scale: pulse,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _errorColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _errorColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _errorColor
                                .withOpacity(0.2 * _pulseController.value),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _errorIcon,
                        size: 48,
                        color: _errorColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Error title
              Text(
                'Shader Error',
                style: AppTypography.titleLarge.copyWith(
                  color: _errorColor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Retry count indicator
              if (widget.retryCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Attempt ${widget.retryCount}/${widget.maxRetries}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              // Error message
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.errorMessage,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: [
                  if (_canRetry)
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: widget.onGoBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.border.withOpacity(0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              // Technical details section
              if (widget.errorDetails != null) ...[
                const SizedBox(height: AppSpacing.xl),
                TextButton.icon(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  icon: Icon(
                    _showDetails
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                  ),
                  label: Text(_showDetails ? 'Hide Details' : 'Show Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                ),
                AnimatedCrossFade(
                  duration: AppAnimations.fast,
                  crossFadeState: _showDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.2),
                      ),
                    ),
                    child: SelectableText(
                      widget.errorDetails!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],

              // Helpful tips
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.primary.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _getTipForErrorType(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTipForErrorType() {
    switch (widget.errorType) {
      case ShaderErrorType.compilation:
        return 'This fractal\'s shader may not be compatible with your GPU. Try a simpler fractal type.';
      case ShaderErrorType.assetNotFound:
        return 'The shader file appears to be missing. Reinstalling the app may fix this issue.';
      case ShaderErrorType.outOfMemory:
        return 'Close other apps to free up GPU memory, then try again.';
      case ShaderErrorType.gpuUnsupported:
        return 'Your device\'s GPU may not support the features required by this fractal.';
      case ShaderErrorType.unknown:
        return 'If this problem persists, try restarting the app or your device.';
    }
  }
}
