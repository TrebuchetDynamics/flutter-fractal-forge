import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';
import 'package:vector_math/vector_math.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

FractalModule buildBurningShipModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 500,
      step: 1,
      defaultValue: 200,
    ),
    FractalParameter(
      id: 'bailout',
      label: (l10n) => l10n.paramBailout,
      type: FractalParamType.float,
      min: 2.0,
      max: 8.0,
      step: 0.1,
      defaultValue: 4.0,
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
  ];

  final defaultPreset = FractalPreset(
    id: 'burning-ship-default',
    moduleId: 'burning_ship',
    name: 'Default',
    params: {
      'iterations': 200,
      'bailout': 4.0,
      'colorScheme': 0,
    },
    view: FractalViewState(
      pan: Vector2(-0.5, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'burning_ship',
    displayName: (l10n) => l10n.moduleBurningShip,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/burning_ship.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'burning-ship-classic', name: 'Classic'),
      // The Ship - centered view of the iconic ship shape
      defaultPreset.copyWith(
        id: 'burning-ship-vessel',
        name: 'The Vessel',
        params: {
          'iterations': 300,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
        },
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.5,
          rotation: Vector3.zero(),
        ),
      ),
      // Armada - fleet of small ships in the fractal
      defaultPreset.copyWith(
        id: 'burning-ship-armada',
        name: 'Armada',
        params: {
          'iterations': 380,
          'bailout': 4.0,
          'colorScheme': 1, // Ocean
        },
        view: FractalViewState(
          pan: Vector2(-1.762, -0.028),
          zoom: 100.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Inferno Core - deep zoom into the flames
      defaultPreset.copyWith(
        id: 'burning-ship-inferno',
        name: 'Inferno Core',
        params: {
          'iterations': 400,
          'bailout': 4.5,
          'colorScheme': 0, // Fire
        },
        view: FractalViewState(
          pan: Vector2(-1.8619, -0.0006),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Ghost Ship - ethereal grayscale version
      defaultPreset.copyWith(
        id: 'burning-ship-ghost',
        name: 'Ghost Ship',
        params: {
          'iterations': 350,
          'bailout': 4.0,
          'colorScheme': 3, // Grayscale
        },
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 2.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Mast & Rigging - intricate details at the mast area
      defaultPreset.copyWith(
        id: 'burning-ship-mast',
        name: 'Mast & Rigging',
        params: {
          'iterations': 320,
          'bailout': 4.0,
          'colorScheme': 2, // Psychedelic
        },
        view: FractalViewState(
          pan: Vector2(-1.755, -0.035),
          zoom: 50.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Volcanic Ash - dark moody tones
      defaultPreset.copyWith(
        id: 'burning-ship-volcanic',
        name: 'Volcanic Ash',
        params: {
          'iterations': 280,
          'bailout': 3.5,
          'colorScheme': 3, // Grayscale
        },
        view: FractalViewState(
          pan: Vector2(-1.8, -0.01),
          zoom: 30.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Neon Voyage - vibrant psychedelic ship
      defaultPreset.copyWith(
        id: 'burning-ship-neon',
        name: 'Neon Voyage',
        params: {
          'iterations': 300,
          'bailout': 5.0,
          'colorScheme': 2, // Psychedelic
        },
        view: FractalViewState(
          pan: Vector2(-0.5, -0.5),
          zoom: 1.8,
          rotation: Vector3.zero(),
        ),
      ),
      // Deep Sea Wreck - ocean-colored deep zoom
      defaultPreset.copyWith(
        id: 'burning-ship-wreck',
        name: 'Deep Sea Wreck',
        params: {
          'iterations': 420,
          'bailout': 4.0,
          'colorScheme': 1, // Ocean
        },
        view: FractalViewState(
          pan: Vector2(-1.7572, -0.0282),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = _readDouble(state.params, 'iterations', 200);
      final bailout = _readDouble(state.params, 'bailout', 4.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations);
      shader.setFloat(7, bailout);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, state.transparentBackground ? 1.0 : 0.0);

      final palette = PaletteService.instance.paletteAtIndex(colorScheme.round());
      PaletteService.instance.setCustomPaletteUniforms(shader, 10, palette);
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
