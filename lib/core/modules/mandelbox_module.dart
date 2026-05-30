import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildMandelboxModule() {
  final parameters = [
    CommonFractalParams.iterations(defaultValue: 15, min: 5, max: 30),
    FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.integer,
      min: 0,
      max: 7,
      step: 1,
      defaultValue: 2,
    ),
    FractalParameter(
      id: 'foldLimit',
      label: (_) => 'Fold Limit',
      type: FractalParamType.float,
      min: 0.5,
      max: 1.5,
      step: 0.01,
      defaultValue: 1.0,
    ),
    FractalParameter(
      id: 'scale',
      label: (_) => 'Scale',
      type: FractalParamType.float,
      min: 1.5,
      max: 3.0,
      step: 0.05,
      defaultValue: 2.0,
    ),
    FractalParameter(
      id: 'maxSteps',
      label: (_) => 'Ray Steps',
      type: FractalParamType.integer,
      min: 40,
      max: 150,
      step: 10,
      defaultValue: 80,
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'mandelbox-default',
    moduleId: 'mandelbox',
    name: 'Default',
    params: const {
      'iterations': 15,
      'colorScheme': 2,
      'foldLimit': 1.0,
      'scale': 2.0,
      'maxSteps': 80,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3(0.3, -0.4, 0.0),
    ),
    createdAt: DateTime.utc(2025, 1, 1),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'mandelbox',
    displayName: (_) => 'Mandelbox',
    dimension: FractalDimension.threeD,
    shaderAsset: 'shaders/3d_and_hypercomplex/mandelbox_3d_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      // Folded Space — default view
      defaultPreset.copyWith(
        id: 'mandelbox-folded-space',
        name: 'Folded Space',
      ),
      // Crystal Cathedral — high iterations, low scale
      defaultPreset.copyWith(
        id: 'mandelbox-cathedral',
        name: 'Crystal Cathedral',
        params: {
          'iterations': 20,
          'colorScheme': 4,
          'foldLimit': 1.0,
          'scale': 1.8,
          'maxSteps': 100,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.5, 0.2, 0.0),
        ),
      ),
      // Inferno Box — fire palette, high scale
      defaultPreset.copyWith(
        id: 'mandelbox-inferno',
        name: 'Inferno Box',
        params: {
          'iterations': 18,
          'colorScheme': 0,
          'foldLimit': 1.0,
          'scale': 2.5,
          'maxSteps': 90,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.2,
          rotation: Vector3(0.6, -0.3, 0.1),
        ),
      ),
      // Deep Ocean — ocean palette, folded geometry
      defaultPreset.copyWith(
        id: 'mandelbox-ocean',
        name: 'Deep Ocean',
        params: {
          'iterations': 15,
          'colorScheme': 1,
          'foldLimit': 0.9,
          'scale': 2.0,
          'maxSteps': 80,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.2, 0.8, 0.0),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 15);
      final colorScheme = readDouble(state.params, 'colorScheme', 2);
      final foldLimit = readDouble(state.params, 'foldLimit', 1.0);
      final scale = readDouble(state.params, 'scale', 2.0);
      final maxSteps = readDouble(state.params, 'maxSteps', 80);
      final foldValue = foldLimit * 2.0; // always 2 * foldLimit
      const mR2 = 0.25; // fixed inner sphere radius²
      const fR2 = 1.0; // fixed outer sphere radius²

      // Uniform layout must match mandelbox_3d_gpu.frag exactly.
      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.rotation.x);
      shader.setFloat(4, state.view.rotation.y);
      shader.setFloat(5, state.view.rotation.z);
      shader.setFloat(6, state.view.zoom);
      shader.setFloat(7, iterations);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, foldLimit);
      shader.setFloat(10, foldValue);
      shader.setFloat(11, mR2);
      shader.setFloat(12, fR2);
      shader.setFloat(13, scale);
      shader.setFloat(14, maxSteps);
      shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
