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
      final raw = param.min + random.nextDouble() * (param.max - param.min);
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

/// Snaps float randomization to slider step precision while avoiding typical
/// binary floating-point display noise.
double roundFractalParamValueToStep(double value, double step) {
  if (step <= 0) {
    return value;
  }
  final snapped = (value / step).round() * step;
  return double.parse(snapped.toStringAsFixed(6));
}
