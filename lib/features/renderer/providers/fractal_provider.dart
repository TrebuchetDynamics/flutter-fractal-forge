import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/services/test_logger.dart';
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
  /// The module registry containing all available fractal types.
  final ModuleRegistry registry;

  final TestLogger? _logger;
  late FractalModule _module;
  Map<String, Object> _params = {};
  FractalViewState _view = FractalViewState.initial();
  bool _transparentBackground = false;

  /// Creates a new [FractalController] with the given [registry].
  ///
  /// Optionally accepts a [logger] for test instrumentation.
  /// Initializes with the first module in the registry.
  FractalController(this.registry, {TestLogger? logger}) : _logger = logger {
    _module = registry.modules.first;
    _applyPreset(_module.defaultPreset);
  }

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

  /// Switches to a different fractal module.
  ///
  /// The [module] must be a valid module from the registry.
  /// Applies the module's default preset after switching.
  ///
  /// No-op if [module] is already the current module.
  void selectModule(FractalModule module) {
    if (_module.id == module.id) {
      return;
    }
    _module = module;
    _applyPreset(module.defaultPreset);
    notifyListeners();
    _logChange('stateChange', 'moduleSwitch', 'Switched to ${module.id}');
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
    final schema = _module.parameters.firstWhere((param) => param.id == id);
    _params = Map<String, Object>.from(_params);
    _params[id] = _clampValue(schema, value);
    notifyListeners();
    _logChange('stateChange', 'paramUpdate', 'Updated $id', metadata: {'value': value.toString()});
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
    notifyListeners();
    _logChange('stateChange', 'reset', 'Reset view');
  }

  /// Resets the entire session state.
  ///
  /// Restores parameters to defaults, resets view state,
  /// and disables transparent background. The selected module
  /// remains unchanged.
  void resetSession() {
    _applyPreset(_module.defaultPreset);
    _transparentBackground = false;
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
          final value = param.min + random.nextInt((param.max - param.min).round() + 1);
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
    _logChange('stateChange', 'randomize', 'Randomized params for ${_module.id}');
  }

  /// Updates the zoom level.
  ///
  /// The [zoom] value is clamped to range [0.05, 20.0].
  void updateZoom(double zoom) {
    _view = _view.copyWith(zoom: zoom.clamp(0.05, 20.0));
    notifyListeners();
    _logChange('userAction', 'zoom', 'Zoom updated', metadata: {'zoom': zoom});
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
    _logChange('userAction', 'pan', 'Pan updated', metadata: {'x': pan.x, 'y': pan.y});
  }

  /// Updates the 3D rotation angles.
  ///
  /// Used for 3D fractals like Mandelbulb to control camera orientation.
  void updateRotation(Vector3 rotation) {
    _view = _view.copyWith(rotation: rotation);
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

  void _logChange(String type, String category, String message, {Map<String, dynamic>? metadata}) {
    _logger?.log(LogEvent(
      timestamp: DateTime.now(),
      type: type,
      category: category,
      message: message,
      metadata: metadata,
    ));
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
      clamped[param.id] = _clampValue(param, merged[param.id] ?? param.defaultValue);
    }

    _params = clamped;
    _view = preset.view;
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
}
