import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

FractalModule buildUlamSpiralModule() {
  const id = 'ulam_spiral';
  const start = 1;
  const palette = 1;
  return FractalModule(
    id: id,
    displayName: (l) => l.moduleUlamSpiral,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/number_theory/ulam_spiral_gpu.frag',
    animationCapability: FractalAnimationCapability.static,
    parameters: [
      FractalParameter(
        id: 'startValue',
        label: (l) => l.ulamStartValue,
        type: FractalParamType.integer,
        min: 1,
        max: 100,
        step: 1,
        defaultValue: start,
      ),
      FractalParameter(
        id: 'pattern',
        label: (l) => l.ulamPattern,
        type: FractalParamType.enumeration,
        control: FractalParamControl.chips,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: 0, label: (l) => l.ulamPrimes),
          FractalParamOption(value: 1, label: (l) => l.ulamRandom),
        ],
      ),
      CommonFractalParams.colorScheme4(defaultValue: palette),
    ],
    defaultPreset: catalogPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Primes',
      params: const {'startValue': start, 'pattern': 0, 'colorScheme': palette},
      view: FractalViewState.initial(),
    ),
    builtInPresets: const [],
    setUniforms: (shader, state, size, _) {
      double choice(String key, int fallback, int min, int max) {
        final raw = state.params[key];
        return raw is num && raw.isFinite
            ? raw.clamp(min, max).roundToDouble()
            : fallback.toDouble();
      }

      // Cells are one plane unit, centred at integer coordinates with y up.
      // Pixels per unit = zoom * min(width, height) / 203. At the viewport
      // centre the plane point is (203 * pan.x, -203 * pan.y), independent
      // of zoom. This preserves the viewer's drag direction and pan units.
      final pan = state.view.pan;
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, pan.x)
        ..setFloat(3, pan.y)
        ..setFloat(4, state.view.zoom)
        ..setFloat(5, choice('startValue', start, 1, 100))
        ..setFloat(6, choice('pattern', 0, 0, 1))
        ..setFloat(7, choice('colorScheme', palette, 0, 3))
        ..setFloat(8, state.transparentBackground ? 1 : 0);
    },
  );
}
