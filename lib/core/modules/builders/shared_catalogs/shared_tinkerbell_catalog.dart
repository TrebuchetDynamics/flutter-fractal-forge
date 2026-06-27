// GENERATED — reviewed Tinkerbell coefficient-map promotions.
// Source: existing-app Tinkerbell metadata aliases with explicit a values;
// b=-0.6013, c=2.0, d=0.5 are the canonical shader constants.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedTinkerbellCatalogEntry {
  final String id;
  final String name;
  final double a;

  const SharedTinkerbellCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
  });
}

const List<SharedTinkerbellCatalogEntry> sharedTinkerbellCatalogEntries = [
  SharedTinkerbellCatalogEntry(
    id: 'f1077_tinkerbell_classic',
    name: 'Tinkerbell Classic',
    a: 0.9,
  ),
  SharedTinkerbellCatalogEntry(
    id: 'f1078_tinkerbell_distorted',
    name: 'Tinkerbell Distorted',
    a: 0.3,
  ),
  SharedTinkerbellCatalogEntry(
    id: 'f1079_tinkerbell_wing',
    name: 'Tinkerbell Wing',
    a: 0.7,
  ),
  SharedTinkerbellCatalogEntry(
    id: 'f1080_tinkerbell_ring',
    name: 'Tinkerbell Ring',
    a: 0.4,
  ),
];

List<FractalModule> buildSharedTinkerbellCatalogModules() =>
    sharedTinkerbellCatalogEntries
        .map(_buildSharedTinkerbellModule)
        .toList(growable: false);

FractalModule _buildSharedTinkerbellModule(
  SharedTinkerbellCatalogEntry entry,
) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 180,
      'bailout': 32.0,
      'colorScheme': 0,
      'a': entry.a,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 0.65,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/strange_attractors/tinkerbell_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 180, max: 500),
      CommonFractalParams.bailout(defaultValue: 32.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      FractalParameter(
        id: 'a',
        label: (_) => 'a',
        type: FractalParamType.float,
        min: -2,
        max: 2,
        step: 0.01,
        defaultValue: entry.a,
      ),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, readDouble(state.params, 'iterations', 180));
      shader.setFloat(7, readDouble(state.params, 'bailout', 32.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'a', entry.a));
    },
  );
}
