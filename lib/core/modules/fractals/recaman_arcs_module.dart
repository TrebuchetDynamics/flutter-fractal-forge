import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

FractalModule buildRecamanArcsModule() {
  const id = 'recaman_arcs';
  const terms = 64;
  const lineWidth = 1.5;
  const palette = 2;
  return FractalModule(
    id: id,
    displayName: (l) => l.moduleRecamanArcs,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/number_theory/recaman_arcs_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'terms',
        label: (l) => l.recamanTerms,
        type: FractalParamType.integer,
        min: 8,
        max: 128,
        step: 1,
        defaultValue: terms,
      ),
      FractalParameter(
        id: 'lineWidth',
        label: (l) => l.recamanLineWidth,
        type: FractalParamType.float,
        min: .5,
        max: 4,
        step: .1,
        defaultValue: lineWidth,
      ),
      FractalParameter(
        id: 'layout',
        label: (l) => l.recamanLayout,
        type: FractalParamType.enumeration,
        control: FractalParamControl.chips,
        min: 0,
        max: 1,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: 0, label: (l) => l.recamanAlternating),
          FractalParamOption(value: 1, label: (l) => l.recamanAllAbove),
        ],
      ),
      CommonFractalParams.colorScheme4(defaultValue: palette),
    ],
    defaultPreset: catalogPreset(
      id: '$id-default',
      moduleId: id,
      name: 'Alternating arcs',
      params: const {
        'terms': terms,
        'lineWidth': lineWidth,
        'layout': 0,
        'colorScheme': palette,
      },
      view: FractalViewState.initial(),
    ),
    builtInPresets: const [],
    setUniforms: (shader, state, size, _) {
      double value(String key, double fallback, double min, double max) {
        final raw = state.params[key];
        return raw is num && raw.isFinite
            ? raw.toDouble().clamp(min, max)
            : fallback;
      }

      final pan = state.view.pan;
      shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, pan.x)
        ..setFloat(3, pan.y)
        ..setFloat(4, state.view.zoom)
        ..setFloat(5, value('terms', terms.toDouble(), 8, 128).roundToDouble())
        ..setFloat(6, value('lineWidth', lineWidth, .5, 4))
        ..setFloat(7, value('layout', 0, 0, 1).roundToDouble())
        ..setFloat(
            8, value('colorScheme', palette.toDouble(), 0, 3).roundToDouble())
        ..setFloat(9, state.transparentBackground ? 1 : 0);
    },
  );
}
