import 'dart:math';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_param_value_normalizer.dart';

/// Generates one randomized value for a fractal parameter schema.
///
/// This pure helper keeps the controller's randomization data flow visible and
/// replayable in tests without depending on FractalController state. Returned
/// values are normalized through the same schema contract used for presets,
/// replayed state, and direct UI updates.
Object randomFractalParamValue(FractalParameter param, Random random) {
  switch (param.type) {
    case FractalParamType.float:
      final raw = _isJuliaSeedParam(param.id)
          ? _randomNearDefault(param, random, radius: 0.35)
          : param.min + random.nextDouble() * (param.max - param.min);
      return normalizeFractalParamValue(
        param,
        roundFractalParamValueToStep(raw, param.step),
      );
    case FractalParamType.integer:
      final bounds = FractalNumericParamBounds.fromSchema(param);
      assert(
        bounds.containsInteger,
        'integer parameter bounds must include at least one integer value',
      );
      if (!bounds.containsInteger) {
        return normalizeFractalParamValue(param, param.defaultValue);
      }
      final min = bounds.min.ceil();
      final max = bounds.max.floor();
      return normalizeFractalParamValue(
        param,
        min + random.nextInt(max - min + 1),
      );
    case FractalParamType.enumeration:
      if (param.options.isNotEmpty) {
        final choice = param.options[random.nextInt(param.options.length)];
        return choice.value;
      }
      return param.defaultValue;
    case FractalParamType.boolean:
      return random.nextBool();
  }
}

bool _isJuliaSeedParam(String id) => id == 'juliaCReal' || id == 'juliaCImag';

double _randomNearDefault(
  FractalParameter param,
  Random random, {
  required double radius,
}) {
  final defaultValue = param.defaultValue;
  final center = defaultValue is num
      ? defaultValue.toDouble()
      : (param.min + param.max) * 0.5;
  return (center + (random.nextDouble() * 2.0 - 1.0) * radius)
      .clamp(param.min, param.max)
      .toDouble();
}

/// Replayable decision for snapping a randomized float to slider precision.
///
/// Parameter schemas are hand-authored across a large catalog. A malformed
/// non-finite step or raw value must not crash randomization before the shared
/// schema normalizer gets a chance to clamp/fallback the value.
final class FractalParamStepSnapPlan {
  final double inputValue;
  final double step;
  final double value;
  final bool appliedStep;

  const FractalParamStepSnapPlan._({
    required this.inputValue,
    required this.step,
    required this.value,
    required this.appliedStep,
  });

  factory FractalParamStepSnapPlan.fromValue({
    required double value,
    required double step,
  }) {
    if (!value.isFinite || !step.isFinite || step <= 0.0) {
      return FractalParamStepSnapPlan._(
        inputValue: value,
        step: step,
        value: value,
        appliedStep: false,
      );
    }

    final snapped = (value / step).round() * step;
    if (!snapped.isFinite) {
      return FractalParamStepSnapPlan._(
        inputValue: value,
        step: step,
        value: value,
        appliedStep: false,
      );
    }

    return FractalParamStepSnapPlan._(
      inputValue: value,
      step: step,
      value: double.parse(snapped.toStringAsFixed(6)),
      appliedStep: true,
    );
  }
}

/// Snaps float randomization to slider step precision while avoiding typical
/// binary floating-point display noise.
double roundFractalParamValueToStep(double value, double step) {
  return FractalParamStepSnapPlan.fromValue(value: value, step: step).value;
}
