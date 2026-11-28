import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

FractalModule buildSacksSpiralModule() {
  const id = 'sacks_spiral';
  const palette = 1;
  return FractalModule(
    id: id,
    displayName: (l) => l.moduleSacksSpiral,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/number_theory/sacks_spiral_gpu.frag',
    animationCapability: FractalAnimationCapability.static,
    parameters: [
      FractalParameter(
        id: 'marks',
        label: (l) => l.sacksMarks,
        type: FractalParamType.enumeration,
        control: FractalParamControl.chips,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: 0, label: (l) => l.sacksPrimes),
          FractalParamOption(value: 1, label: (l) => l.sacksPrimesAndSquares),
        ],
      ),
      CommonFractalParams.colorScheme4(defaultValue: palette),
    ],
    defaultPreset: catalogPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Primes',
      params: const {'marks': 0, 'colorScheme': palette},
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

      // Consecutive turns are one plane unit apart, with y up.
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
        ..setFloat(5, choice('marks', 0, 0, 1))
        ..setFloat(6, choice('colorScheme', palette, 0, 3))
        ..setFloat(7, state.transparentBackground ? 1 : 0);
    },
  );
}
