// GENERATED — reviewed Clifford attractor coefficient-map promotions.
// Source: existing-app Clifford metadata aliases with explicit a,b,c,d values.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedCliffordCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;
  final double c;
  final double d;

  const SharedCliffordCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

const List<SharedCliffordCatalogEntry> sharedCliffordCatalogEntries = [
  SharedCliffordCatalogEntry(
    id: 'f0338_clifford_tornado',
    name: 'Clifford Tornado',
    a: -1.4,
    b: 1.6,
    c: 1.0,
    d: 0.7,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0339_clifford_butterfly',
    name: 'Clifford Butterfly',
    a: -1.7,
    b: 1.3,
    c: -0.1,
    d: -1.2,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0340_clifford_galaxy',
    name: 'Clifford Galaxy',
    a: 1.7,
    b: 1.7,
    c: 0.6,
    d: 1.2,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0341_clifford_nebula',
    name: 'Clifford Nebula',
    a: -1.8,
    b: -2.0,
    c: -0.5,
    d: -0.9,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0342_clifford_spirals',
    name: 'Clifford Spirals',
    a: -2.0,
    b: -2.0,
    c: -1.2,
    d: 2.0,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0343_clifford_shell',
    name: 'Clifford Shell',
    a: -1.24,
    b: 1.1,
    c: -1.25,
    d: -1.02,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0344_clifford_ribbon',
    name: 'Clifford Ribbon',
    a: 1.5,
    b: -1.8,
    c: 1.6,
    d: 0.9,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0345_clifford_flame',
    name: 'Clifford Flame',
    a: -1.6,
    b: -1.6,
    c: -0.8,
    d: 1.6,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0346_clifford_vortex',
    name: 'Clifford Vortex',
    a: 1.4,
    b: -1.56,
    c: 1.4,
    d: -6.56,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0347_clifford_web',
    name: 'Clifford Web',
    a: 1.7,
    b: 0.7,
    c: 1.2,
    d: 1.8,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0348_clifford_crystal',
    name: 'Clifford Crystal',
    a: -1.3,
    b: -1.3,
    c: -1.8,
    d: 1.8,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0349_clifford_lace',
    name: 'Clifford Lace',
    a: -1.08,
    b: -1.1,
    c: 0.73,
    d: -0.65,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0350_clifford_mist',
    name: 'Clifford Mist',
    a: -0.2,
    b: -1.1,
    c: -0.5,
    d: 1.3,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0351_clifford_star',
    name: 'Clifford Star',
    a: 1.6,
    b: -0.6,
    c: -1.2,
    d: 1.6,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0352_clifford_coral',
    name: 'Clifford Coral',
    a: -1.7,
    b: 1.8,
    c: -1.9,
    d: -0.4,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0353_clifford_rose',
    name: 'Clifford Rose',
    a: 1.5,
    b: 1.5,
    c: 0.5,
    d: 0.5,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0354_clifford_flower',
    name: 'Clifford Flower',
    a: -1.24,
    b: -1.25,
    c: -1.88,
    d: -1.11,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0355_clifford_disk',
    name: 'Clifford Disk',
    a: 2.0,
    b: 2.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0356_clifford_swirl',
    name: 'Clifford Swirl',
    a: -1.9,
    b: -1.9,
    c: 1.3,
    d: -0.9,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0357_clifford_torus',
    name: 'Clifford Torus',
    a: 1.1,
    b: -1.0,
    c: 1.0,
    d: 1.5,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0358_clifford_arms',
    name: 'Clifford Arms',
    a: -1.4,
    b: -1.8,
    c: 0.5,
    d: -1.3,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0359_clifford_knot',
    name: 'Clifford Knot',
    a: 0.5,
    b: -1.3,
    c: 2.0,
    d: -2.1,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0360_clifford_whirl',
    name: 'Clifford Whirl',
    a: -1.6,
    b: 1.8,
    c: 0.8,
    d: 1.4,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0361_clifford_infinity',
    name: 'Clifford Infinity',
    a: -1.38,
    b: 1.5,
    c: 0.51,
    d: -0.9,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0362_clifford_tendrils',
    name: 'Clifford Tendrils',
    a: -1.1,
    b: 2.0,
    c: -1.7,
    d: 1.3,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0363_clifford_moth',
    name: 'Clifford Moth',
    a: -1.6,
    b: -1.5,
    c: 1.0,
    d: 1.0,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0364_clifford_scroll',
    name: 'Clifford Scroll',
    a: 1.4,
    b: 1.5,
    c: -1.3,
    d: 0.9,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0365_clifford_fan',
    name: 'Clifford Fan',
    a: -1.5,
    b: -1.7,
    c: -0.3,
    d: -0.7,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0366_clifford_hearts',
    name: 'Clifford Hearts',
    a: 1.3,
    b: -1.6,
    c: -0.75,
    d: 1.2,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0367_clifford_veil',
    name: 'Clifford Veil',
    a: -1.95,
    b: 1.83,
    c: 0.52,
    d: -0.74,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0368_clifford_ocean',
    name: 'Clifford Ocean',
    a: -2.0,
    b: 1.9,
    c: 0.3,
    d: 1.3,
  ),
  SharedCliffordCatalogEntry(
    id: 'f0369_clifford_dunes',
    name: 'Clifford Dunes',
    a: 1.97,
    b: -1.41,
    c: -0.9,
    d: -1.5,
  ),
];

List<FractalModule> buildSharedCliffordCatalogModules() =>
    sharedCliffordCatalogEntries
        .map(_buildSharedCliffordModule)
        .toList(growable: false);

FractalModule _buildSharedCliffordModule(SharedCliffordCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 220,
      'bailout': 16.0,
      'colorScheme': 0,
      'a': entry.a,
      'b': entry.b,
      'c': entry.c,
      'd': entry.d,
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
    shaderAsset: 'shaders/strange_attractors/clifford_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 220, max: 500),
      CommonFractalParams.bailout(defaultValue: 16.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      _coefficientParam('a', entry.a),
      _coefficientParam('b', entry.b),
      _coefficientParam('c', entry.c),
      _coefficientParam('d', entry.d),
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
      shader.setFloat(7, readDouble(state.params, 'bailout', 16.0));
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(10, readDouble(state.params, 'a', entry.a));
      shader.setFloat(11, readDouble(state.params, 'b', entry.b));
      shader.setFloat(12, readDouble(state.params, 'c', entry.c));
      shader.setFloat(13, readDouble(state.params, 'd', entry.d));
    },
  );
}

FractalParameter _coefficientParam(String id, double defaultValue) =>
    FractalParameter(
      id: id,
      label: (_) => id,
      type: FractalParamType.float,
      min: -3,
      max: 3,
      step: 0.01,
      defaultValue: defaultValue,
    );
