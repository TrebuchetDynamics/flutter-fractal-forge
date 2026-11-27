import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

import 'langton_ant_frame.dart';

FractalModule buildLangtonAntModule() {
  final presets = [
    for (final rule in langtonAntRules)
      FractalPreset(
        id: 'langton_ant-$rule',
        moduleId: 'langton_ant',
        name: rule,
        params: {
          'rule': rule,
          'steps': langtonAntDefaultSteps,
          'colorScheme': 0
        },
        view: FractalViewState.initial(),
        createdAt: DateTime.utc(2026),
        isBuiltIn: true,
      ),
  ];
  return FractalModule(
    id: 'langton_ant',
    displayName: (_) => "Langton's Ant",
    dimension: FractalDimension.twoD,
    hidesEffectControls: true,
    animationCapability: FractalAnimationCapability.stepDriven,
    shaderAsset: '',
    parameters: [
      FractalParameter(
        id: 'rule',
        label: (l10n) => l10n.langtonAntRule,
        type: FractalParamType.turnRule,
        min: 2,
        max: 20,
        step: 1,
        defaultValue: langtonAntRules.first,
      ),
      FractalParameter(
        id: 'steps',
        label: (l10n) => l10n.paramSteps,
        type: FractalParamType.integer,
        min: 0,
        max: langtonAntMaxSteps.toDouble(),
        step: 1,
        defaultValue: langtonAntDefaultSteps,
      ),
      CommonFractalParams.colorScheme64(),
    ],
    defaultPreset: presets.first,
    builtInPresets: presets,
    setUniforms: (shader, state, size, time) {},
  );
}
