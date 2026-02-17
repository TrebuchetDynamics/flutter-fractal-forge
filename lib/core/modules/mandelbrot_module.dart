import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/shaders/uniform_schema.dart';
import 'package:vector_math/vector_math.dart';

FractalModule buildMandelbrotModule() {
  final schema = UniformSchema.build((b) {
    b.float('uTime');
    b.vec2('uResolution');
    b.vec2('uCenter');
    b.float('uZoom');
    b.float('uIterations');
    b.float('uBailout');
    b.float('uColorScheme');
    b.float('uTransparentBg');
    // Palette is now a sampler2D — no more vec4 stops!
  });

  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 20,
      max: 5000,
      step: 1,
      defaultValue: 120,
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
    CommonFractalParams.colorScheme64(defaultValue: 0),
  ];

  final defaultPreset = FractalPreset(
    id: 'mandelbrot-default',
    moduleId: 'mandelbrot',
    name: 'Default',
    params: {
      'iterations': 120,
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
    id: 'mandelbrot',
    displayName: (l10n) => l10n.moduleMandelbrot,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/mandel_step_smooth.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(id: 'mandelbrot-classic', name: 'Classic'),
      // Seahorse Valley - famous zoom location with spiraling tentacles
      defaultPreset.copyWith(
        id: 'mandelbrot-seahorse',
        name: 'Seahorse Valley',
        params: {
          'iterations': 350,
          'bailout': 4.0,
          'colorScheme': 1, // Ocean
        },
        view: FractalViewState(
          pan: Vector2(-0.747, 0.1),
          zoom: 25.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Elephant Valley - trunk-like spirals
      defaultPreset.copyWith(
        id: 'mandelbrot-elephant',
        name: 'Elephant Valley',
        params: {
          'iterations': 300,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
        },
        view: FractalViewState(
          pan: Vector2(0.275, 0.0),
          zoom: 15.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Deep Spiral - mesmerizing spiral patterns
      defaultPreset.copyWith(
        id: 'mandelbrot-spiral',
        name: 'Deep Spiral',
        params: {
          'iterations': 400,
          'bailout': 4.0,
          'colorScheme': 2, // Psychedelic
        },
        view: FractalViewState(
          pan: Vector2(-0.743643887037158, 0.131825904205330),
          zoom: 500.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Lightning Strike - high contrast jagged edges
      defaultPreset.copyWith(
        id: 'mandelbrot-lightning',
        name: 'Lightning Strike',
        params: {
          'iterations': 280,
          'bailout': 3.0,
          'colorScheme': 3, // Grayscale
        },
        view: FractalViewState(
          pan: Vector2(-0.1011, 0.9563),
          zoom: 80.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Mini Mandelbrot - small copy deep in the set
      defaultPreset.copyWith(
        id: 'mandelbrot-mini',
        name: 'Mini Mandelbrot',
        params: {
          'iterations': 450,
          'bailout': 4.0,
          'colorScheme': 0, // Fire
        },
        view: FractalViewState(
          pan: Vector2(-1.7497591451303785, 0.0),
          zoom: 200.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Aurora Borealis - soft flowing colors
      defaultPreset.copyWith(
        id: 'mandelbrot-aurora',
        name: 'Aurora Borealis',
        params: {
          'iterations': 200,
          'bailout': 6.0,
          'colorScheme': 1, // Ocean
        },
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
      ),
      // Cosmic Web - intricate web-like structures
      defaultPreset.copyWith(
        id: 'mandelbrot-cosmic',
        name: 'Cosmic Web',
        params: {
          'iterations': 380,
          'bailout': 4.5,
          'colorScheme': 2, // Psychedelic
        },
        view: FractalViewState(
          pan: Vector2(-0.16, 1.0405),
          zoom: 150.0,
          rotation: Vector3.zero(),
        ),
      ),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = _readDouble(state.params, 'iterations', 120);
      final bailout = _readDouble(state.params, 'bailout', 4.0);
      final colorScheme = _readDouble(state.params, 'colorScheme', 0);

      final w = schema.writer(shader);
      w.setFloat('uTime', time);
      w.setVec2('uResolution', size.width, size.height);
      w.setVec2('uCenter', state.view.pan.x, state.view.pan.y);
      w.setFloat('uZoom', state.view.zoom);
      w.setFloat('uIterations', iterations);
      w.setFloat('uBailout', bailout);
      w.setFloat('uColorScheme', colorScheme);
      w.setFloat('uTransparentBg', state.transparentBackground ? 1.0 : 0.0);

      // DIAG: no sampler for diag_9float.frag test
      // final palette = PaletteService.instance.paletteAtIndex(colorScheme.round());
      // final paletteTex = PaletteService.instance.paletteTexture(palette);
      // shader.setImageSampler(0, paletteTex);
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
