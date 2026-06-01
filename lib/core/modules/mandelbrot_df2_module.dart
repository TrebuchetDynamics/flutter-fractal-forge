import 'dart:typed_data';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';

/// Returns a [FractalModule] that wraps the standard Mandelbrot module
/// but uses the double-float shader for deep zoom (zoom >= 5e6).
///
/// Uniform layout must match shaders/legacy/precision/mandelbrot_df2.frag.
FractalModule buildMandelbrotDf2Module(FractalModule standardModule) {
  return FractalModule(
    id: standardModule.id,              // keep 'mandelbrot'
    displayName: standardModule.displayName,
    dimension: standardModule.dimension,
    shaderAsset: 'shaders/legacy/precision/mandelbrot_df2.frag',
    parameters: standardModule.parameters,
    defaultPreset: standardModule.defaultPreset,
    builtInPresets: standardModule.builtInPresets,
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 200);
      final bailout    = readDouble(state.params, 'bailout', 4.0);
      final colorScheme= readDouble(state.params, 'colorScheme', 0);

      // Split center.x and center.y into float32 hi+lo pairs.
      final (cxHi, cxLo) = _splitDouble(state.view.pan.x);
      final (cyHi, cyLo) = _splitDouble(state.view.pan.y);

      shader.setFloat(0,  time);
      shader.setFloat(1,  size.width);
      shader.setFloat(2,  size.height);
      shader.setFloat(3,  cxHi);
      shader.setFloat(4,  cxLo);
      shader.setFloat(5,  cyHi);
      shader.setFloat(6,  cyLo);
      shader.setFloat(7,  state.view.zoom);
      shader.setFloat(8,  iterations);
      shader.setFloat(9,  bailout);
      shader.setFloat(10, colorScheme);
      shader.setFloat(11, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}

/// Splits a Dart double into float32 hi + residual lo.
/// hi = value rounded to float32 precision.
/// lo = exact residual (v - hi), which is the sub-float32 correction.
(double, double) _splitDouble(double v) {
  final bytes = ByteData(4);
  bytes.setFloat32(0, v);
  final hi = bytes.getFloat32(0).toDouble();
  final lo = v - hi;
  return (hi, lo);
}
