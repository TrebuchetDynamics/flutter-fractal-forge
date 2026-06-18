// GENERATED — reviewed Lozi coefficient-map promotions.
// Source: existing-app Lozi metadata aliases with explicit a,b values.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedLoziCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;

  const SharedLoziCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
  });
}

const List<SharedLoziCatalogEntry> sharedLoziCatalogEntries = [
  SharedLoziCatalogEntry(
    id: 'f1095_lozi_classic',
    name: 'Lozi Classic',
    a: 1.7,
    b: 0.5,
  ),
  SharedLoziCatalogEntry(
    id: 'f1096_lozi_saddle',
    name: 'Lozi Saddle',
    a: 1.4,
    b: 0.3,
  ),
  SharedLoziCatalogEntry(
    id: 'f1097_lozi_edge',
    name: 'Lozi Edge',
    a: 1.5,
    b: 0.45,
  ),
  SharedLoziCatalogEntry(
    id: 'f1098_lozi_compact',
    name: 'Lozi Compact',
    a: 1.8,
    b: 0.6,
  ),
  SharedLoziCatalogEntry(
    id: 'f1099_lozi_strange',
    name: 'Lozi Strange',
    a: 1.3,
    b: 0.7,
  ),
  SharedLoziCatalogEntry(
    id: 'f1100_lozi_wide',
    name: 'Lozi Wide',
    a: 2.0,
    b: 0.4,
  ),
];

List<FractalModule> buildSharedLoziCatalogModules() => sharedLoziCatalogEntries
    .map(_buildSharedLoziModule)
    .toList(growable: false);

FractalModule _buildSharedLoziModule(SharedLoziCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 180,
      'bailout': 24.0,
      'colorScheme': 0,
      'a': entry.a,
      'b': entry.b,
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
    shaderAsset: 'shaders/strange_attractors/lozi_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 180, max: 500),
      CommonFractalParams.bailout(defaultValue: 24.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      FractalParameter(
        id: 'a',
        label: (_) => 'a',
        type: FractalParamType.float,
        min: -4,
        max: 4,
        step: 0.01,
        defaultValue: entry.a,
      ),
      FractalParameter(
        id: 'b',
        label: (_) => 'b',
        type: FractalParamType.float,
        min: -2,
        max: 2,
        step: 0.01,
        defaultValue: entry.b,
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
      shader.setFloat(7, readDouble(state.params, 'bailout', 24.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'a', entry.a));
      shader.setFloat(11, readDouble(state.params, 'b', entry.b));
    },
  );
}
