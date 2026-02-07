import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:vector_math/vector_math.dart';

class FractalController extends ChangeNotifier {
  final ModuleRegistry registry;
  late FractalModule _module;
  Map<String, Object> _params = {};
  FractalViewState _view = FractalViewState.initial();
  bool _transparentBackground = false;

  FractalController(this.registry) {
    _module = registry.modules.first;
    _applyPreset(_module.defaultPreset);
  }

  FractalModule get module => _module;
  Map<String, Object> get params => _params;
  FractalViewState get view => _view;
  bool get transparentBackground => _transparentBackground;

  void selectModule(FractalModule module) {
    if (_module.id == module.id) {
      return;
    }
    _module = module;
    _applyPreset(module.defaultPreset);
    notifyListeners();
  }

  void updateParam(String id, Object value) {
    final schema = _module.parameters.firstWhere((param) => param.id == id);
    _params = Map<String, Object>.from(_params);
    _params[id] = _clampValue(schema, value);
    notifyListeners();
  }

  void applyPreset(FractalPreset preset) {
    _applyPreset(preset);
    notifyListeners();
  }

  void resetParams() {
    _applyPreset(_module.defaultPreset);
    notifyListeners();
  }

  void resetView() {
    _view = FractalViewState.initial();
    notifyListeners();
  }

  /// Resets the current "session" state (params + view + transparency)
  /// without changing the selected module.
  void resetSession() {
    _applyPreset(_module.defaultPreset);
    _transparentBackground = false;
    notifyListeners();
  }

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
  }

  void updateZoom(double zoom) {
    _view = _view.copyWith(zoom: zoom.clamp(0.05, 20.0));
    notifyListeners();
  }

  void updatePan(Vector2 pan) {
    _view = _view.copyWith(pan: pan);
    notifyListeners();
  }

  void updateRotation(Vector3 rotation) {
    _view = _view.copyWith(rotation: rotation);
    notifyListeners();
  }

  void setTransparentBackground(bool value) {
    _transparentBackground = value;
    notifyListeners();
  }

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
