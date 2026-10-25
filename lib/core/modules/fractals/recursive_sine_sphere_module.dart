import 'dart:math' as math;

import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math_64.dart';

FractalModule buildRecursiveSineSphereModule() {
  const defaults = <String, Object>{
    'depth': 3,
    'strength': 0.8,
    'radius': 1.0,
    'phase': 0.0,
    'steps': 256,
    'colorScheme': 0,
    'animate': false,
  };
  final view = FractalViewState(
    pan: Vector2.zero(),
    zoom: 1,
    rotation: Vector3(0.3, -0.4, 0),
  );
  final preset = catalogPreset(
    id: 'recursive_sine_sphere-default',
    moduleId: 'recursive_sine_sphere',
    name: 'Bounded sphere',
    params: defaults,
    view: view,
  );
  return FractalModule(
    id: 'recursive_sine_sphere',
    displayName: (l10n) => l10n.recursiveSineSphereName,
    dimension: FractalDimension.threeD,
    animationCapability: FractalAnimationCapability.timeDriven,
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/recursive_sine_sphere_gpu.frag',
    parameters: [
      FractalParameter(
          id: 'depth',
          label: (l) => l.recursiveSineSphereDepth,
          type: FractalParamType.integer,
          min: 0,
          max: 6,
          step: 1,
          defaultValue: 3),
      FractalParameter(
          id: 'strength',
          label: (l) => l.recursiveSineSphereStrength,
          type: FractalParamType.float,
          min: 0,
          max: 1,
          step: 0.05,
          defaultValue: 0.8),
      FractalParameter(
          id: 'radius',
          label: (l) => l.recursiveSineSphereRadius,
          type: FractalParamType.float,
          min: 0.25,
          max: 2,
          step: 0.05,
          defaultValue: 1),
      FractalParameter(
          id: 'phase',
          label: (l) => l.recursiveSineSpherePhase,
          type: FractalParamType.float,
          min: -math.pi,
          max: math.pi,
          step: 0.05,
          defaultValue: 0),
      FractalParameter(
          id: 'steps',
          label: (l) => l.recursiveSineSphereRaySteps,
          type: FractalParamType.integer,
          min: 64,
          max: 512,
          step: 16,
          defaultValue: 256),
      CommonFractalParams.colorScheme4(defaultValue: 0),
      FractalParameter(
          id: 'animate',
          label: (l) => l.recursiveSineSphereAnimate,
          type: FractalParamType.boolean,
          min: 0,
          max: 1,
          step: 1,
          defaultValue: false),
    ],
    defaultPreset: preset,
    builtInPresets: [
      preset,
      preset.copyWith(
          id: 'recursive_sine_sphere-fine',
          name: 'Fine detail',
          params: {...defaults, 'depth': 5, 'steps': 384},
          // Keep the finer lobes inside the viewport (qualified at 4:3).
          view: view.copyWith(zoom: 0.9)),
    ],
    setUniforms: (shader, state, size, time) {
      setRaymarched3DFrameUniforms(
        setFloat: shader.setFloat,
        time: time,
        width: size.width,
        height: size.height,
        view: state.view,
      );
      shader.setFloat(9, _bounded(state.params, 'depth', 3, 0, 6));
      shader.setFloat(10, _bounded(state.params, 'strength', 0.8, 0, 1));
      shader.setFloat(11, _bounded(state.params, 'radius', 1, 0.25, 2));
      shader.setFloat(
          12, _bounded(state.params, 'phase', 0, -math.pi, math.pi));
      shader.setFloat(13, _bounded(state.params, 'steps', 256, 64, 512));
      shader.setFloat(14, _bounded(state.params, 'colorScheme', 0, 0, 3));
      shader.setFloat(15, state.params['animate'] == true ? 1 : 0);
      shader.setFloat(16, state.transparentBackground ? 1 : 0);
    },
  );
}

double _bounded(Map<String, Object> params, String key, double fallback,
    double minimum, double maximum) {
  final value = readDouble(params, key, fallback);
  return (value.isFinite ? value : fallback).clamp(minimum, maximum).toDouble();
}
