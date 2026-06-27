// GENERATED — reviewed Standard Map coefficient promotions.
// Source: existing-app Standard Map metadata aliases with explicit K values.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedStandardMapCatalogEntry {
  final String id;
  final String name;
  final double k;

  const SharedStandardMapCatalogEntry({
    required this.id,
    required this.name,
    required this.k,
  });
}

const List<SharedStandardMapCatalogEntry> sharedStandardMapCatalogEntries = [
  SharedStandardMapCatalogEntry(
    id: 'f0821_standard_map_chirikov_k_0_97',
    name: 'Standard Map (Chirikov K=0.97)',
    k: 0.97,
  ),
  SharedStandardMapCatalogEntry(
    id: 'f0822_standard_map_k_2_0',
    name: 'Standard Map K=2.0',
    k: 2.0,
  ),
  SharedStandardMapCatalogEntry(
    id: 'f0823_standard_map_k_6_0',
    name: 'Standard Map K=6.0',
    k: 6.0,
  ),
];

List<FractalModule> buildSharedStandardMapCatalogModules() =>
    sharedStandardMapCatalogEntries
        .map(_buildSharedStandardMapModule)
        .toList(growable: false);

FractalModule _buildSharedStandardMapModule(
  SharedStandardMapCatalogEntry entry,
) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 220,
      'bailout': 12.0,
      'colorScheme': 0,
      'k': entry.k,
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
    shaderAsset: 'shaders/strange_attractors/standard_map_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 220, max: 500),
      CommonFractalParams.bailout(defaultValue: 12.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      FractalParameter(
        id: 'k',
        label: (_) => 'K',
        type: FractalParamType.float,
        min: 0,
        max: 8,
        step: 0.01,
        defaultValue: entry.k,
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
      shader.setFloat(6, readDouble(state.params, 'iterations', 220));
      shader.setFloat(7, readDouble(state.params, 'bailout', 12.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'k', entry.k));
    },
  );
}
