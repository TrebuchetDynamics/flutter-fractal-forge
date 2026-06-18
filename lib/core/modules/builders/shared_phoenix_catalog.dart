// GENERATED — reviewed shared Phoenix renderer promotions.
// Source: research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedPhoenixCatalogEntry {
  final String id;
  final String name;
  final double power;

  const SharedPhoenixCatalogEntry({
    required this.id,
    required this.name,
    required this.power,
  });
}

const List<SharedPhoenixCatalogEntry> sharedPhoenixCatalogEntries = [
  SharedPhoenixCatalogEntry(
      id: 'f0131_phoenix_d_2', name: 'Phoenix d=2', power: 2.0),
  SharedPhoenixCatalogEntry(
      id: 'f0132_phoenix_d_3', name: 'Phoenix d=3', power: 3.0),
  SharedPhoenixCatalogEntry(
      id: 'f0133_phoenix_d_4', name: 'Phoenix d=4', power: 4.0),
];

List<FractalModule> buildSharedPhoenixCatalogModules() =>
    sharedPhoenixCatalogEntries
        .map(_buildSharedPhoenixModule)
        .toList(growable: false);

FractalModule _buildSharedPhoenixModule(SharedPhoenixCatalogEntry entry) {
  const cReal = 0.5667;
  const cImag = 0.0;
  const feedback = -0.5;
  final parameters = [
    CommonFractalParams.iterations(defaultValue: 280),
    CommonFractalParams.bailout(defaultValue: 4.0),
    CommonFractalParams.colorScheme64(defaultValue: 4),
    FractalParameter(
      id: 'phoenixCReal',
      label: (_) => 'Phoenix c real',
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: cReal,
    ),
    FractalParameter(
      id: 'phoenixCImag',
      label: (_) => 'Phoenix c imaginary',
      type: FractalParamType.float,
      min: -1.5,
      max: 1.5,
      step: 0.01,
      defaultValue: cImag,
    ),
    FractalParameter(
      id: 'phoenixP',
      label: (_) => 'Phoenix feedback',
      type: FractalParamType.float,
      min: -1.0,
      max: 1.0,
      step: 0.01,
      defaultValue: feedback,
    ),
    FractalParameter(
      id: 'phoenixPower',
      label: (_) => 'Phoenix degree',
      type: FractalParamType.float,
      min: 2.0,
      max: 8.0,
      step: 1.0,
      defaultValue: entry.power,
    ),
  ];

  final defaultPreset = catalogPreset(
    id: '${entry.id}-default',
    moduleId: entry.id,
    name: 'Default',
    params: {
      'iterations': 280,
      'bailout': 4.0,
      'colorScheme': 4,
      'phoenixCReal': cReal,
      'phoenixCImag': cImag,
      'phoenixP': feedback,
      'phoenixPower': entry.power,
    },
    view: FractalViewState(
      pan: Vector2(-0.5, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
  );

  return FractalModule(
    id: entry.id,
    displayName: (_) => entry.name,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/escape_time_family/core/phoenix_gpu.frag',
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
      shader.setFloat(8, readDouble(state.params, 'colorScheme', 4));
      shader.setFloat(9, readDouble(state.params, 'phoenixCReal', cReal));
      shader.setFloat(10, readDouble(state.params, 'phoenixCImag', cImag));
      shader.setFloat(11, readDouble(state.params, 'phoenixP', feedback));
      shader.setFloat(
          12, readDouble(state.params, 'phoenixPower', entry.power));
      shader.setFloat(13, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
