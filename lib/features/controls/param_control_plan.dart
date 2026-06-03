import 'dart:math';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Replayable presentation and update contract for numeric parameter controls.
///
/// The controls sheet receives dynamic `Object` values from controller state.
/// Keeping slider normalization, label formatting, division calculation, and
/// emitted values together prevents the visible label from drifting away from
/// the clamped slider position when stale/replayed values are malformed.
final class NumericParamControlPlan {
  const NumericParamControlPlan._({
    required this.type,
    required this.range,
    required this.value,
    required this.divisions,
    required this.valueLabel,
    required this.floatPrecision,
  });

  factory NumericParamControlPlan.fromParam({
    required FractalParameter param,
    required Object value,
  }) {
    assert(
      param.type == FractalParamType.float ||
          param.type == FractalParamType.integer,
      'NumericParamControlPlan only supports numeric parameter types',
    );

    final range = NumericParamControlRange.fromParam(param);
    final rawValue = _finiteNumericValue(value) ??
        _finiteNumericValue(param.defaultValue) ??
        range.min;
    final sliderValue = range.clamp(rawValue);
    final floatPrecision = NumericParamFloatPrecision.fromStep(param.step);

    return NumericParamControlPlan._(
      type: param.type,
      range: range,
      value: sliderValue,
      divisions: range.divisionsForStep(param.step),
      valueLabel: _labelFor(
        type: param.type,
        range: range,
        sliderValue: sliderValue,
        floatPrecision: floatPrecision,
      ),
      floatPrecision: floatPrecision,
    );
  }

  final FractalParamType type;
  final NumericParamControlRange range;

  /// Clamped finite value that is safe to pass to [Slider.value].
  final double value;

  /// Slider divisions, or null when the schema step cannot form divisions.
  final int? divisions;

  /// Label for the same normalized value shown by the slider.
  final String valueLabel;

  /// Float formatting/emission precision derived from the schema step.
  final NumericParamFloatPrecision floatPrecision;

  double get min => range.min;
  double get max => range.max;

  Object valueForSliderPosition(double sliderPosition) {
    final clamped = range.clamp(sliderPosition);
    return switch (type) {
      FractalParamType.integer => range.integerValueFor(clamped),
      FractalParamType.float => floatPrecision.round(clamped),
      FractalParamType.boolean || FractalParamType.enumeration => clamped,
    };
  }

  static String _labelFor({
    required FractalParamType type,
    required NumericParamControlRange range,
    required double sliderValue,
    required NumericParamFloatPrecision floatPrecision,
  }) {
    if (type == FractalParamType.integer) {
      return range.integerValueFor(sliderValue).toString();
    }
    return floatPrecision.format(sliderValue);
  }

  static double? _finiteNumericValue(Object value) {
    if (value is! num) return null;
    final numericValue = value.toDouble();
    return numericValue.isFinite ? numericValue : null;
  }
}

/// Sanitized numeric range for a parameter slider.
final class NumericParamControlRange {
  const NumericParamControlRange({
    required this.min,
    required this.max,
  });

  factory NumericParamControlRange.fromParam(FractalParameter param) {
    final safeMin = param.min.isFinite ? param.min : 0.0;
    final safeMax = param.max.isFinite ? param.max : safeMin;

    if (safeMin <= safeMax) {
      return NumericParamControlRange(min: safeMin, max: safeMax);
    }
    return NumericParamControlRange(min: safeMax, max: safeMin);
  }

  final double min;
  final double max;

  double get span => max - min;

  double clamp(double value) {
    if (!value.isFinite) return min;
    return value.clamp(min, max).toDouble();
  }

  int? divisionsForStep(double step) {
    if (span <= 0.0 || !step.isFinite || step <= 0.0) return null;

    final rawDivisions = span / step;
    if (!rawDivisions.isFinite) return null;

    final divisions = rawDivisions.round();
    return divisions > 0 ? divisions : null;
  }

  int integerValueFor(double sliderPosition) {
    final rounded = clamp(sliderPosition).round();
    final lower = min.ceil();
    final upper = max.floor();
    if (lower > upper) return rounded;
    return rounded.clamp(lower, upper).toInt();
  }
}

/// Float label/update precision derived from a slider schema step.
///
/// The old control contract used a hard-coded two decimal places for every
/// float. Some module parameters declare finer steps (for example 0.001), so
/// replayed slider positions must retain at least the precision the schema
/// promises while preserving the existing two-decimal minimum for coarser
/// controls.
final class NumericParamFloatPrecision {
  static const int defaultFractionDigits = 2;
  static const int maxFractionDigits = 12;
  static const double _integerTolerance = 1e-9;

  const NumericParamFloatPrecision._(this.fractionDigits);

  factory NumericParamFloatPrecision.fromStep(double step) {
    if (!step.isFinite || step <= 0.0 || step >= 1.0) {
      return const NumericParamFloatPrecision._(defaultFractionDigits);
    }

    for (var digits = defaultFractionDigits;
        digits <= maxFractionDigits;
        digits++) {
      final scale = pow(10.0, digits).toDouble();
      final scaledStep = step * scale;
      if (!scaledStep.isFinite) break;
      if ((scaledStep - scaledStep.round()).abs() <= _integerTolerance) {
        return NumericParamFloatPrecision._(digits);
      }
    }

    return const NumericParamFloatPrecision._(defaultFractionDigits);
  }

  final int fractionDigits;

  double round(double value) => double.parse(format(value));

  String format(double value) => value.toStringAsFixed(fractionDigits);
}
