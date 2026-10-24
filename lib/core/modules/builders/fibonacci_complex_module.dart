import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';

import 'built_in_preset_contract.dart';

/// One fixed-c initial-condition slice of H_c on C², not an invariant diagonal.
FractalModule buildFibonacciComplexModule() {
  final preset = catalogPreset(
    id: 'fibonacci-complex-default',
    moduleId: 'fibonacci_complex_julia',
    name: 'Default',
    params: const {
      'iterations': 45,
      'bailout': 4.0,
      'juliaCReal': -0.2,
      'juliaCImag': 0.25,
    },
    view: FractalViewState.initial(),
  );
  return FractalModule(
    id: 'fibonacci_complex_julia',
    displayName: (l10n) => l10n.moduleFibonacciComplexJulia,
    dimension: FractalDimension.twoD,
    animationCapability: FractalAnimationCapability.static,
    shaderAsset:
        'shaders/escape_time_family/polynomial_maps/fibonacci_complex_julia_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 45, min: 1, max: 45),
      CommonFractalParams.bailout(defaultValue: 4),
      for (final real in [true, false])
        FractalParameter(
          id: real ? 'juliaCReal' : 'juliaCImag',
          label: (l10n) => real ? l10n.paramJuliaCReal : l10n.paramJuliaCImag,
          type: FractalParamType.float,
          min: -2,
          max: 2,
          step: .01,
          defaultValue: real ? -.2 : .25,
        ),
    ],
    defaultPreset: preset,
    builtInPresets: [
      preset,
      preset.copyWith(
          id: 'fibonacci-complex-unit-disk',
          name: 'c = 0',
          params: {...preset.params, 'juliaCReal': 0.0, 'juliaCImag': 0.0}),
    ],
    setUniforms: (shader, state, size, time) {
      // Dedicated compact layout, no palette/time-dependent classification.
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      shader.setFloat(2, state.view.pan.x);
      shader.setFloat(3, state.view.pan.y);
      shader.setFloat(4, state.view.zoom);
      shader.setFloat(
          5, readInt(state.params, 'iterations', 45).clamp(1, 45).toDouble());
      shader.setFloat(6, readDouble(state.params, 'bailout', 4));
      shader.setFloat(
          7, readDouble(state.params, 'juliaCReal', -.2).clamp(-2, 2));
      shader.setFloat(
          8, readDouble(state.params, 'juliaCImag', .25).clamp(-2, 2));
      shader.setFloat(9, state.transparentBackground ? 1 : 0);
    },
  );
}
