import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildMandelbulbModule() {
  final parameters = [
    FractalParameter(
      id: 'power',
      label: (l10n) => l10n.paramPower,
      type: FractalParamType.float,
      min: 2.0,
      max: 12.0,
      step: 0.1,
      defaultValue: 8.0,
    ),
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 10,
      max: 100,
      step: 1,
      defaultValue: 50,
    ),
    FractalParameter(
      id: 'steps',
      label: (l10n) => l10n.paramSteps,
      type: FractalParamType.integer,
      min: 20,
      max: 200,
      step: 1,
      defaultValue: 120,
    ),
    FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: 1.0,
      max: 4.0,
      step: 0.1,
      defaultValue: 2.0,
    ),
    FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(value: 0, label: (l10n) => l10n.colorFire),
        FractalParamOption(value: 1, label: (l10n) => l10n.colorOcean),
        FractalParamOption(value: 2, label: (l10n) => l10n.colorPsychedelic),
        FractalParamOption(value: 3, label: (l10n) => l10n.colorGrayscale),
      ],
    ),
    FractalParameter(
      id: 'fractalType',
      label: (l10n) => l10n.paramFractalType,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(value: 0, label: (l10n) => l10n.fractalTypeMandelbulb),
        FractalParamOption(value: 1, label: (l10n) => l10n.fractalTypeMandelbox),
        FractalParamOption(value: 2, label: (l10n) => l10n.fractalTypeJulia),
        FractalParamOption(value: 3, label: (l10n) => l10n.fractalTypeSierpinski),
      ],
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'mandelbulb-default',
    moduleId: 'mandelbulb',
    name: 'Default',
    params: {
      'power': 8.0,
      'iterations': 50,
      'steps': 120,
      'bailout': 2.0,
      'colorScheme': 0,
      'fractalType': 0,
    },
    view: FractalViewState.initial(),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'mandelbulb',
    displayName: (l10n) => l10n.moduleMandelbulb,
    dimension: FractalDimension.threeD,
    shaderAsset: 'shaders/mandelbulb.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'mandelbulb-classic', name: 'Classic'),
      // Alien Artifact - top-down view revealing intricate surface
      defaultPreset.copyWith(
        id: 'mandelbulb-artifact',
        name: 'Alien Artifact',
        params: {
          'power': 8.0,
          'iterations': 65,
          'steps': 150,
          'bailout': 2.0,
          'colorScheme': 1, // Ocean
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.5, 0.0, 0.0),
        ),
      ),
      // Coral Formation - organic underwater look
      defaultPreset.copyWith(
        id: 'mandelbulb-coral',
        name: 'Coral Formation',
        params: {
          'power': 7.0,
          'iterations': 70,
          'steps': 160,
          'bailout': 2.2,
          'colorScheme': 1, // Ocean
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3(0.3, 0.4, 0.0),
        ),
      ),
      // Volcanic Heart - fiery core perspective
      defaultPreset.copyWith(
        id: 'mandelbulb-volcanic',
        name: 'Volcanic Heart',
        params: {
          'power': 9.0,
          'iterations': 55,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 0, // Fire
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.5,
          rotation: Vector3(0.7, 0.2, 0.1),
        ),
      ),
      // Psychedelic Sphere - vibrant trippy colors
      defaultPreset.copyWith(
        id: 'mandelbulb-psychedelic',
        name: 'Psychedelic Sphere',
        params: {
          'power': 8.0,
          'iterations': 60,
          'steps': 130,
          'bailout': 2.0,
          'colorScheme': 2, // Psychedelic
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.4, 0.6, 0.2),
        ),
      ),
      // Monolith - dramatic grayscale structure
      defaultPreset.copyWith(
        id: 'mandelbulb-monolith',
        name: 'Monolith',
        params: {
          'power': 10.0,
          'iterations': 50,
          'steps': 120,
          'bailout': 2.0,
          'colorScheme': 3, // Grayscale
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.4,
          rotation: Vector3(0.2, 0.8, 0.0),
        ),
      ),
      // Low Power Bloom - softer, more organic shapes
      defaultPreset.copyWith(
        id: 'mandelbulb-bloom',
        name: 'Soft Bloom',
        params: {
          'power': 5.0,
          'iterations': 80,
          'steps': 170,
          'bailout': 2.5,
          'colorScheme': 1, // Ocean
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.6,
          rotation: Vector3(0.5, 0.3, 0.1),
        ),
      ),
      // High Power Crystal - sharp geometric patterns
      defaultPreset.copyWith(
        id: 'mandelbulb-crystal',
        name: 'Crystal Core',
        params: {
          'power': 12.0,
          'iterations': 45,
          'steps': 110,
          'bailout': 1.8,
          'colorScheme': 2, // Psychedelic
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.2,
          rotation: Vector3(0.6, 0.5, 0.3),
        ),
      ),
      // Mandelbox - folded space geometry
      defaultPreset.copyWith(
        id: 'mandelbulb-mandelbox',
        name: 'Folded Space',
        params: {
          'power': 8.0,
          'iterations': 60,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 0, // Fire
          'fractalType': 1, // Mandelbox
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.3,
          rotation: Vector3(0.3, 0.4, 0.0),
        ),
      ),
      // 3D Julia - smooth flowing curves
      defaultPreset.copyWith(
        id: 'mandelbulb-julia3d',
        name: '3D Julia Dream',
        params: {
          'power': 8.0,
          'iterations': 70,
          'steps': 150,
          'bailout': 2.2,
          'colorScheme': 2, // Psychedelic
          'fractalType': 2, // Julia
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.4, 0.2, 0.1),
        ),
      ),
      // Sierpinski Pyramid - recursive triangular shapes
      defaultPreset.copyWith(
        id: 'mandelbulb-sierpinski',
        name: 'Sierpinski Pyramid',
        params: {
          'power': 8.0,
          'iterations': 50,
          'steps': 120,
          'bailout': 2.0,
          'colorScheme': 3, // Grayscale
          'fractalType': 3, // Sierpinski
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.5, 0.5, 0.0),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final power = _readDouble(state.params, 'power', 8.0);
      final iterations = _readDouble(state.params, 'iterations', 50);
      final steps = _readDouble(state.params, 'steps', 120);
      final bailout = _readDouble(state.params, 'bailout', 2.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);
      final fractalType = _readDouble(state.params, 'fractalType', 0);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, 0.0);
      shader.setFloat(4, 0.0);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, state.view.rotation.x);
      shader.setFloat(7, state.view.rotation.y);
      shader.setFloat(8, state.view.rotation.z);
      shader.setFloat(9, power);
      shader.setFloat(10, iterations);
      shader.setFloat(11, steps);
      shader.setFloat(12, bailout);
      shader.setFloat(13, colorScheme);
      shader.setFloat(14, fractalType);
      shader.setFloat(15, state.transparentBackground ? 1.0 : 0.0);

      final palette = PaletteService.instance.paletteAtIndex(colorScheme.round());
      PaletteService.instance.setCustomPaletteUniforms(shader, 16, palette);
    },
  );
}

double _readDouble(Map<String, Object> params, String key, double fallback) {
  final value = params[key];
  if (value is int) {
    return value.toDouble();
  }
  if (value is double) {
    return value;
  }
  return fallback;
}
