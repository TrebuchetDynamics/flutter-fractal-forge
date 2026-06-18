// GENERATED — reviewed exact Sprott renderer promotions.
// Source: research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedSprottCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;

  const SharedSprottCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
  });
}

const List<SharedSprottCatalogEntry> sharedSprottCatalogEntries = [
  SharedSprottCatalogEntry(
    id: 'f0014_sprott_a',
    name: 'Sprott A',
    shaderAsset: 'shaders/strange_attractors/sprott_a_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0015_sprott_b',
    name: 'Sprott B',
    shaderAsset: 'shaders/strange_attractors/sprott_b_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0017_sprott_d',
    name: 'Sprott D',
    shaderAsset: 'shaders/strange_attractors/sprott_d_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0018_sprott_e',
    name: 'Sprott E',
    shaderAsset: 'shaders/strange_attractors/sprott_e_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0019_sprott_f',
    name: 'Sprott F',
    shaderAsset: 'shaders/strange_attractors/sprott_f_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0020_sprott_g',
    name: 'Sprott G',
    shaderAsset: 'shaders/strange_attractors/sprott_g_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0021_sprott_h',
    name: 'Sprott H',
    shaderAsset: 'shaders/strange_attractors/sprott_h_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0022_sprott_i',
    name: 'Sprott I',
    shaderAsset: 'shaders/strange_attractors/sprott_i_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0024_sprott_k',
    name: 'Sprott K',
    shaderAsset: 'shaders/strange_attractors/sprott_k_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0025_sprott_l',
    name: 'Sprott L',
    shaderAsset: 'shaders/strange_attractors/sprott_l_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0026_sprott_m',
    name: 'Sprott M',
    shaderAsset: 'shaders/strange_attractors/sprott_m_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0027_sprott_n',
    name: 'Sprott N',
    shaderAsset: 'shaders/strange_attractors/sprott_n_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0028_sprott_o',
    name: 'Sprott O',
    shaderAsset: 'shaders/strange_attractors/sprott_o_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0032_sprott_s',
    name: 'Sprott S',
    shaderAsset: 'shaders/strange_attractors/sprott_s_gpu.frag',
  ),
  SharedSprottCatalogEntry(
    id: 'f0016_sprott_c',
    name: 'Sprott C',
    shaderAsset: 'shaders/strange_attractors/sprott_c_gpu.frag',
  ),
];

List<FractalModule> buildSharedSprottCatalogModules() =>
    sharedSprottCatalogEntries
        .map(_buildSharedSprottModule)
        .toList(growable: false);

FractalModule _buildSharedSprottModule(SharedSprottCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 360,
      'bailout': 8.0,
      'colorScheme': 0,
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
    shaderAsset: entry.shaderAsset,
    parameters: [
      CommonFractalParams.iterations(defaultValue: 360, max: 500),
      CommonFractalParams.bailout(defaultValue: 8.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
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
      shader.setFloat(6, readDouble(state.params, 'iterations', 360));
      shader.setFloat(7, readDouble(state.params, 'bailout', 8.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
