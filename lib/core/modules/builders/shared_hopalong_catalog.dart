// GENERATED — reviewed Martin/Hopalong coefficient-map promotions.
// Source: existing-app Hopalong metadata aliases with explicit a,b,c values.

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedHopalongCatalogEntry {
  final String id;
  final String name;
  final double a;
  final double b;
  final double c;

  const SharedHopalongCatalogEntry({
    required this.id,
    required this.name,
    required this.a,
    required this.b,
    required this.c,
  });
}

const List<SharedHopalongCatalogEntry> sharedHopalongCatalogEntries = [
  SharedHopalongCatalogEntry(
    id: 'f1028_martin_hopalong_classic',
    name: 'Martin Hopalong (Classic)',
    a: 1.0,
    b: 2.0,
    c: 3.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1029_martin_hopalong_wide',
    name: 'Martin Hopalong Wide',
    a: 0.4,
    b: 1.0,
    c: 0.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1030_martin_hopalong_tight',
    name: 'Martin Hopalong Tight',
    a: 5.0,
    b: 1.5,
    c: 10.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1031_martin_hopalong_spiral',
    name: 'Martin Hopalong Spiral',
    a: 2.0,
    b: 1.0,
    c: 5.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1032_martin_hopalong_galaxy',
    name: 'Martin Hopalong Galaxy',
    a: -2.0,
    b: -3.0,
    c: -10.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1033_martin_hopalong_cloud',
    name: 'Martin Hopalong Cloud',
    a: 7.7,
    b: 0.13,
    c: 8.15,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1034_martin_hopalong_diamond',
    name: 'Martin Hopalong Diamond',
    a: -200.0,
    b: 0.1,
    c: -80.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1035_martin_hopalong_spider',
    name: 'Martin Hopalong Spider',
    a: 0.41,
    b: 1.05,
    c: 0.02,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1036_martin_hopalong_crystal',
    name: 'Martin Hopalong Crystal',
    a: 11.0,
    b: 0.05,
    c: 0.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1037_martin_hopalong_mosaic',
    name: 'Martin Hopalong Mosaic',
    a: 7.16878197,
    b: 8.43659746,
    c: 2.55983412,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1038_martin_hopalong_vortex',
    name: 'Martin Hopalong Vortex',
    a: -3.14,
    b: -1.41,
    c: -2.71,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1039_martin_hopalong_storm',
    name: 'Martin Hopalong Storm',
    a: 9.7,
    b: 1.999,
    c: 50.0,
  ),
  SharedHopalongCatalogEntry(
    id: 'f1040_martin_hopalong_rosette',
    name: 'Martin Hopalong Rosette',
    a: 1.4,
    b: 0.13,
    c: 6.9,
  ),
];

List<FractalModule> buildSharedHopalongCatalogModules() =>
    sharedHopalongCatalogEntries
        .map(_buildSharedHopalongModule)
        .toList(growable: false);

FractalModule _buildSharedHopalongModule(SharedHopalongCatalogEntry entry) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 180,
      'bailout': 32.0,
      'colorScheme': 0,
      'a': entry.a,
      'b': entry.b,
      'c': entry.c,
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
    shaderAsset: 'shaders/strange_attractors/hopalong_gpu.frag',
    parameters: [
      CommonFractalParams.iterations(defaultValue: 180, max: 500),
      CommonFractalParams.bailout(defaultValue: 32.0),
      CommonFractalParams.colorScheme64(defaultValue: 0),
      _coefficientParam('a', entry.a, -250, 250),
      _coefficientParam('b', entry.b, -20, 20),
      _coefficientParam('c', entry.c, -100, 100),
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
      shader.setFloat(11, readDouble(state.params, 'b', entry.b));
      shader.setFloat(12, readDouble(state.params, 'c', entry.c));
    },
  );
}

FractalParameter _coefficientParam(
  String id,
  double defaultValue,
  double min,
  double max,
) =>
    FractalParameter(
      id: id,
      label: (_) => id,
      type: FractalParamType.float,
      min: min,
      max: max,
      step: 0.01,
      defaultValue: defaultValue,
    );
