import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Normalizes raw parameter values against a module parameter schema.
///
/// This keeps replayed state, presets, and direct UI updates on the same
/// contract: finite numeric values clamp to schema bounds, enum values must be
/// one of the declared options, booleans must be real booleans, and non-finite
/// numeric values fall back to the schema default instead of being promoted to
/// an arbitrary bound.
Object normalizeFractalParamValue(FractalParameter schema, Object value) {
  if (schema.type == FractalParamType.boolean) {
    return value is bool ? value : _booleanDefault(schema);
  }
  if (schema.type == FractalParamType.enumeration) {
    final optionValues = schema.options.map((option) => option.value).toSet();
    return optionValues.contains(value) ? value : schema.defaultValue;
  }

  final numericValue = _finiteNumericValue(value);
  if (numericValue != null) {
    final clamped = numericValue.clamp(schema.min, schema.max);
    if (schema.type == FractalParamType.integer) {
      return clamped.round();
    }
    return clamped;
  }
  return schema.defaultValue;
}

double? _finiteNumericValue(Object value) {
  if (value is! num) return null;
  final numericValue = value.toDouble();
  return numericValue.isFinite ? numericValue : null;
}

bool _booleanDefault(FractalParameter schema) {
  final defaultValue = schema.defaultValue;
  return defaultValue is bool ? defaultValue : false;
}
