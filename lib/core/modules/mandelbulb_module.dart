import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
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
    CommonFractalParams.iterations(defaultValue: 50, min: 10, max: 100),
    FractalParameter(
      id: 'steps',
      label: (l10n) => l10n.paramSteps,
      type: FractalParamType.integer,
      min: 20,
      max: 200,
      step: 1,
      defaultValue: 120,
    ),
    CommonFractalParams.bailout(defaultValue: 2.0, min: 1.0, max: 4.0),
    CommonFractalParams.colorScheme4(defaultValue: 0),
    FractalParameter(
      id: 'fractalType',
      label: (l10n) => l10n.paramFractalType,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(
            value: 0, label: (l10n) => l10n.fractalTypeMandelbulb),
        FractalParamOption(
            value: 1, label: (l10n) => l10n.fractalTypeMandelbox),
        FractalParamOption(value: 2, label: (l10n) => l10n.fractalTypeJulia),
        FractalParamOption(
            value: 3, label: (l10n) => l10n.fractalTypeSierpinski),
      ],
    ),
  ];

  final defaultPreset = catalogPreset(
    id: 'mandelbulb-default',
    moduleId: 'mandelbulb',
    name: 'Default',
    params: const {
      'power': 8.0,
      'iterations': 50,
      'steps': 120,
      'bailout': 2.0,
      'colorScheme': 0,
      'fractalType': 0,
    },
    view: FractalViewState.initial(),
  );

  return FractalModule(
    id: 'mandelbulb',
    displayName: (l10n) => l10n.moduleMandelbulb,
    dimension: FractalDimension.threeD,
    shaderAsset: 'shaders/legacy/raymarched_3d/mandelbulb.frag',
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
      final power = readDouble(state.params, 'power', 8.0);
      final iterations = readDouble(state.params, 'iterations', 50);
      final steps = readDouble(state.params, 'steps', 120);
      final bailout = readDouble(state.params, 'bailout', 2.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0);
      final fractalType = readDouble(state.params, 'fractalType', 0);

      shader.setFloat(Raymarched3DUniformSlots.time, time);
      shader.setFloat(Raymarched3DUniformSlots.resolutionX, size.width);
      shader.setFloat(Raymarched3DUniformSlots.resolutionY, size.height);
      shader.setFloat(Raymarched3DUniformSlots.mouseX, 0.0);
      shader.setFloat(Raymarched3DUniformSlots.mouseY, 0.0);
      shader.setFloat(Raymarched3DUniformSlots.zoom, state.view.zoom);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationX, state.view.rotation.x);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationY, state.view.rotation.y);
      shader.setFloat(
          Raymarched3DUniformSlots.rotationZ, state.view.rotation.z);
      shader.setFloat(Raymarched3DUniformSlots.power, power);
      shader.setFloat(Raymarched3DUniformSlots.iterations, iterations);
      shader.setFloat(Raymarched3DUniformSlots.steps, steps);
      shader.setFloat(Raymarched3DUniformSlots.bailout, bailout);
      shader.setFloat(Raymarched3DUniformSlots.colorScheme, colorScheme);
      shader.setFloat(Raymarched3DUniformSlots.fractalType, fractalType);
      shader.setFloat(Raymarched3DUniformSlots.transparentBackground,
          state.transparentBackground ? 1.0 : 0.0);

      try {
        final palette =
            PaletteService.instance.paletteAtIndex(colorScheme.round());
        PaletteService.instance.setCustomPaletteUniforms(shader, 16, palette);
      } catch (_) {
        // PaletteService unavailable; shader built-in color schemes apply.
      }
    },
  );
}
