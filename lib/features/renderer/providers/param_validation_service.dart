import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Handles parameter validation and value clamping.
///
/// Responsibilities:
/// - Clamp numeric values to parameter ranges
/// - Validate enumeration selections
/// - Round floats to integers when required
/// - Handle boolean parameter defaults
///
/// Extracted from FractalController to follow Single Responsibility Principle.
class ParamValidationService {
  /// Clamps a value to the parameter's valid range.
  ///
  /// Handles:
  /// - Booleans: returns value or false
  /// - Enumerations: validates against allowed options
  /// - Numbers: clamps to [min, max], rounds for integers
  Object clampValue(FractalParameter schema, Object value) {
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

  /// Finds a parameter by ID in the module's parameter list.
  FractalParameter? findParam(String id, List<FractalParameter> parameters) {
    for (final param in parameters) {
      if (param.id == id) {
        return param;
      }
    }
    return null;
  }

  /// Clamps a map of parameters to their valid ranges.
  ///
  /// Merges with defaults for any missing parameters.
  Map<String, Object> clampParams({
    required List<FractalParameter> parameters,
    required Map<String, Object> values,
  }) {
    final clamped = <String, Object>{};
    for (final param in parameters) {
      final value = values[param.id] ?? param.defaultValue;
      clamped[param.id] = clampValue(param, value);
    }
    return clamped;
  }

  /// Clamps a preset's parameters against module defaults.
  ///
  /// Preset values override defaults, but both are clamped.
  Map<String, Object> clampPresetParams({
    required List<FractalParameter> parameters,
    required Map<String, Object> presetParams,
  }) {
    final defaults = <String, Object>{
      for (final param in parameters) param.id: param.defaultValue,
    };

    final merged = {
      ...defaults,
      ...presetParams,
    };

    return clampParams(parameters: parameters, values: merged);
  }
}
