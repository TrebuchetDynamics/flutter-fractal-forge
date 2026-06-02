import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Normalizes raw parameter values against a module parameter schema.
///
/// This keeps replayed state, presets, and direct UI updates on the same
/// contract: numeric values clamp to schema bounds, enum values must be one of
/// the declared options, booleans must be real booleans, and NaN falls back to
/// the schema default instead of being promoted to an arbitrary bound.
Object normalizeFractalParamValue(FractalParameter schema, Object value) {
  if (schema.type == FractalParamType.boolean) {
    return value is bool ? value : _booleanDefault(schema);
  }
  if (schema.type == FractalParamType.enumeration) {
    final optionValues = schema.options.map((option) => option.value).toSet();
    return optionValues.contains(value) ? value : schema.defaultValue;
  }
  if (value is num) {
    final numericValue = value.toDouble();
    if (numericValue.isNaN) {
      return schema.defaultValue;
    }

    final clamped = numericValue.clamp(schema.min, schema.max);
    if (schema.type == FractalParamType.integer) {
      return clamped.round();
    }
    return clamped;
  }
  return schema.defaultValue;
}

bool _booleanDefault(FractalParameter schema) {
  final defaultValue = schema.defaultValue;
  return defaultValue is bool ? defaultValue : false;
}
