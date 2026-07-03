import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math.dart';

/// Dual-panel Mandelbrot + Julia set viewer.
///
/// Left panel: Mandelbrot set (pan/zoom controlled by view state).
/// Right panel: Julia set for the parameter c = (uJuliaReal, uJuliaImag).
///
/// Uniform layout (must match mandel_julia_dual_gpu.frag):
///   0  uTime
///   1-2  uResolution
///   3-4  uCenter (Mandelbrot pan)
///   5  uZoom
///   6  uIterations
///   7  uBailout
///   8  uColorScheme
///   9  uJuliaReal
///   10 uJuliaImag
///   11 uTransparentBg
FractalModule buildJuliaDualModule() {
  final parameters = [
    CommonFractalParams.iterations(defaultValue: 180),
    CommonFractalParams.bailout(defaultValue: 4.0),
    CommonFractalParams.colorScheme64(defaultValue: 0),
    FractalParameter(
      id: 'juliaCReal',
      label: (l10n) => l10n.paramJuliaCReal,
      type: FractalParamType.float,
      min: -2.0,
      max: 2.0,
      step: 0.001,
      defaultValue: -0.7269,
    ),
    FractalParameter(
      id: 'juliaCImag',
      label: (l10n) => l10n.paramJuliaCImag,
      type: FractalParamType.float,
      min: -2.0,
      max: 2.0,
      step: 0.001,
      defaultValue: 0.1889,
    ),
  ];

  FractalPreset preset(String id, String name, double cr, double ci, int cs) =>
      catalogPreset(
        id: 'julia-dual-$id',
        moduleId: 'julia_dual',
        name: name,
        params: {
          'iterations': 200,
          'bailout': 4.0,
          'colorScheme': cs,
          'juliaCReal': cr,
          'juliaCImag': ci,
        },
        view: FractalViewState(
          pan: Vector2(-0.5, 0.0),
          zoom: 1.0,
          rotation: Vector3.zero(),
        ),
      );

  return FractalModule(
    id: 'julia_dual',
    displayName: (_) => 'Mandelbrot + Julia',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/escape_time_family/core/mandel_julia_dual_gpu.frag',
    parameters: parameters,
    defaultPreset: preset('galaxy', 'Spiral Galaxy', -0.7269, 0.1889, 2),
    builtInPresets: [
      preset('galaxy', 'Spiral Galaxy', -0.7269, 0.1889, 2),
      preset('dendrite', 'Dendrite', 0.0, 1.0, 3),
      preset('dragon', "Dragon's Breath", -0.835, -0.2321, 0),
      preset('sanmarco', 'San Marco', -0.75, 0.0, 1),
      preset('siegel', 'Siegel Disk', -0.391, -0.587, 2),
      preset('rabbit', 'Douady Rabbit', -0.123, 0.745, 0),
    ],
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 180);
      final bailout = readDouble(state.params, 'bailout', 4.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0);
      final juliaCReal = readDouble(state.params, 'juliaCReal', -0.7269);
      final juliaCImag = readDouble(state.params, 'juliaCImag', 0.1889);

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations);
      shader.setFloat(7, bailout);
      shader.setFloat(8, colorScheme);
      shader.setFloat(9, juliaCReal);
      shader.setFloat(10, juliaCImag);
      shader.setFloat(11, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
