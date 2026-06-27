// GENERATED — reviewed Quaternion Julia renderer promotions.
// Source: research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedQuaternionJuliaCatalogEntry {
  final String id;
  final String name;
  final double c0;
  final double c1;
  final double c2;
  final double c3;

  const SharedQuaternionJuliaCatalogEntry({
    required this.id,
    required this.name,
    required this.c0,
    required this.c1,
    required this.c2,
    required this.c3,
  });
}

const List<SharedQuaternionJuliaCatalogEntry>
    sharedQuaternionJuliaCatalogEntries = [
  SharedQuaternionJuliaCatalogEntry(
    id: 'f0540_quaternion_julia_0_2_0_8_0_0_0_0',
    name: 'Quaternion Julia c=(-0.2, 0.8, 0, 0)',
    c0: -0.2,
    c1: 0.8,
    c2: 0.0,
    c3: 0.0,
  ),
  SharedQuaternionJuliaCatalogEntry(
    id: 'f0544_quaternion_julia_0_291_0_399_0_339_0_437',
    name: 'Quaternion Julia c=(0.291, 0.399, 0.339, 0.437)',
    c0: 0.291,
    c1: 0.399,
    c2: 0.339,
    c3: 0.437,
  ),
  SharedQuaternionJuliaCatalogEntry(
    id: 'f0545_quaternion_julia_0_08_0_0_0_8_0_0',
    name: 'Quaternion Julia c=(0.08, 0, 0.8, 0)',
    c0: 0.08,
    c1: 0.0,
    c2: 0.8,
    c3: 0.0,
  ),
];

List<FractalModule> buildSharedQuaternionJuliaCatalogModules() =>
    sharedQuaternionJuliaCatalogEntries
        .map(_buildSharedQuaternionJuliaModule)
        .toList(growable: false);

FractalModule _buildSharedQuaternionJuliaModule(
  SharedQuaternionJuliaCatalogEntry entry,
) {
  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'power': 2.0,
      'iterations': 14,
      'steps': 120,
      'bailout': 4.0,
      'colorScheme': 0,
      'c0': entry.c0,
      'c1': entry.c1,
      'c2': entry.c2,
      'c3': entry.c3,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3(0.3, -0.4, 0.0),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.threeD,
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'power',
        label: (_) => 'Power',
        type: FractalParamType.float,
        min: 0.2,
        max: 4.0,
        step: 0.1,
        defaultValue: 2.0,
      ),
      CommonFractalParams.iterations(defaultValue: 14, min: 4, max: 20),
      FractalParameter(
        id: 'steps',
        label: (l10n) => l10n.paramSteps,
        type: FractalParamType.integer,
        min: 20,
        max: 200,
        step: 1,
        defaultValue: 120,
      ),
      CommonFractalParams.bailout(defaultValue: 4.0, min: 1.0, max: 8.0),
      CommonFractalParams.colorScheme4(defaultValue: 0),
      _cParam('c0', entry.c0),
      _cParam('c1', entry.c1),
      _cParam('c2', entry.c2),
      _cParam('c3', entry.c3),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, 0.0);
      shader.setFloat(4, 0.0);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, state.view.rotation.x);
      shader.setFloat(7, state.view.rotation.y);
      shader.setFloat(8, state.view.rotation.z);
      shader.setFloat(9, readDouble(state.params, 'power', 2.0));
      shader.setFloat(10, readDouble(state.params, 'iterations', 14));
      shader.setFloat(11, readDouble(state.params, 'steps', 120));
      shader.setFloat(12, readDouble(state.params, 'bailout', 4.0));
      shader.setFloat(13, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(14, -1.0);
      shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(16, readDouble(state.params, 'c0', entry.c0));
      shader.setFloat(17, readDouble(state.params, 'c1', entry.c1));
      shader.setFloat(18, readDouble(state.params, 'c2', entry.c2));
      shader.setFloat(19, readDouble(state.params, 'c3', entry.c3));
    },
  );
}

FractalParameter _cParam(String id, double defaultValue) => FractalParameter(
      id: id,
      label: (_) => id,
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.001,
      defaultValue: defaultValue,
    );
