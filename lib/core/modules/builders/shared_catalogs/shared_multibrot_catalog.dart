// GENERATED — reviewed Multibrot renderer promotions.
// Source: research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

class SharedMultibrotCatalogEntry {
  final String id;
  final String name;
  final double power;

  const SharedMultibrotCatalogEntry(
      {required this.id, required this.name, required this.power});
}

const List<SharedMultibrotCatalogEntry> sharedMultibrotCatalogEntries = [
  SharedMultibrotCatalogEntry(
      id: 'f0135_mandelbrot_power_d_1_25',
      name: 'Mandelbrot power d=1.25',
      power: 1.25),
  SharedMultibrotCatalogEntry(
      id: 'f0134_mandelbrot_power_d_2_7',
      name: 'Mandelbrot power d=2.7',
      power: 2.7),
  SharedMultibrotCatalogEntry(
      id: 'f0096_multibrot_d_0_5', name: "Multibrot d=0.5", power: 0.5),
  SharedMultibrotCatalogEntry(
      id: 'f0097_multibrot_d_3_5', name: "Multibrot d=3.5", power: 3.5),
  SharedMultibrotCatalogEntry(
      id: 'f0098_multibrot_d_4_5', name: "Multibrot d=4.5", power: 4.5),
  SharedMultibrotCatalogEntry(
      id: 'f0099_multibrot_d_5_5', name: "Multibrot d=5.5", power: 5.5),
  SharedMultibrotCatalogEntry(
      id: 'f0100_multibrot_d_6_5', name: "Multibrot d=6.5", power: 6.5),
  SharedMultibrotCatalogEntry(
      id: 'f0101_multibrot_d_7_5', name: "Multibrot d=7.5", power: 7.5),
  SharedMultibrotCatalogEntry(
      id: 'f0102_multibrot_d_8_5', name: "Multibrot d=8.5", power: 8.5),
  SharedMultibrotCatalogEntry(
      id: 'f0088_multibrot_z_13', name: "Multibrot z^13", power: 13.0),
  SharedMultibrotCatalogEntry(
      id: 'f0089_multibrot_z_14', name: "Multibrot z^14", power: 14.0),
  SharedMultibrotCatalogEntry(
      id: 'f0090_multibrot_z_15', name: "Multibrot z^15", power: 15.0),
  SharedMultibrotCatalogEntry(
      id: 'f0091_multibrot_z_16', name: "Multibrot z^16", power: 16.0),
  SharedMultibrotCatalogEntry(
      id: 'f0092_multibrot_z_17', name: "Multibrot z^17", power: 17.0),
  SharedMultibrotCatalogEntry(
      id: 'f0093_multibrot_z_18', name: "Multibrot z^18", power: 18.0),
  SharedMultibrotCatalogEntry(
      id: 'f0094_multibrot_z_19', name: "Multibrot z^19", power: 19.0),
  SharedMultibrotCatalogEntry(
      id: 'f0095_multibrot_z_20', name: "Multibrot z^20", power: 20.0),
  SharedMultibrotCatalogEntry(
      id: 'f0105_inverse_multibrot_d_5',
      name: "Inverse Multibrot d=-5",
      power: -5.0),
  SharedMultibrotCatalogEntry(
      id: 'f0104_inverse_multibrot_d_4',
      name: "Inverse Multibrot d=-4",
      power: -4.0),
  SharedMultibrotCatalogEntry(
      id: 'f0103_inverse_multibrot_d_3',
      name: "Inverse Multibrot d=-3",
      power: -3.0),
];

List<FractalModule> buildSharedMultibrotCatalogModules() =>
    sharedMultibrotCatalogEntries
        .map(_buildSharedMultibrotModule)
        .toList(growable: false);

FractalModule _buildSharedMultibrotModule(SharedMultibrotCatalogEntry entry) {
  final defaultPreset = catalogPreset(
      id: '${entry.id}-default',
      moduleId: entry.id,
      name: 'Default',
      params: {
        'iterations': 180,
        'bailout': 4.0,
        'colorScheme': 0,
        'power': entry.power
      },
      view: FractalViewState(
          pan: Vector2.zero(), zoom: 1.0, rotation: Vector3.zero()));

  return FractalModule(
      id: entry.id,
      displayName: (_) => entry.name,
      dimension: FractalDimension.twoD,
      shaderAsset:
          'shaders/escape_time_family/families/multibrot/integer_powers/multibrot3_gpu.frag',
      parameters: [
        CommonFractalParams.iterations(defaultValue: 180),
        CommonFractalParams.bailout(defaultValue: 4.0),
        CommonFractalParams.colorScheme64(defaultValue: 0),
        FractalParameter(
            id: 'power',
            label: (_) => 'Power',
            type: FractalParamType.float,
            min: -8,
            max: 24,
            step: 0.1,
            defaultValue: entry.power)
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
        shader.setFloat(7, readDouble(state.params, 'bailout', 4.0));
        shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
        shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);
        shader.setFloat(10, readDouble(state.params, 'power', entry.power));
      });
}
