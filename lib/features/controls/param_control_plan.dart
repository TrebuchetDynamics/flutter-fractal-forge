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

    return NumericParamControlPlan._(
      type: param.type,
      range: range,
      value: sliderValue,
      divisions: range.divisionsForStep(param.step),
      valueLabel: _labelFor(
        type: param.type,
        range: range,
        sliderValue: sliderValue,
      ),
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

  double get min => range.min;
  double get max => range.max;

  Object valueForSliderPosition(double sliderPosition) {
    final clamped = range.clamp(sliderPosition);
    return switch (type) {
      FractalParamType.integer => range.integerValueFor(clamped),
      FractalParamType.float => double.parse(clamped.toStringAsFixed(2)),
      FractalParamType.boolean || FractalParamType.enumeration => clamped,
    };
  }

  static String _labelFor({
    required FractalParamType type,
    required NumericParamControlRange range,
    required double sliderValue,
  }) {
    if (type == FractalParamType.integer) {
      return range.integerValueFor(sliderValue).toString();
    }
    return sliderValue.toStringAsFixed(2);
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
