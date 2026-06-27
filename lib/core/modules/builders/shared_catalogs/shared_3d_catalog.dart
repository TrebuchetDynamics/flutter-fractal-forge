// GENERATED — reviewed shared 3D renderer promotions.
// Source: research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.json

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

enum Shared3DKind { mandelboxScale, mandelbulbPower }

class Shared3DCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final Shared3DKind kind;
  final double value;

  const Shared3DCatalogEntry(
      {required this.id,
      required this.name,
      required this.shaderAsset,
      required this.kind,
      required this.value});
}

const List<Shared3DCatalogEntry> shared3DCatalogEntries = [
  Shared3DCatalogEntry(
      id: 'f0570_mandelbox_s_1_5',
      name: "Mandelbox s=1.5",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 1.5),
  Shared3DCatalogEntry(
      id: 'f0571_mandelbox_s_1_8',
      name: "Mandelbox s=1.8",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 1.8),
  Shared3DCatalogEntry(
      id: 'f0572_mandelbox_s_2_0',
      name: "Mandelbox s=2.0",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 2.0),
  Shared3DCatalogEntry(
      id: 'f0573_mandelbox_s_2_2',
      name: "Mandelbox s=2.2",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 2.2),
  Shared3DCatalogEntry(
      id: 'f0574_mandelbox_s_2_5',
      name: "Mandelbox s=2.5",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 2.5),
  Shared3DCatalogEntry(
      id: 'f0575_mandelbox_s_2_7',
      name: "Mandelbox s=2.7",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 2.7),
  Shared3DCatalogEntry(
      id: 'f0576_mandelbox_s_3_0',
      name: "Mandelbox s=3.0",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 3.0),
  Shared3DCatalogEntry(
      id: 'f0577_mandelbox_s_3_5',
      name: "Mandelbox s=3.5",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 3.5),
  Shared3DCatalogEntry(
      id: 'f0578_mandelbox_s_4_0',
      name: "Mandelbox s=4.0",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_3d_gpu.frag',
      kind: Shared3DKind.mandelboxScale,
      value: 4.0),
  Shared3DCatalogEntry(
      id: 'f0561_mandelbulb_n_8',
      name: "Mandelbulb n=8",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 8.0),
  Shared3DCatalogEntry(
      id: 'f0562_mandelbulb_n_9',
      name: "Mandelbulb n=9",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 9.0),
  Shared3DCatalogEntry(
      id: 'f0563_mandelbulb_n_10',
      name: "Mandelbulb n=10",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 10.0),
  Shared3DCatalogEntry(
      id: 'f0564_mandelbulb_n_11',
      name: "Mandelbulb n=11",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 11.0),
  Shared3DCatalogEntry(
      id: 'f0565_mandelbulb_n_12',
      name: "Mandelbulb n=12",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 12.0),
  Shared3DCatalogEntry(
      id: 'f0566_mandelbulb_n_14',
      name: "Mandelbulb n=14",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 14.0),
  Shared3DCatalogEntry(
      id: 'f0567_mandelbulb_n_16',
      name: "Mandelbulb n=16",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 16.0),
  Shared3DCatalogEntry(
      id: 'f0568_mandelbulb_n_20',
      name: "Mandelbulb n=20",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 20.0),
  Shared3DCatalogEntry(
      id: 'f0569_mandelbulb_n_24',
      name: "Mandelbulb n=24",
      shaderAsset:
          'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
      kind: Shared3DKind.mandelbulbPower,
      value: 24.0),
];

List<FractalModule> buildShared3DCatalogModules() =>
    shared3DCatalogEntries.map(_buildShared3DModule).toList(growable: false);

FractalModule _buildShared3DModule(Shared3DCatalogEntry entry) {
  return switch (entry.kind) {
    Shared3DKind.mandelboxScale => _buildMandelboxScaleModule(entry),
    Shared3DKind.mandelbulbPower => _buildStandard3DModule(entry),
  };
}

FractalModule _buildStandard3DModule(Shared3DCatalogEntry entry) {
  final defaultPreset = catalogPreset(
      id: '${entry.id}-default',
      moduleId: entry.id,
      name: 'Default',
      params: {
        'power': entry.value,
        'iterations': 50,
        'steps': 120,
        'bailout': 4.0,
        'colorScheme': 0
      },
      view: FractalViewState(
          pan: Vector2.zero(), zoom: 1.0, rotation: Vector3(0.3, -0.4, 0.0)));
  return FractalModule(
      id: entry.id,
      displayName: (_) => entry.name,
      dimension: FractalDimension.threeD,
      shaderAsset: entry.shaderAsset,
      parameters: [
        FractalParameter(
            id: 'power',
            label: (_) => 'Power',
            type: FractalParamType.float,
            min: 2.0,
            max: 24.0,
            step: 1.0,
            defaultValue: entry.value),
        CommonFractalParams.iterations(defaultValue: 50, min: 5, max: 100),
        FractalParameter(
            id: 'steps',
            label: (l10n) => l10n.paramSteps,
            type: FractalParamType.integer,
            min: 20,
            max: 200,
            step: 1,
            defaultValue: 120),
        CommonFractalParams.bailout(defaultValue: 4.0, min: 1.0, max: 8.0),
        CommonFractalParams.colorScheme4(defaultValue: 0)
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
        shader.setFloat(9, readDouble(state.params, 'power', entry.value));
        shader.setFloat(10, readDouble(state.params, 'iterations', 50));
        shader.setFloat(11, readDouble(state.params, 'steps', 120));
        shader.setFloat(12, readDouble(state.params, 'bailout', 4.0));
        shader.setFloat(13, readDouble(state.params, 'colorScheme', 0));
        shader.setFloat(14, 0.0);
        shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
      });
}

FractalModule _buildMandelboxScaleModule(Shared3DCatalogEntry entry) {
  final defaultPreset = catalogPreset(
      id: '${entry.id}-default',
      moduleId: entry.id,
      name: 'Default',
      params: {
        'scale': entry.value,
        'iterations': 15,
        'steps': 100,
        'colorScheme': 0
      },
      view: FractalViewState(
          pan: Vector2.zero(), zoom: 1.0, rotation: Vector3(0.3, -0.4, 0.0)));
  return FractalModule(
      id: entry.id,
      displayName: (_) => entry.name,
      dimension: FractalDimension.threeD,
      shaderAsset: entry.shaderAsset,
      parameters: [
        FractalParameter(
            id: 'scale',
            label: (_) => 'Scale',
            type: FractalParamType.float,
            min: 1.0,
            max: 4.0,
            step: 0.1,
            defaultValue: entry.value),
        CommonFractalParams.iterations(defaultValue: 15, min: 5, max: 40),
        FractalParameter(
            id: 'steps',
            label: (l10n) => l10n.paramSteps,
            type: FractalParamType.integer,
            min: 20,
            max: 200,
            step: 1,
            defaultValue: 100),
        CommonFractalParams.colorScheme4(defaultValue: 0)
      ],
      defaultPreset: defaultPreset,
      builtInPresets: [defaultPreset],
      setUniforms: (shader, state, size, time) {
        shader.setFloat(0, time);
        shader.setFloat(1, size.width);
        shader.setFloat(2, size.height);
        shader.setFloat(3, state.view.rotation.x);
        shader.setFloat(4, state.view.rotation.y);
        shader.setFloat(5, state.view.rotation.z);
        shader.setFloat(6, state.view.zoom);
        shader.setFloat(7, readDouble(state.params, 'iterations', 15));
        shader.setFloat(8, readDouble(state.params, 'colorScheme', 0));
        shader.setFloat(9, 1.0);
        shader.setFloat(10, 2.0);
        shader.setFloat(11, 0.25);
        shader.setFloat(12, 1.0);
        shader.setFloat(13, readDouble(state.params, 'scale', entry.value));
        shader.setFloat(14, readDouble(state.params, 'steps', 100));
        shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
      });
}
