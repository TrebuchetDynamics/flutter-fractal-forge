// GENERATED — reviewed shared Julia renderer promotions.
// Source: research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedJuliaCatalogEntry {
  final String id;
  final String name;
  final double cReal;
  final double cImag;

  const SharedJuliaCatalogEntry({
    required this.id,
    required this.name,
    required this.cReal,
    required this.cImag,
  });
}

const List<SharedJuliaCatalogEntry> sharedJuliaCatalogEntries = [
  SharedJuliaCatalogEntry(
      id: 'f0143_dendrite_julia',
      name: "Dendrite Julia",
      cReal: 0.0,
      cImag: 1.0),
  SharedJuliaCatalogEntry(
      id: 'f0144_airplane_julia',
      name: "Airplane Julia",
      cReal: -1.7548776662,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0145_seahorse_valley_julia',
      name: "Seahorse Valley Julia",
      cReal: -0.75,
      cImag: 0.1),
  SharedJuliaCatalogEntry(
      id: 'f0146_basilica_julia',
      name: "Basilica Julia",
      cReal: -1.0,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0147_san_marco_julia',
      name: "San Marco Julia",
      cReal: -0.75,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0148_kaleidoscope_julia',
      name: "Kaleidoscope Julia",
      cReal: -0.4,
      cImag: 0.6),
  SharedJuliaCatalogEntry(
      id: 'f0149_cactus_julia', name: "Cactus Julia", cReal: 0.285, cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0150_fatou_dust_julia',
      name: "Fatou Dust Julia",
      cReal: 0.4,
      cImag: 0.4),
  SharedJuliaCatalogEntry(
      id: 'f0151_siegel_disk_julia',
      name: "Siegel Disk Julia",
      cReal: -0.391,
      cImag: -0.587),
  SharedJuliaCatalogEntry(
      id: 'f0152_galaxy_julia',
      name: "Galaxy Julia",
      cReal: 0.285,
      cImag: 0.01),
  SharedJuliaCatalogEntry(
      id: 'f0153_dragon_julia',
      name: "Dragon Julia",
      cReal: -0.8,
      cImag: 0.156),
  SharedJuliaCatalogEntry(
      id: 'f0154_period_3_julia',
      name: "Period-3 Julia",
      cReal: -0.12,
      cImag: 0.74),
  SharedJuliaCatalogEntry(
      id: 'f0155_period_4_julia',
      name: "Period-4 Julia",
      cReal: 0.27334,
      cImag: 0.00742),
  SharedJuliaCatalogEntry(
      id: 'f0156_period_5_julia',
      name: "Period-5 Julia",
      cReal: -0.5046,
      cImag: 0.5631),
  SharedJuliaCatalogEntry(
      id: 'f0157_period_6_julia',
      name: "Period-6 Julia",
      cReal: -1.3107,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0158_period_7_julia',
      name: "Period-7 Julia",
      cReal: 0.4388,
      cImag: 0.3499),
  SharedJuliaCatalogEntry(
      id: 'f0161_swirl_julia', name: "Swirl Julia", cReal: -0.54, cImag: 0.54),
  SharedJuliaCatalogEntry(
      id: 'f0162_lightning_julia',
      name: "Lightning Julia",
      cReal: -0.7269,
      cImag: 0.1889),
  SharedJuliaCatalogEntry(
      id: 'f0163_filigree_julia',
      name: "Filigree Julia",
      cReal: 0.355,
      cImag: 0.355),
  SharedJuliaCatalogEntry(
      id: 'f0164_spiral_julia',
      name: "Spiral Julia",
      cReal: -0.75,
      cImag: 0.11),
  SharedJuliaCatalogEntry(
      id: 'f0166_chebyshev_julia',
      name: "Chebyshev Julia",
      cReal: 2.0,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0167_cauliflower_bulb_julia',
      name: "Cauliflower Bulb Julia",
      cReal: -1.25,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0173_mini_brot_julia',
      name: "Mini-Brot Julia",
      cReal: 0.3,
      cImag: 0.5),
  SharedJuliaCatalogEntry(
      id: 'f0174_elephant_valley_julia',
      name: "Elephant Valley Julia",
      cReal: 0.25,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0175_near_elephant_julia',
      name: "Near-Elephant Julia",
      cReal: 0.251,
      cImag: 0.0001),
  SharedJuliaCatalogEntry(
      id: 'f0176_dendritic_tree_julia',
      name: "Dendritic Tree Julia",
      cReal: -0.8,
      cImag: 0.2),
  SharedJuliaCatalogEntry(
      id: 'f0177_mink_julia', name: "Mink Julia", cReal: -0.12, cImag: -0.77),
  SharedJuliaCatalogEntry(
      id: 'f0178_star_julia',
      name: "Star Julia",
      cReal: -0.835,
      cImag: -0.2321),
  SharedJuliaCatalogEntry(
      id: 'f0180_jumping_jack_julia',
      name: "Jumping Jack Julia",
      cReal: 0.285,
      cImag: -0.01),
  SharedJuliaCatalogEntry(
      id: 'f0181_twin_spiral_julia',
      name: "Twin Spiral Julia",
      cReal: -0.74543,
      cImag: 0.11301),
  SharedJuliaCatalogEntry(
      id: 'f0182_hyperbolic_julia',
      name: "Hyperbolic Julia",
      cReal: -0.1,
      cImag: 0.75),
  SharedJuliaCatalogEntry(
      id: 'f0184_centrally_symmetric_julia',
      name: "Centrally Symmetric Julia",
      cReal: -0.8,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0185_thistle_julia',
      name: "Thistle Julia",
      cReal: -0.1015352,
      cImag: 0.6333312),
  SharedJuliaCatalogEntry(
      id: 'f0186_zig_zag_julia',
      name: "Zig-Zag Julia",
      cReal: -0.39054,
      cImag: -0.58679),
  SharedJuliaCatalogEntry(
      id: 'f0187_spider_julia',
      name: "Spider Julia",
      cReal: -0.235125,
      cImag: 0.827215),
  SharedJuliaCatalogEntry(
      id: 'f0188_flower_julia',
      name: "Flower Julia",
      cReal: 0.38,
      cImag: 0.295),
  SharedJuliaCatalogEntry(
      id: 'f0189_medusa_julia', name: "Medusa Julia", cReal: 0.25, cImag: 0.52),
  SharedJuliaCatalogEntry(
      id: 'f0190_broccoli_julia',
      name: "Broccoli Julia",
      cReal: -0.158,
      cImag: 1.033),
  SharedJuliaCatalogEntry(
      id: 'f0191_spring_julia',
      name: "Spring Julia",
      cReal: -1.04,
      cImag: 0.27),
  SharedJuliaCatalogEntry(
      id: 'f0192_maze_julia', name: "Maze Julia", cReal: 0.37, cImag: 0.1),
  SharedJuliaCatalogEntry(
      id: 'f0193_gossamer_julia',
      name: "Gossamer Julia",
      cReal: -0.162,
      cImag: 1.04),
  SharedJuliaCatalogEntry(
      id: 'f0194_sparse_dust_julia',
      name: "Sparse Dust Julia",
      cReal: 0.6,
      cImag: 0.3),
  SharedJuliaCatalogEntry(
      id: 'f0195_period_8_julia',
      name: "Period-8 Julia",
      cReal: -1.3761,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0196_period_9_julia',
      name: "Period-9 Julia",
      cReal: -1.3811,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0197_near_boundary_julia',
      name: "Near-Boundary Julia",
      cReal: -0.7,
      cImag: 0.3),
  SharedJuliaCatalogEntry(
      id: 'f0198_grainy_julia',
      name: "Grainy Julia",
      cReal: -1.476,
      cImag: 0.0),
  SharedJuliaCatalogEntry(
      id: 'f0199_flying_bird_julia',
      name: "Flying Bird Julia",
      cReal: -0.36,
      cImag: 0.1),
  SharedJuliaCatalogEntry(
      id: 'f0200_infinity_julia',
      name: "Infinity Julia",
      cReal: -1.9,
      cImag: 1e-05),
  SharedJuliaCatalogEntry(
      id: 'f0201_northern_light_julia',
      name: "Northern Light Julia",
      cReal: -0.2209,
      cImag: 0.7448),
  SharedJuliaCatalogEntry(
      id: 'f0202_lacework_julia',
      name: "Lacework Julia",
      cReal: 0.3,
      cImag: -0.5),
];

List<FractalModule> buildSharedJuliaCatalogModules() =>
    sharedJuliaCatalogEntries
        .map(_buildSharedJuliaModule)
        .toList(growable: false);

FractalModule _buildSharedJuliaModule(SharedJuliaCatalogEntry entry) {
  final parameters = [
    CommonFractalParams.iterations(defaultValue: 280),
    CommonFractalParams.bailout(defaultValue: 4.0),
    CommonFractalParams.colorScheme64(defaultValue: 0),
    FractalParameter(
      id: 'juliaCReal',
      label: (_) => 'Julia c real',
      type: FractalParamType.float,
      min: -2.0,
      max: 2.0,
      step: 0.01,
      defaultValue: entry.cReal,
    ),
    FractalParameter(
      id: 'juliaCImag',
      label: (_) => 'Julia c imaginary',
      type: FractalParamType.float,
      min: -2.0,
      max: 2.0,
      step: 0.01,
      defaultValue: entry.cImag,
    ),
  ];

  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 280,
      'bailout': 4.0,
      'colorScheme': 0,
      'juliaCReal': entry.cReal,
      'juliaCImag': entry.cImag,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.25,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/escape_time_family/core/julia_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, readDouble(state.params, 'iterations', 280));
      shader.setFloat(7, readDouble(state.params, 'bailout', 4.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, readDouble(state.params, 'juliaCReal', entry.cReal));
      shader.setFloat(10, readDouble(state.params, 'juliaCImag', entry.cImag));
      shader.setFloat(11, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
