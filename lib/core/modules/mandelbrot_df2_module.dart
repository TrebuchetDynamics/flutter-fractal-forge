import 'dart:typed_data';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';

/// Returns a [FractalModule] that wraps the standard Mandelbrot module
/// but uses the double-float shader for deep zoom (zoom >= 5e6).
///
/// Uniform layout must match [MandelbrotDf2UniformSlots] and
/// shaders/legacy/precision/mandelbrot_df2.frag.
FractalModule buildMandelbrotDf2Module(FractalModule standardModule) {
  return FractalModule(
    id: standardModule.id, // keep 'mandelbrot'
    displayName: standardModule.displayName,
    dimension: standardModule.dimension,
    shaderAsset: 'shaders/legacy/precision/mandelbrot_df2.frag',
    parameters: standardModule.parameters,
    defaultPreset: standardModule.defaultPreset,
    builtInPresets: standardModule.builtInPresets,
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 200);
      final bailout = readDouble(state.params, 'bailout', 4.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0);

      // Split center.x and center.y into float32 hi+lo pairs.
      final (cxHi, cxLo) = _splitDouble(state.view.pan.x);
      final (cyHi, cyLo) = _splitDouble(state.view.pan.y);

      shader.setFloat(MandelbrotDf2UniformSlots.time, time);
      shader.setFloat(MandelbrotDf2UniformSlots.resolutionX, size.width);
      shader.setFloat(MandelbrotDf2UniformSlots.resolutionY, size.height);
      shader.setFloat(MandelbrotDf2UniformSlots.centerHiX, cxHi);
      shader.setFloat(MandelbrotDf2UniformSlots.centerLoX, cxLo);
      shader.setFloat(MandelbrotDf2UniformSlots.centerHiY, cyHi);
      shader.setFloat(MandelbrotDf2UniformSlots.centerLoY, cyLo);
      shader.setFloat(MandelbrotDf2UniformSlots.zoom, state.view.zoom);
      shader.setFloat(MandelbrotDf2UniformSlots.iterations, iterations);
      shader.setFloat(MandelbrotDf2UniformSlots.bailout, bailout);
      shader.setFloat(MandelbrotDf2UniformSlots.colorScheme, colorScheme);
      shader.setFloat(MandelbrotDf2UniformSlots.transparentBackground,
          state.transparentBackground ? 1.0 : 0.0);
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
