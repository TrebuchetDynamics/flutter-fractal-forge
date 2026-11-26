import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

/// At 1x with no pan, the canvas centre is 1/2 + 25i. Each complex unit
/// occupies min(width, height) / 29 pixels on either axis, with Im(s) up.
FractalModule buildZetaCriticalStripModule() {
  const id = 'zeta_critical_strip';
  return FractalModule(
    id: id,
    displayName: (l) => l.moduleZetaCriticalStrip,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/number_theory/zeta_critical_strip_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'contours',
        label: (l) => l.zetaContours,
        type: FractalParamType.enumeration,
        control: FractalParamControl.chips,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 1,
        options: [
          FractalParamOption(value: 0, label: (l) => l.zetaPhaseOnly),
          FractalParamOption(value: 1, label: (l) => l.zetaPhaseAndModulus),
        ],
      ),
      FractalParameter(
        id: 'guides',
        label: (l) => l.zetaGuides,
        type: FractalParamType.boolean,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: true,
      ),
    ],
    defaultPreset: catalogPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Critical strip',
      params: const {'contours': 1, 'guides': true},
      view: FractalViewState.initial(),
    ),
    builtInPresets: const [],
    setUniforms: (shader, state, size, _) {
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, state.view.pan.x)
        ..setFloat(3, state.view.pan.y)
        ..setFloat(4, state.view.zoom)
        ..setFloat(5, state.params['contours'] == 0 ? 0 : 1)
        ..setFloat(6, state.params['guides'] == false ? 0 : 1);
    },
  );
}
