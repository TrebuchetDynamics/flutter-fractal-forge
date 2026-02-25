import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:vector_math/vector_math.dart';

/// Manages the state of fractal rendering and user interactions.
///
/// [FractalController] is the central state manager for the fractal viewer.
/// It handles:
/// - **Module selection**: Switching between fractal types
/// - **Parameter updates**: Modifying fractal settings with validation
/// - **View transformations**: Pan, zoom, and rotation
/// - **Preset management**: Applying and randomizing configurations
/// - **AR mode**: Transparent background toggle
///
/// This controller uses [ChangeNotifier] for reactive updates and is
/// typically provided via the Provider package.
///
/// {@category State Management}
///
/// Example usage:
/// ```dart
/// final controller = FractalController(registry);
///
/// // Switch fractal type
/// controller.selectModule(registry.byId('julia'));
///
/// // Update a parameter
/// controller.updateParam('iterations', 150);
///
/// // Apply a preset
/// controller.applyPreset(myPreset);
///
/// // Reset to defaults
/// controller.resetSession();
/// ```
class FractalController extends ChangeNotifier {
  static const bool _adaptiveIterationsEnabled = bool.fromEnvironment(
    'ADAPTIVE_ITERATIONS',
    defaultValue: true,
  );
  static const int _adaptiveIterationsMinStep = 8;
  static const double _adaptiveZoomEpsilon = 1.01;

  // Test mode detection - skip timer-based animations in automated tests.
  bool get _isTest => RuntimeModeService.isAutomatedTest;

  /// The module registry containing all available fractal types.
  final ModuleRegistry registry;

  final TestLogger? _logger;
  late FractalModule _module;
  Map<String, Object> _params = {};
  FractalViewState _view = FractalViewState.initial();
  bool _transparentBackground = false;
  bool _rotationLocked = false;
  bool _glowEnabled = false;
  double _glowSigma = 1.0; // blur radius multiplier: 1.0 = standard
  double _glowIntensity = 0.35; // opacity of glow layer

  // Animation state
  bool _isMorphing = false;
  double _morphProgress = 1.0;
  String? _previousModuleId;
  Timer? _morphTimer;
  bool _isCelebrating = false;
  Timer? _celebrationTimer;

  // Interesting spot tracking for celebrations
  int _consecutiveInterestingSpots = 0;
  DateTime? _lastInterestingSpotTime;
  final _celebrationController = StreamController<void>.broadcast();
  double _lastAdaptiveZoom = 1.0;

  /// Creates a new [FractalController] with the given [registry].
  ///
  /// Optionally accepts a [logger] for test instrumentation.
  /// Initializes with the first module in the registry.
  FractalController(this.registry, {TestLogger? logger}) : _logger = logger {
    _module = registry.modules.first;
    _applyPreset(_module.defaultPreset);
    _lastAdaptiveZoom = _view.zoom;
  }

  /// Whether a module morph transition is in progress.
  bool get isMorphing => _isMorphing;

  /// Progress of the current morph transition (0.0 to 1.0).
  double get morphProgress => _morphProgress;

  /// The previous module ID during a morph transition.
  String? get previousModuleId => _previousModuleId;

  /// Whether a celebration effect should be shown.
  bool get isCelebrating => _isCelebrating;

  /// Stream that emits when a celebration should be triggered.
  Stream<void> get onCelebration => _celebrationController.stream;

  /// The currently selected fractal module.
  ///
  /// Determines which fractal type is being rendered and
  /// what parameters are available.
  FractalModule get module => _module;

  /// Current parameter values keyed by parameter ID.
  ///
  /// These are passed to the shader each frame via [FractalRenderState].
  Map<String, Object> get params => _params;

  /// Current view state (pan, zoom, rotation).
  ///
  /// Updated by gesture handlers and preset application.
  FractalViewState get view => _view;

  /// Whether the fractal should render with a transparent background.
  ///
  /// Used for AR overlay mode and transparent PNG export.
  bool get transparentBackground => _transparentBackground;

  /// Whether gesture-based rotation is locked.
  bool get rotationLocked => _rotationLocked;

  bool get glowEnabled => _glowEnabled;
  double get glowSigma => _glowSigma;
  double get glowIntensity => _glowIntensity;

  /// Switches to a different fractal module.
  ///
  /// The [module] must be a valid module from the registry.
  /// Applies the module's default preset after switching.
  /// Triggers a smooth morph transition animation.
  ///
  /// No-op if [module] is already the current module.
  void selectModule(FractalModule module, {bool animate = true}) {
    if (_module.id == module.id) {
      return;
    }

    final previousId = _module.id;
    _module = module;
    _applyPreset(module.defaultPreset);

    if (animate) {
      _startMorphTransition(previousId);
    }

    notifyListeners();
    _logChange('stateChange', 'moduleSwitch', 'Switched to ${module.id}');
  }

  /// Starts a morph transition animation between fractal types.
  void _startMorphTransition(String fromModuleId) {
    // Skip timer-based animations in test mode
    if (_isTest) {
      _morphProgress = 1.0;
      _isMorphing = false;
      return;
    }

    _previousModuleId = fromModuleId;
    _isMorphing = true;
    _morphProgress = 0.0;

    HapticFeedback.lightImpact();

    _morphTimer?.cancel();

    const duration = Duration(milliseconds: 600);
    const fps = 60;
    final steps = (duration.inMilliseconds / (1000 / fps)).round();
    var step = 0;

    _morphTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ fps),
      (timer) {
        step++;
        // Use ease-out cubic curve
        final t = step / steps;
        _morphProgress = 1.0 - pow(1.0 - t, 3);
        notifyListeners();

        if (step >= steps) {
          timer.cancel();
          _morphProgress = 1.0;
          _isMorphing = false;
          _previousModuleId = null;
          notifyListeners();
        }
      },
    );
  }

  /// Updates a single fractal parameter.
  ///
  /// The [id] must match a parameter defined in the current module.
  /// The [value] is automatically clamped to the parameter's valid range.
  ///
  /// Example:
  /// ```dart
  /// controller.updateParam('iterations', 200);
  /// controller.updateParam('colorScheme', 2);
  /// ```
  void updateParam(String id, Object value) {
    final schema = _findParam(id);
    if (schema == null) return;
    _params = Map<String, Object>.from(_params);
    _params[id] = _clampValue(schema, value);
    notifyListeners();
    _logChange('stateChange', 'paramUpdate', 'Updated $id',
        metadata: {'value': value.toString()});
  }

  /// Applies a preset, setting all parameters and view state.
  ///
  /// The [preset] should match the current module (by moduleId).
  /// Missing parameters are filled with module defaults.
  void applyPreset(FractalPreset preset) {
    _applyPreset(preset);
    notifyListeners();
    _logChange('stateChange', 'presetApply', 'Applied preset ${preset.name}');
  }

  /// Resets all parameters to the module's default values.
  ///
  /// Does not affect the view state (pan, zoom, rotation).
  void resetParams() {
    _applyPreset(_module.defaultPreset);
    notifyListeners();
    _logChange('stateChange', 'reset', 'Reset params to default');
  }

  /// Resets the view state to initial values.
  ///
  /// Sets zoom to 1.0, pan to center, and rotation to zero.
  /// Does not affect fractal parameters.
  void resetView() {
    _view = FractalViewState.initial();
    _lastAdaptiveZoom = _view.zoom;
    notifyListeners();
    _logChange('stateChange', 'reset', 'Reset view');
  }

  /// Resets the entire session state.
  ///
  /// Restores parameters to defaults, resets view state,
  /// and disables transparent background. The selected module
  /// remains unchanged.
  void resetSession() {
    // Reset params to module defaults, but reset the view to the true "initial" view.
    // (Module default presets may intentionally start at a non-zero pan like -0.5,0.0 for Mandelbrot.)
    _applyPreset(_module.defaultPreset);
    _view = FractalViewState.initial();
    _lastAdaptiveZoom = _view.zoom;
    _transparentBackground = false;
    _rotationLocked = false;
    notifyListeners();
    _logChange('stateChange', 'reset', 'Reset session');
  }

  /// Randomizes all parameters within their valid ranges.
  ///
  /// Creates interesting, unpredictable fractal configurations.
  /// Useful for exploration and discovery.
  void randomizeParams() {
    final random = Random();
    final updated = <String, Object>{};
    for (final param in _module.parameters) {
      switch (param.type) {
        case FractalParamType.float:
          final raw = param.min + random.nextDouble() * (param.max - param.min);
          final stepped = _roundToStep(raw, param.step);
          updated[param.id] = stepped;
          break;
        case FractalParamType.integer:
          final value =
              param.min + random.nextInt((param.max - param.min).round() + 1);
          updated[param.id] = value.round();
          break;
        case FractalParamType.enumeration:
          if (param.options.isNotEmpty) {
            final choice = param.options[random.nextInt(param.options.length)];
            updated[param.id] = choice.value;
          } else {
            updated[param.id] = param.defaultValue;
          }
          break;
        case FractalParamType.boolean:
          updated[param.id] = random.nextBool();
          break;
      }
    }
    _params = updated;
    notifyListeners();
    _logChange(
        'stateChange', 'randomize', 'Randomized params for ${_module.id}');
  }

  double _moduleMinZoom(String moduleId) {
    switch (moduleId) {
      case 'cantor_set':
        // Prevent ultra-zoomed-out aliasing that appears as black vertical bands.
        return 0.2;
      default:
        return 1e-9;
    }
  }

  /// Updates the zoom level.
  ///
  /// The [zoom] value is clamped to range [moduleMinZoom, 1e12] to support
  /// deep-zoom exploration before precision fallback kicks in.
  void updateZoom(double zoom) {
    final minZoom = _moduleMinZoom(_module.id);
    final clampedZoom = zoom.clamp(minZoom, 1e12).toDouble();
    final zoomingIn = clampedZoom > (_lastAdaptiveZoom * _adaptiveZoomEpsilon);
    _view = _view.copyWith(zoom: clampedZoom);
    _lastAdaptiveZoom = clampedZoom;

    final autoIterations = _applyAdaptiveIterationsForZoom(
      zoom: clampedZoom,
      zoomingIn: zoomingIn,
    );

    notifyListeners();
    _logChange('userAction', 'zoom', 'Zoom updated', metadata: {
      'zoom': clampedZoom,
      if (autoIterations != null) 'autoIterations': autoIterations,
    });
  }

  /// Updates the 2D pan offset.
  ///
  /// Each component of [pan] is clamped to range [-3.0, 3.0].
  /// Used for 2D fractals to navigate the complex plane.
  void updatePan(Vector2 pan) {
    _view = _view.copyWith(
      pan: Vector2(
        pan.x.clamp(-3.0, 3.0),
        pan.y.clamp(-3.0, 3.0),
      ),
    );
    notifyListeners();
    _logChange('userAction', 'pan', 'Pan updated',
        metadata: {'x': pan.x, 'y': pan.y});
  }

  /// Updates the 3D rotation angles.
  ///
  /// Used for 3D fractals like Mandelbulb to control camera orientation.
  void updateRotation(Vector3 rotation) {
    _view = _view.copyWith(rotation: rotation);
    notifyListeners();
  }

  /// Locks or unlocks gesture-based rotation.
  void setRotationLocked(bool value) {
    if (_rotationLocked == value) return;
    _rotationLocked = value;
    notifyListeners();
    _logChange(
      'stateChange',
      'rotationLock',
      value ? 'Rotation locked' : 'Rotation unlocked',
    );
  }

  /// Toggles gesture-based rotation lock.
  void toggleRotationLock() {
    setRotationLocked(!_rotationLocked);
  }

  void setGlowEnabled(bool value) {
    if (_glowEnabled == value) return;
    _glowEnabled = value;
    notifyListeners();
  }

  void setGlowSigma(double value) {
    _glowSigma = value.clamp(0.1, 5.0);
    notifyListeners();
  }

  void setGlowIntensity(double value) {
    _glowIntensity = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Sets whether the background should be transparent.
  ///
  /// When [value] is true, the shader renders background pixels
  /// with alpha=0, suitable for AR overlay or PNG export.
  void setTransparentBackground(bool value) {
    _transparentBackground = value;
    notifyListeners();
  }

  void _logChange(String type, String category, String message,
      {Map<String, dynamic>? metadata}) {
    _logger?.log(LogEvent(
      timestamp: DateTime.now(),
      type: type,
      category: category,
      message: message,
      metadata: metadata,
    ));
  }

  /// Records finding an interesting spot in the fractal.
  ///
  /// When multiple interesting spots are found in quick succession,
  /// triggers a celebration effect.
  void recordInterestingSpot() {
    final now = DateTime.now();

    if (_lastInterestingSpotTime != null) {
      final elapsed = now.difference(_lastInterestingSpotTime!);
      if (elapsed.inSeconds < 30) {
        _consecutiveInterestingSpots++;

        // Trigger celebration after finding 3 interesting spots quickly
        if (_consecutiveInterestingSpots >= 3) {
          celebrate();
          _consecutiveInterestingSpots = 0;
        }
      } else {
        _consecutiveInterestingSpots = 1;
      }
    } else {
      _consecutiveInterestingSpots = 1;
    }

    _lastInterestingSpotTime = now;
    _logChange('userAction', 'discovery', 'Found interesting spot');
  }

  /// Manually triggers a celebration effect.
  void celebrate() {
    if (_isCelebrating) return;

    _isCelebrating = true;
    if (!_isTest) {
      HapticFeedback.mediumImpact();
    }
    _celebrationController.add(null);
    notifyListeners();

    // Skip timer in test mode
    if (_isTest) {
      _isCelebrating = false;
      return;
    }

    _celebrationTimer?.cancel();
    _celebrationTimer = Timer(const Duration(milliseconds: 2500), () {
      _isCelebrating = false;
      notifyListeners();
    });

    _logChange('event', 'celebration', 'Celebration triggered');
  }

  @override
  void dispose() {
    _morphTimer?.cancel();
    _celebrationTimer?.cancel();
    _celebrationController.close();
    super.dispose();
  }

  /// Applies an AR quality preset to the current parameters.
  ///
  /// AR quality presets adjust iteration counts and other
  /// performance-sensitive parameters to balance quality vs.
  /// frame rate during camera overlay.
  ///
  /// The [preset] affects only parameters relevant to the
  /// current module; other parameters are unchanged.
  void applyArQualityPreset(ArQualityPreset preset) {
    final overrides = arQualityParamsForModule(preset, _module.id);
    if (overrides.isEmpty) {
      return;
    }
    final updated = Map<String, Object>.from(_params);
    for (final entry in overrides.entries) {
      final schema = _findParam(entry.key);
      if (schema == null) {
        continue;
      }
      updated[entry.key] = _clampValue(schema, entry.value);
    }
    _params = updated;
    notifyListeners();
  }

  void _applyPreset(FractalPreset preset) {
    final defaults = <String, Object>{
      for (final param in _module.parameters) param.id: param.defaultValue,
    };

    final merged = {
      ...defaults,
      ...preset.params,
    };

    final clamped = <String, Object>{};
    for (final param in _module.parameters) {
      clamped[param.id] =
          _clampValue(param, merged[param.id] ?? param.defaultValue);
    }

    _params = clamped;
    _view = preset.view;
    _lastAdaptiveZoom = _view.zoom;
  }

  int? _applyAdaptiveIterationsForZoom({
    required double zoom,
    required bool zoomingIn,
  }) {
    if (!_adaptiveIterationsEnabled || !zoomingIn) {
      return null;
    }
    if (_module.dimension != FractalDimension.twoD) {
      return null;
    }

    final iterationsSchema = _findParam('iterations');
    if (iterationsSchema == null ||
        iterationsSchema.type != FractalParamType.integer) {
      return null;
    }

    final minIterations = iterationsSchema.min.round();
    final maxIterations = iterationsSchema.max.round();
    final currentValue = _params['iterations'];
    final currentIterations = currentValue is num
        ? currentValue.round()
        : (iterationsSchema.defaultValue as num).round();
    final baseIterations = (iterationsSchema.defaultValue as num).round();

    final targetIterations = _suggestIterationsForZoom(
      zoom: zoom,
      baseIterations: baseIterations,
      minIterations: minIterations,
      maxIterations: maxIterations,
    );
    if (targetIterations <= currentIterations) {
      return null;
    }

    final delta = targetIterations - currentIterations;
    final step = delta >= 256
        ? 64
        : delta >= 96
            ? 32
            : delta >= 32
                ? 16
                : _adaptiveIterationsMinStep;
    final nextIterations =
        (currentIterations + step).clamp(minIterations, maxIterations);
    if (nextIterations <= currentIterations) {
      return null;
    }

    _params = Map<String, Object>.from(_params);
    _params['iterations'] = nextIterations;
    _logChange(
      'stateChange',
      'adaptiveIterations',
      'Adaptive iterations increased',
      metadata: {
        'module': _module.id,
        'zoom': zoom,
        'from': currentIterations,
        'to': nextIterations,
        'target': targetIterations,
      },
    );
    return nextIterations;
  }

  int _suggestIterationsForZoom({
    required double zoom,
    required int baseIterations,
    required int minIterations,
    required int maxIterations,
  }) {
    final safeZoom = max(1.0, zoom);
    final zoomOctaves = log(safeZoom) / ln2;
    final extra = max(0, (zoomOctaves * 48.0).round());
    final raw = baseIterations + extra;
    // Snap to a small step to avoid jittery one-by-one jumps.
    final snapped = ((raw + 3) ~/ 4) * 4;
    return snapped.clamp(minIterations, maxIterations);
  }

  double _roundToStep(double value, double step) {
    if (step <= 0) {
      return value;
    }
    final snapped = (value / step).round() * step;
    // Avoid floating point noise for typical slider steps.
    return double.parse(snapped.toStringAsFixed(6));
  }

  Object _clampValue(FractalParameter schema, Object value) {
    if (schema.type == FractalParamType.boolean) {
      return value is bool ? value : false;
    }
    if (schema.type == FractalParamType.enumeration) {
      final optionValues = schema.options.map((option) => option.value).toSet();
      return optionValues.contains(value) ? value : schema.defaultValue;
    }
    if (value is num) {
      final clamped = value.toDouble().clamp(schema.min, schema.max);
      if (schema.type == FractalParamType.integer) {
        return clamped.round();
      }
      return clamped;
    }
    return schema.defaultValue;
  }

  FractalParameter? _findParam(String id) {
    for (final param in _module.parameters) {
      if (param.id == id) {
        return param;
      }
    }
    return null;
  }

  /// Alias for [view] for backward compatibility.
  FractalViewState get viewState => _view;

  /// The currently selected fractal module (alias for [module]).
  FractalModule get currentModule => _module;

  /// Loads a complete state from another controller or snapshot.
  ///
  /// This initializes the controller from a full state including
  /// module, parameters, view state, and transparency setting.
  /// Parameters are clamped to the target module's schema.
  ///
  /// Can accept either a [module] object directly or a [moduleId] string.
  void loadState({
    FractalModule? module,
    String? moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
    bool transparentBackground = false,
    bool animateModule = false,
  }) {
    // Find the module by ID or use provided module
    final FractalModule targetModule;
    if (module != null) {
      targetModule = module;
    } else if (moduleId != null) {
      targetModule = registry.modules.firstWhere(
        (m) => m.id == moduleId,
        orElse: () => _module,
      );
    } else {
      targetModule = _module;
    }

    // Switch to the target module
    if (targetModule.id != _module.id) {
      if (animateModule) {
        selectModule(targetModule, animate: true);
      } else {
        _module = targetModule;
      }
    }

    // Apply parameters with clamping
    final clamped = <String, Object>{};
    for (final param in _module.parameters) {
      final value = params[param.id] ?? param.defaultValue;
      clamped[param.id] = _clampValue(param, value);
    }
    _params = clamped;

    // Set view state
    _view = view;
    _lastAdaptiveZoom = _view.zoom;

    // Set transparency
    _transparentBackground = transparentBackground;

    notifyListeners();
    _logChange('stateChange', 'loadState', 'Loaded state for ${_module.id}');
  }
}
