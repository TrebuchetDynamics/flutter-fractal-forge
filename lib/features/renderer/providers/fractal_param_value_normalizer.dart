import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Numeric bounds derived from a [FractalParameter] schema.
///
/// Integer schemas store bounds as doubles because they share the numeric
/// parameter contract with float sliders. [containsInteger] exposes the hidden
/// assumption that those double bounds still include at least one valid integer
/// value before integer rounding is applied.
final class FractalNumericParamBounds {
  const FractalNumericParamBounds({
    required this.min,
    required this.max,
  });

  factory FractalNumericParamBounds.fromSchema(FractalParameter schema) {
    return FractalNumericParamBounds(min: schema.min, max: schema.max);
  }

  final double min;
  final double max;

  bool get hasFiniteOrderedRange => min.isFinite && max.isFinite && min <= max;

  bool get containsInteger =>
      hasFiniteOrderedRange && min.ceil() <= max.floor();

  double? tryNormalizeFloat(double value) {
    if (!hasFiniteOrderedRange) return null;
    return value.clamp(min, max).toDouble();
  }

  int? tryNormalizeInteger(double value) {
    if (!containsInteger) return null;
    final rounded = tryNormalizeFloat(value)!.round();
    return rounded.clamp(min.ceil(), max.floor()).toInt();
  }

  double normalizeFloat(double value) {
    assert(
      hasFiniteOrderedRange,
      'numeric parameter bounds must be finite and ordered',
    );
    return tryNormalizeFloat(value) ?? value;
  }

  int normalizeInteger(double value) {
    assert(
      containsInteger,
      'integer parameter bounds must include at least one integer value',
    );
    return tryNormalizeInteger(value) ?? value.round();
  }
}

/// Normalizes raw parameter values against a module parameter schema.
///
/// This keeps replayed state, presets, and direct UI updates on the same
/// contract: finite numeric values clamp to schema bounds after type coercion,
/// enum values must be one of the declared options, booleans must be real
/// booleans, and non-finite numeric values fall back to the schema default
/// instead of being promoted to an arbitrary bound.
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
    final bounds = FractalNumericParamBounds.fromSchema(schema);
    if (schema.type == FractalParamType.integer) {
      return bounds.tryNormalizeInteger(numericValue) ?? schema.defaultValue;
    }
    return bounds.tryNormalizeFloat(numericValue) ?? schema.defaultValue;
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
