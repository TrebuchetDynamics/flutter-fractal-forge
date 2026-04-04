import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Centralizes schema-driven normalization for controls UI.
///
/// The renderer controller remains the authority for persisted state, but the
/// controls layer should present values consistently with the same schema rules:
/// - invalid raw values fall back safely
/// - numeric values are clamped and step-aligned for slider rendering
/// - labels preserve the precision implied by the parameter step
class FractalControlValueResolver {
  static const int _maxFractionDigits = 6;
  static const int _scrollableEnumThreshold = 8;

  const FractalControlValueResolver._();

  static ResolvedNumericParameter resolveNumeric({
    required FractalParameter parameter,
    required Object rawValue,
  }) {
    assert(
      parameter.type == FractalParamType.float ||
          parameter.type == FractalParamType.integer,
      'resolveNumeric only supports float and integer parameters.',
    );

    final min = math.min(parameter.min, parameter.max);
    final max = math.max(parameter.min, parameter.max);
    final fallbackValue = _fallbackNumericValue(parameter, min: min, max: max);
    final sourceValue =
        rawValue is num ? rawValue.toDouble() : fallbackValue.toDouble();
    final step = parameter.step.abs();
    final sliderValue = _snapToStep(
      value: sourceValue,
      step: step,
      min: min,
      max: max,
    );

    return ResolvedNumericParameter._(
      type: parameter.type,
      min: min,
      max: max,
      step: step,
      sliderValue: sliderValue,
      divisions: _resolveDivisions(min: min, max: max, step: step),
      fractionDigits: parameter.type == FractalParamType.integer
          ? 0
          : step > 0
              ? _fractionDigitsForStep(step)
              : _maxFractionDigits,
    );
  }

  static Object normalizeEnumerationValue({
    required FractalParameter parameter,
    required Object rawValue,
  }) {
    final optionValues =
        parameter.options.map((option) => option.value).toSet();
    if (optionValues.contains(rawValue)) {
      return rawValue;
    }
    if (optionValues.contains(parameter.defaultValue)) {
      return parameter.defaultValue;
    }
    if (parameter.options.isNotEmpty) {
      return parameter.options.first.value;
    }

    return parameter.defaultValue;
  }

  static bool normalizeBooleanValue({
    required FractalParameter parameter,
    required Object rawValue,
  }) {
    if (rawValue is bool) {
      return rawValue;
    }

    final defaultValue = parameter.defaultValue;
    return defaultValue is bool ? defaultValue : false;
  }

  static bool useScrollableOptions(FractalParameter parameter) {
    return parameter.options.length > _scrollableEnumThreshold;
  }

  static num _fallbackNumericValue(
    FractalParameter parameter, {
    required double min,
    required double max,
  }) {
    final defaultValue = parameter.defaultValue;
    if (defaultValue is num) {
      return defaultValue.toDouble().clamp(min, max);
    }

    return min;
  }

  static int? _resolveDivisions({
    required double min,
    required double max,
    required double step,
  }) {
    if (step <= 0) {
      return null;
    }

    final range = max - min;
    if (range <= 0) {
      return null;
    }

    final divisions = (range / step).round();
    return divisions > 0 ? divisions : null;
  }

  static int _fractionDigitsForStep(double step) {
    if (step <= 0) {
      return 0;
    }

    final formatted = step.toStringAsFixed(_maxFractionDigits);
    final decimalPart = formatted.contains('.')
        ? formatted.split('.').last.replaceFirst(RegExp(r'0+$'), '')
        : '';
    return decimalPart.length;
  }

  static double _snapToStep({
    required double value,
    required double step,
    required double min,
    required double max,
  }) {
    final clampedValue = value.clamp(min, max).toDouble();
    if (step <= 0) {
      return double.parse(clampedValue.toStringAsFixed(_maxFractionDigits));
    }

    final snapped = min + (((clampedValue - min) / step).round() * step);
    final bounded = snapped.clamp(min, max).toDouble();
    return double.parse(bounded.toStringAsFixed(_maxFractionDigits));
  }
}

@immutable
class ResolvedNumericParameter {
  final FractalParamType type;
  final double min;
  final double max;
  final double step;
  final double sliderValue;
  final int? divisions;
  final int fractionDigits;

  const ResolvedNumericParameter._({
    required this.type,
    required this.min,
    required this.max,
    required this.step,
    required this.sliderValue,
    required this.divisions,
    required this.fractionDigits,
  });

  String get valueLabel {
    if (type == FractalParamType.integer) {
      return sliderValue.round().toString();
    }

    final formatted = sliderValue.toStringAsFixed(fractionDigits);
    return _trimTrailingZeros(formatted);
  }

  Object valueFromSlider(double rawValue) {
    final clampedValue = rawValue.clamp(min, max).toDouble();
    if (type == FractalParamType.integer) {
      if (step <= 0) {
        return clampedValue.round();
      }

      final snapped = min + (((clampedValue - min) / step).round() * step);
      return snapped.clamp(min, max).round();
    }

    if (step <= 0) {
      return double.parse(clampedValue.toStringAsFixed(fractionDigits));
    }

    final snapped = min + (((clampedValue - min) / step).round() * step);
    final bounded = snapped.clamp(min, max).toDouble();
    return double.parse(bounded.toStringAsFixed(fractionDigits));
  }
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) {
    return value;
  }

  return value.replaceFirst(RegExp(r'\.?0+$'), '');
}
