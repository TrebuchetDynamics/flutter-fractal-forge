import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

/// Declarative config for a standard 3D ray-marched fractal.
///
/// Adding a new ray-marched 3D fractal = one [Raymarched3DConfig] + one .frag shader.
/// No separate Dart module file needed.
///
/// All 3D ray-marched fractals share this uniform layout (matching mandelbulb.frag):
///   float 0:  uTime
///   float 1-2: uResolution (vec2)
///   float 3-4: uMousePos (vec2, unused placeholder)
///   float 5:  uZoom
///   float 6-8: uRotation (vec3)
///   float 9:  uPower
///   float 10: uIterations
///   float 11: uSteps
///   float 12: uBailout
///   float 13: uColorScheme
///   float 14: uFractalType
///   float 15: uTransparentBg
class Raymarched3DConfig {
  final String id;
  final String name;
  final ModuleNameBuilder? displayName;
  final String shaderAsset;
  final String category;

  // Default parameter values
  final double defaultPower;
  final double minPower;
  final double maxPower;
  final String powerLabel;
  final double defaultIterations;
  final double maxIterations;
  final double defaultSteps;
  final double defaultBailout;
  final int defaultColorScheme;
  final int maxColorScheme;
  final int defaultFractalType;
  final int maxFractalType;
  final List<FractalParamOption> fractalTypeOptions;
  final List<FractalPreset> extraPresets;

  const Raymarched3DConfig({
    required this.id,
    required this.name,
    required this.shaderAsset,
    this.displayName,
    this.category = '3D Fractals',
    this.defaultPower = 8.0,
    this.minPower = 2.0,
    this.maxPower = 12.0,
    this.powerLabel = 'Power',
    this.defaultIterations = 50,
    this.maxIterations = 100,
    this.defaultSteps = 120,
    this.defaultBailout = 2.0,
    this.defaultColorScheme = 0,
    this.maxColorScheme = 3,
    this.defaultFractalType = 0,
    this.maxFractalType = 0,
    this.fractalTypeOptions = const [],
    this.extraPresets = const [],
  });
}

/// Builds a [FractalModule] from a declarative [Raymarched3DConfig].
FractalModule buildRaymarched3DModule(Raymarched3DConfig config) {
  final parameters = [
    FractalParameter(
      id: 'power',
      label: (_) => config.powerLabel,
      type: FractalParamType.float,
      min: config.minPower,
      max: config.maxPower,
      step: 0.1,
      defaultValue: config.defaultPower,
    ),
    CommonFractalParams.iterations(
      defaultValue: config.defaultIterations,
      min: 5,
      max: config.maxIterations,
    ),
    FractalParameter(
      id: 'steps',
      label: (l10n) => l10n.paramSteps,
      type: FractalParamType.integer,
      min: 20,
      max: 200,
      step: 1,
      defaultValue: config.defaultSteps,
    ),
    CommonFractalParams.bailout(
      defaultValue: config.defaultBailout,
      min: 1.0,
      max: 8.0,
    ),
    CommonFractalParams.colorScheme4(
      defaultValue: config.defaultColorScheme.toDouble(),
      max: config.maxColorScheme,
    ),
    if (config.maxFractalType > 0)
      FractalParameter(
        id: 'fractalType',
        label: (_) => 'Variant',
        type: FractalParamType.enumeration,
        min: 0,
        max: config.maxFractalType.toDouble(),
        step: 1,
        defaultValue: config.defaultFractalType.toDouble(),
        options: config.fractalTypeOptions,
      ),
  ];

  final defaultParams = <String, Object>{
    'power': config.defaultPower,
    'iterations': config.defaultIterations,
    'steps': config.defaultSteps,
    'bailout': config.defaultBailout,
    'colorScheme': config.defaultColorScheme,
    if (config.maxFractalType > 0) 'fractalType': config.defaultFractalType,
  };

  final defaultPreset = FractalPreset(
    id: '${config.id}-default',
    moduleId: config.id,
    name: 'Default',
    params: defaultParams,
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3(0.3, -0.4, 0.0),
    ),
    createdAt: builtInPresetCreatedAt,
    isBuiltIn: true,
  );

  return FractalModule(
    id: config.id,
    displayName: config.displayName ?? ((_) => config.name),
    dimension: FractalDimension.threeD,
    shaderAsset: config.shaderAsset,
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: buildBuiltInPresetList(
      moduleId: config.id,
      defaultPreset: defaultPreset,
      extraPresets: config.extraPresets,
    ),
    setUniforms: (shader, state, size, time) {
      shader.setFloat(Raymarched3DUniformSlots.time, time);
      shader.setFloat(Raymarched3DUniformSlots.resolutionX, size.width);
      shader.setFloat(Raymarched3DUniformSlots.resolutionY, size.height);
      shader.setFloat(Raymarched3DUniformSlots.mouseX, 0.0); // unused
      shader.setFloat(Raymarched3DUniformSlots.mouseY, 0.0); // unused
      shader.setFloat(Raymarched3DUniformSlots.zoom, state.view.zoom);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationX, state.view.rotation.x);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationY, state.view.rotation.y);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationZ, state.view.rotation.z);
      shader.setFloat(Raymarched3DUniformSlots.power,
          readDouble(state.params, 'power', config.defaultPower));
      shader.setFloat(Raymarched3DUniformSlots.iterations,
          readDouble(state.params, 'iterations', config.defaultIterations));
      shader.setFloat(Raymarched3DUniformSlots.steps,
          readDouble(state.params, 'steps', config.defaultSteps));
      shader.setFloat(Raymarched3DUniformSlots.bailout,
          readDouble(state.params, 'bailout', config.defaultBailout));
      shader.setFloat(
          Raymarched3DUniformSlots.colorScheme,
          readDouble(state.params, 'colorScheme',
              config.defaultColorScheme.toDouble()));
      shader.setFloat(
          Raymarched3DUniformSlots.fractalType,
          readDouble(state.params, 'fractalType',
              config.defaultFractalType.toDouble()));
      shader.setFloat(Raymarched3DUniformSlots.transparentBackground,
          state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
