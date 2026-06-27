// GENERATED — reviewed Gumowski-Mira coefficient-map promotions.
// Source: existing-app Gumowski-Mira metadata aliases. Alias a maps to mu;
// alias b maps to the y^2 scale in the local Gumowski-Mira renderer.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedGumowskiMiraCatalogEntry {
  final String id;
  final String name;
  final double mu;
  final double yScale;

  const SharedGumowskiMiraCatalogEntry({
    required this.id,
    required this.name,
    required this.mu,
    required this.yScale,
  });
}

const List<SharedGumowskiMiraCatalogEntry> sharedGumowskiMiraCatalogEntries = [
  SharedGumowskiMiraCatalogEntry(
    id: 'f0409_gumowski_mira_butterfly',
    name: 'Gumowski-Mira Butterfly',
    mu: 0.008,
    yScale: 0.05,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0410_gumowski_mira_shell',
    name: 'Gumowski-Mira Shell',
    mu: -0.25,
    yScale: 0.0,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0411_gumowski_mira_flowers',
    name: 'Gumowski-Mira Flowers',
    mu: 0.7,
    yScale: 0.9,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0412_gumowski_mira_galaxy',
    name: 'Gumowski-Mira Galaxy',
    mu: -0.48,
    yScale: 0.93,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0413_gumowski_mira_jellyfish',
    name: 'Gumowski-Mira Jellyfish',
    mu: -0.01,
    yScale: 0.05,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0414_gumowski_mira_skulls',
    name: 'Gumowski-Mira Skulls',
    mu: 0.31,
    yScale: 0.05,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0415_gumowski_mira_lamp',
    name: 'Gumowski-Mira Lamp',
    mu: -0.32,
    yScale: 0.12,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0416_gumowski_mira_storm',
    name: 'Gumowski-Mira Storm',
    mu: -0.12,
    yScale: 0.06,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0417_gumowski_mira_peacock',
    name: 'Gumowski-Mira Peacock',
    mu: 0.05,
    yScale: 0.0,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0418_gumowski_mira_octopus',
    name: 'Gumowski-Mira Octopus',
    mu: 0.3,
    yScale: 0.05,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0419_gumowski_mira_spirals',
    name: 'Gumowski-Mira Spirals',
    mu: -0.75,
    yScale: 0.02,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0420_gumowski_mira_propeller',
    name: 'Gumowski-Mira Propeller',
    mu: 0.2,
    yScale: 0.9,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0421_gumowski_mira_lace',
    name: 'Gumowski-Mira Lace',
    mu: -0.45,
    yScale: 0.0,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0422_gumowski_mira_sea_urchin',
    name: 'Gumowski-Mira Sea Urchin',
    mu: -0.99,
    yScale: 0.04,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0423_gumowski_mira_coral_reef',
    name: 'Gumowski-Mira Coral Reef',
    mu: 0.41,
    yScale: 0.00011,
  ),
  SharedGumowskiMiraCatalogEntry(
    id: 'f0424_gumowski_mira_crown',
    name: 'Gumowski-Mira Crown',
    mu: 0.04,
    yScale: 0.01,
  ),
];

List<FractalModule> buildSharedGumowskiMiraCatalogModules() =>
    sharedGumowskiMiraCatalogEntries
        .map(_buildSharedGumowskiMiraModule)
        .toList(growable: false);

FractalModule _buildSharedGumowskiMiraModule(
  SharedGumowskiMiraCatalogEntry entry,
) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 240,
      'bailout': 48.0,
      'colorScheme': 0,
      'mu': entry.mu,
      'yScale': entry.yScale,
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
    shaderAsset: 'shaders/strange_attractors/gumowski_mira_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 240, max: 500),
      CommonFractalParams.bailout(defaultValue: 48.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      FractalParameter(
        id: 'mu',
        label: (_) => 'mu',
        type: FractalParamType.float,
        min: -2,
        max: 2,
        step: 0.001,
        defaultValue: entry.mu,
      ),
      FractalParameter(
        id: 'yScale',
        label: (_) => 'y scale',
        type: FractalParamType.float,
        min: 0,
        max: 1,
        step: 0.001,
        defaultValue: entry.yScale,
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
      shader.setFloat(6, readDouble(state.params, 'iterations', 240));
      shader.setFloat(7, readDouble(state.params, 'bailout', 48.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'mu', entry.mu));
      shader.setFloat(11, readDouble(state.params, 'yScale', entry.yScale));
    },
  );
}
