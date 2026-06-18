// GENERATED — reviewed exact strange-attractor renderer promotions.
// Source: existing-app strange-attractor leads with exact local shader support.

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedExactAttractorCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;

  const SharedExactAttractorCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
  });
}

const List<SharedExactAttractorCatalogEntry>
    sharedExactAttractorCatalogEntries = [
  SharedExactAttractorCatalogEntry(
    id: 'f0047_lorenz_system',
    name: 'Lorenz System',
    shaderAsset: 'shaders/strange_attractors/lorenz_2d_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0050_r_ssler_attractor',
    name: 'Rössler Attractor',
    shaderAsset: 'shaders/strange_attractors/rossler_2d_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0052_chua_s_circuit_double_scroll',
    name: "Chua's Circuit Double Scroll",
    shaderAsset: 'shaders/strange_attractors/chua_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0053_chen_attractor',
    name: 'Chen Attractor',
    shaderAsset: 'shaders/strange_attractors/chen_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0054_l_system',
    name: 'Lü System',
    shaderAsset: 'shaders/strange_attractors/lu_chen_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0055_halvorsen_attractor',
    name: 'Halvorsen Attractor',
    shaderAsset: 'shaders/strange_attractors/halvorsen_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0056_aizawa_attractor',
    name: 'Aizawa Attractor',
    shaderAsset: 'shaders/strange_attractors/aizawa_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0057_thomas_attractor',
    name: 'Thomas Attractor',
    shaderAsset: 'shaders/strange_attractors/thomas_attractor_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0059_shimizu_morioka',
    name: 'Shimizu-Morioka',
    shaderAsset: 'shaders/strange_attractors/shimizu_morioka_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0060_rabinovich_fabrikant',
    name: 'Rabinovich-Fabrikant',
    shaderAsset: 'shaders/strange_attractors/rabinovich_fabrikant_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0061_dadras_attractor',
    name: 'Dadras Attractor',
    shaderAsset: 'shaders/strange_attractors/dadras_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0062_burke_shaw',
    name: 'Burke-Shaw',
    shaderAsset: 'shaders/strange_attractors/burke_shaw_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0063_moore_spiegel',
    name: 'Moore-Spiegel',
    shaderAsset: 'shaders/strange_attractors/moore_spiegel_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0064_newton_leipnik',
    name: 'Newton-Leipnik',
    shaderAsset: 'shaders/strange_attractors/newton_leipnik_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0065_rucklidge_attractor',
    name: 'Rucklidge Attractor',
    shaderAsset: 'shaders/strange_attractors/rucklidge_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0066_wang_sun_attractor',
    name: 'Wang-Sun Attractor',
    shaderAsset: 'shaders/strange_attractors/wang_sun_cang_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0067_arneodo_attractor',
    name: 'Arneodo Attractor',
    shaderAsset: 'shaders/strange_attractors/arneodo_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0068_nos_hoover',
    name: 'Nosé-Hoover',
    shaderAsset: 'shaders/strange_attractors/nose_hoover_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0069_chen_lee',
    name: 'Chen-Lee',
    shaderAsset: 'shaders/strange_attractors/chen_lee_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0070_dequan_li_attractor',
    name: 'Dequan Li Attractor',
    shaderAsset: 'shaders/strange_attractors/dequan_li_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0072_four_wing_chaotic',
    name: 'Four-Wing Chaotic',
    shaderAsset: 'shaders/strange_attractors/four_wing_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0073_liu_chaotic_system',
    name: 'Liu Chaotic System',
    shaderAsset: 'shaders/strange_attractors/liu_chen_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0074_qi_chaotic_system',
    name: 'Qi Chaotic System',
    shaderAsset: 'shaders/strange_attractors/qi_chen_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0075_hadley_circulation',
    name: 'Hadley Circulation',
    shaderAsset: 'shaders/strange_attractors/hadley_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0076_sakarya_attractor',
    name: 'Sakarya Attractor',
    shaderAsset: 'shaders/strange_attractors/sakarya_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0077_bouali_attractor',
    name: 'Bouali Attractor',
    shaderAsset: 'shaders/strange_attractors/bouali_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0078_yu_wang',
    name: 'Yu-Wang',
    shaderAsset: 'shaders/strange_attractors/yu_wang_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0079_genesio_tesi',
    name: 'Genesio-Tesi',
    shaderAsset: 'shaders/strange_attractors/genesio_tesi_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0080_coullet_system',
    name: 'Coullet System',
    shaderAsset: 'shaders/strange_attractors/coullet_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0082_duffing_oscillator_forced',
    name: 'Duffing Oscillator Forced',
    shaderAsset: 'shaders/strange_attractors/duffing_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0203_h_non_map',
    name: 'Hénon Map',
    shaderAsset: 'shaders/strange_attractors/henon_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0204_tinkerbell_map',
    name: 'Tinkerbell Map',
    shaderAsset: 'shaders/strange_attractors/tinkerbell_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0205_lozi_map',
    name: 'Lozi Map',
    shaderAsset: 'shaders/strange_attractors/lozi_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0206_gingerbreadman_map',
    name: 'Gingerbreadman Map',
    shaderAsset: 'shaders/strange_attractors/gingerbreadman_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0207_bogdanov_map',
    name: 'Bogdanov Map',
    shaderAsset: 'shaders/strange_attractors/bogdanov_map_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0208_clifford_attractor',
    name: 'Clifford Attractor',
    shaderAsset: 'shaders/strange_attractors/clifford_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0209_peter_de_jong_attractor',
    name: 'Peter de Jong Attractor',
    shaderAsset: 'shaders/strange_attractors/peter_de_jong_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0210_svensson_attractor',
    name: 'Svensson Attractor',
    shaderAsset: 'shaders/strange_attractors/svensson_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0211_ikeda_map',
    name: 'Ikeda Map',
    shaderAsset: 'shaders/strange_attractors/ikeda_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0212_standard_map_chirikov',
    name: 'Standard Map Chirikov',
    shaderAsset: 'shaders/strange_attractors/standard_map_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0214_zaslavskii_map',
    name: 'Zaslavskii Map',
    shaderAsset: 'shaders/strange_attractors/zaslavsky_gpu.frag',
  ),
  SharedExactAttractorCatalogEntry(
    id: 'f0218_gumowski_mira_map',
    name: 'Gumowski-Mira Map',
    shaderAsset: 'shaders/strange_attractors/gumowski_mira_gpu.frag',
  ),
];

List<FractalModule> buildSharedExactAttractorCatalogModules() =>
    sharedExactAttractorCatalogEntries
        .map(_buildSharedExactAttractorModule)
        .toList(growable: false);

FractalModule _buildSharedExactAttractorModule(
  SharedExactAttractorCatalogEntry entry,
) {
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
      if (entry.shaderAsset == 'shaders/strange_attractors/clifford_gpu.frag') {
        shader.setFloat(10, -1.4);
        shader.setFloat(11, 1.6);
        shader.setFloat(12, 1.0);
        shader.setFloat(13, 0.7);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/svensson_gpu.frag') {
        shader.setFloat(10, 1.5);
        shader.setFloat(11, -1.8);
        shader.setFloat(12, 1.6);
        shader.setFloat(13, 0.9);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/peter_de_jong_gpu.frag') {
        shader.setFloat(10, 1.4);
        shader.setFloat(11, -2.3);
        shader.setFloat(12, 2.4);
        shader.setFloat(13, -2.1);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/lozi_gpu.frag') {
        shader.setFloat(10, 1.7);
        shader.setFloat(11, 0.5);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/tinkerbell_gpu.frag') {
        shader.setFloat(10, 0.9);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/gumowski_mira_gpu.frag') {
        shader.setFloat(10, 0.008);
        shader.setFloat(11, 0.05);
      } else if (entry.shaderAsset ==
          'shaders/strange_attractors/standard_map_gpu.frag') {
        shader.setFloat(10, 0.9);
      }
    },
  );
}
