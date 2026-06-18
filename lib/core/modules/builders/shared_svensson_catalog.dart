// GENERATED — reviewed Svensson attractor coefficient-map promotions.
// Source: existing-app Svensson metadata aliases with explicit a,b,c,d values.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedSvenssonCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;
  final double c;
  final double d;

  const SharedSvenssonCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

const List<SharedSvenssonCatalogEntry> sharedSvenssonCatalogEntries = [
  SharedSvenssonCatalogEntry(
    id: 'f1041_svensson_classic',
    name: 'Svensson Classic',
    a: 1.4,
    b: 1.56,
    c: 1.4,
    d: -6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1042_svensson_bloom',
    name: 'Svensson Bloom',
    a: -2.337,
    b: -2.337,
    c: 0.533,
    d: 1.378,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1043_svensson_storm',
    name: 'Svensson Storm',
    a: -2.0,
    b: 2.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1044_svensson_lace',
    name: 'Svensson Lace',
    a: 1.5,
    b: -1.8,
    c: 1.6,
    d: 0.9,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1045_svensson_iris',
    name: 'Svensson Iris',
    a: -1.78,
    b: -2.05,
    c: -2.55,
    d: -0.53,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1046_svensson_wave',
    name: 'Svensson Wave',
    a: 1.4,
    b: 1.56,
    c: 1.4,
    d: 6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1047_svensson_coral',
    name: 'Svensson Coral',
    a: -1.97,
    b: 1.81,
    c: 0.82,
    d: -1.13,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1048_svensson_eye',
    name: 'Svensson Eye',
    a: -2.0,
    b: -2.0,
    c: -1.2,
    d: 2.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1049_svensson_net',
    name: 'Svensson Net',
    a: 1.4,
    b: 1.56,
    c: -1.4,
    d: -6.56,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1050_svensson_bay',
    name: 'Svensson Bay',
    a: -1.55,
    b: 1.55,
    c: -2.4,
    d: -2.4,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1051_svensson_petals',
    name: 'Svensson Petals',
    a: -2.7,
    b: 5.0,
    c: -1.9,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1052_svensson_arc',
    name: 'Svensson Arc',
    a: 1.0,
    b: 1.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1053_svensson_mandala',
    name: 'Svensson Mandala',
    a: -2.34,
    b: 2.0,
    c: 0.2,
    d: 0.1,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1054_svensson_halo',
    name: 'Svensson Halo',
    a: -2.5,
    b: 5.0,
    c: -1.9,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1055_svensson_cyclone',
    name: 'Svensson Cyclone',
    a: -2.34,
    b: -3.34,
    c: 0.5,
    d: -1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1056_svensson_twist',
    name: 'Svensson Twist',
    a: 1.5,
    b: -2.5,
    c: 1.5,
    d: 0.5,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1057_svensson_disk',
    name: 'Svensson Disk',
    a: 2.0,
    b: 2.0,
    c: 1.0,
    d: 1.0,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1058_svensson_tornado',
    name: 'Svensson Tornado',
    a: -1.4,
    b: 1.6,
    c: 1.0,
    d: 0.7,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1059_svensson_mist',
    name: 'Svensson Mist',
    a: -0.2,
    b: -1.1,
    c: -0.5,
    d: 1.3,
  ),
  SharedSvenssonCatalogEntry(
    id: 'f1060_svensson_fan',
    name: 'Svensson Fan',
    a: -1.5,
    b: -1.7,
    c: -0.3,
    d: -0.7,
  ),
];

List<FractalModule> buildSharedSvenssonCatalogModules() =>
    sharedSvenssonCatalogEntries
        .map(_buildSharedSvenssonModule)
        .toList(growable: false);

FractalModule _buildSharedSvenssonModule(SharedSvenssonCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 220,
      'bailout': 24.0,
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
    shaderAsset: 'shaders/strange_attractors/svensson_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 220, max: 500),
      CommonFractalParams.bailout(defaultValue: 24.0),
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
      shader.setFloat(7, readDouble(state.params, 'bailout', 24.0));
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
      min: -8,
      max: 8,
      step: 0.01,
      defaultValue: defaultValue,
    );
