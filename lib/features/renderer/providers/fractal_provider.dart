import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
import 'package:flutter_fractals/core/services/runtime_mode_service.dart';
import 'package:flutter_fractals/features/renderer/providers/adaptive_iterations_service.dart';
import 'package:flutter_fractals/features/renderer/providers/animation_manager.dart';
import 'package:flutter_fractals/features/renderer/providers/param_validation_service.dart';
import 'package:flutter_fractals/features/renderer/providers/viewport_constraints.dart';
import 'package:vector_math/vector_math.dart';

/// Manages the state of fractal rendering and user interactions.
///
/// [FractalController] is the central state manager for the fractal viewer.
/// It handles:
/// - **Module selection**: Switching between fractal types
/// - **Parameter updates**: Modifying fractal settings with validation
/// - **View transformations**: Pan, zoom, and rotation
/// - **Preset management**: Applying and randomizing configurations
///
/// This controller uses [ChangeNotifier] for reactive updates and is
/// typically provided via the Provider package.
///
/// Architecture Note:
/// This class follows the Facade pattern, delegating specialized
/// responsibilities to focused services:
/// - [AnimationManager]: Morph transitions and celebrations
/// - [AdaptiveIterationsService]: Zoom-based iteration adjustment
/// - [ParamValidationService]: Parameter clamping and validation
/// - [ViewportConstraints]: Module-specific viewport limits
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
  static const double _adaptiveZoomEpsilon = 1.01;

  // ========================================================================
  // Dependencies (injected for testability and SOLID compliance)
  // ========================================================================

  final ModuleRegistry registry;
  final TestLogger? _logger;

  // Delegated services following Single Responsibility Principle
  late final AnimationManager _animationManager;
  late final AdaptiveIterationsService _adaptiveIterations;
  late final ParamValidationService _paramValidation;
  late final ViewportConstraints _viewportConstraints;

  // ========================================================================
  // Core State
  // ========================================================================

  late FractalModule _module;
  Map<String, Object> _params = {};
  FractalViewState _view = FractalViewState.initial();
  bool _transparentBackground = false;
  bool _rotationLocked = false;
  bool _glowEnabled = false;
  double _glowSigma = 1.0;
  double _glowIntensity = 0.35;
  double _lastAdaptiveZoom = 1.0;

  // Interesting spot tracking for celebrations
  int _consecutiveInterestingSpots = 0;
  DateTime? _lastInterestingSpotTime;

  // ========================================================================
  // Constructor
  // ========================================================================

  /// Creates a new [FractalController] with the given [registry].
  ///
  /// Optionally accepts a [logger] for test instrumentation.
  /// Initializes with the first module in the registry.
  FractalController(this.registry, {TestLogger? logger}) : _logger = logger {
    _initServices();
    _module = registry.modules.first;
    _applyPreset(_module.defaultPreset);
    _lastAdaptiveZoom = _view.zoom;
  }

  /// Initializes delegated services.
  ///
  /// Extracted to a method for clarity and testability.
  void _initServices() {
    _animationManager = AnimationManager(
      isTest: RuntimeModeService.isAutomatedTest,
      notifyListeners: () => notifyListeners(),
      logChange: _logChange,
    );

    _adaptiveIterations = AdaptiveIterationsService();
    _paramValidation = ParamValidationService();
    _viewportConstraints = ViewportConstraints();
  }

  // ========================================================================
  // Animation State (Delegated to AnimationManager)
  // ========================================================================

  /// Whether a module morph transition is in progress.
  bool get isMorphing => _animationManager.isMorphing;

  /// Progress of the current morph transition (0.0 to 1.0).
  double get morphProgress => _animationManager.morphProgress;

  /// The previous module ID during a morph transition.
  String? get previousModuleId => _animationManager.previousModuleId;

  /// Whether a celebration effect should be shown.
  bool get isCelebrating => _animationManager.isCelebrating;

  /// Stream that emits when a celebration should be triggered.
  Stream<void> get onCelebration => _animationManager.onCelebration;

  // ========================================================================
  // Module & Parameter State
  // ========================================================================

  /// The currently selected fractal module.
  FractalModule get module => _module;

  /// Current parameter values keyed by parameter ID.
  Map<String, Object> get params => _params;

  /// Current view state (pan, zoom, rotation).
  FractalViewState get view => _view;

  /// Whether the fractal should render with a transparent background.
  bool get transparentBackground => _transparentBackground;

  /// Whether gesture-based rotation is locked.
  bool get rotationLocked => _rotationLocked;

  bool get glowEnabled => _glowEnabled;
  double get glowSigma => _glowSigma;
  double get glowIntensity => _glowIntensity;

  // ========================================================================
  // Module Selection
  // ========================================================================

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
      _animationManager.startMorphTransition(previousId);
    }

    notifyListeners();
    _logChange('stateChange', 'moduleSwitch', 'Switched to ${module.id}');
  }

  // ========================================================================
  // Parameter Updates
  // ========================================================================

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
    final schema = _paramValidation.findParam(id, _module.parameters);
    if (schema == null) return;
    _params = Map<String, Object>.from(_params);
    _params[id] = _paramValidation.clampValue(schema, value);
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

  // ========================================================================
  // View Transformations
  // ========================================================================

  /// Updates the zoom level.
  ///
  /// The [zoom] value is clamped to range [moduleMinZoom, 1e12] to support
  /// deep-zoom exploration before precision fallback kicks in.
  void updateZoom(double zoom) {
    final minZoom = _viewportConstraints.minZoom(_module.id);
    final clampedZoom = zoom.clamp(minZoom, _viewportConstraints.maxZoom);
    final zoomingIn = clampedZoom > (_lastAdaptiveZoom * _adaptiveZoomEpsilon);
    _view = _view.copyWith(zoom: clampedZoom);
    _lastAdaptiveZoom = clampedZoom;

    final autoIterations = _adaptiveIterations.applyAdaptiveIterationsForZoom(
      zoom: clampedZoom,
      zoomingIn: zoomingIn,
      is2D: _module.dimension == FractalDimension.twoD,
      iterationsSchema:
          _paramValidation.findParam('iterations', _module.parameters),
      params: _params,
      updateParams: (updated) => _params = updated,
      logChange: _logChange,
      moduleId: _module.id,
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
        pan.x.clamp(ViewportConstraints.panMin, ViewportConstraints.panMax),
        pan.y.clamp(ViewportConstraints.panMin, ViewportConstraints.panMax),
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

  // ========================================================================
  // Rotation Lock
  // ========================================================================

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

  // ========================================================================
  // Glow Effects
  // ========================================================================

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

  // ========================================================================
  // Transparency
  // ========================================================================

  /// Sets whether the background should be transparent.
  ///
  /// When [value] is true, the shader renders background pixels
  /// with alpha=0, suitable for transparent PNG export.
  void setTransparentBackground(bool value) {
    _transparentBackground = value;
    notifyListeners();
  }

  // ========================================================================
  // Logging
  // ========================================================================

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

  // ========================================================================
  // Discovery & Celebrations
  // ========================================================================

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
          _animationManager.celebrate();
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
    _animationManager.celebrate();
  }

  // ========================================================================
  // Lifecycle
  // ========================================================================

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  // ========================================================================
  // Private Helpers
  // ========================================================================

  void _applyPreset(FractalPreset preset) {
    _params = _paramValidation.clampPresetParams(
      parameters: _module.parameters,
      presetParams: preset.params,
    );
    _view = preset.view;
    _lastAdaptiveZoom = _view.zoom;
  }

  double _roundToStep(double value, double step) {
    if (step <= 0) {
      return value;
    }
    final snapped = (value / step).round() * step;
    // Avoid floating point noise for typical slider steps.
    return double.parse(snapped.toStringAsFixed(6));
  }

  // ========================================================================
  // Backward Compatibility Aliases
  // ========================================================================

  /// Alias for [view] for backward compatibility.
  FractalViewState get viewState => _view;

  /// The currently selected fractal module (alias for [module]).
  FractalModule get currentModule => _module;

  // ========================================================================
  // State Loading
  // ========================================================================

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
    _params = _paramValidation.clampParams(
      parameters: _module.parameters,
      values: params,
    );

    // Set view state
    _view = view;
    _lastAdaptiveZoom = _view.zoom;

    // Set transparency
    _transparentBackground = transparentBackground;

    notifyListeners();
    _logChange('stateChange', 'loadState', 'Loaded state for ${_module.id}');
  }
}
