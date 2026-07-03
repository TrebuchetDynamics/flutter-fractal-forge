import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart'
    show packPerturbOrbitComponent;
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:flutter_fractals/core/services/rendering/palette_shader_adapter.dart';
import 'package:flutter_fractals/core/services/rendering/perturb_orbit_texture.dart';

/// Wraps the Julia module with perturbation-theory GPU shader at deep zoom.
FractalModule buildJuliaPerturbModule(FractalModule standardModule) {
  // Inject color-cycle-speed slider (G15) if not already present.
  final baseParams = standardModule.parameters;
  final hasCycleParam = baseParams.any((p) => p.id == 'colorCycleSpeed');
  final parameters = hasCycleParam
      ? baseParams
      : [...baseParams, CommonFractalParams.colorCycleSpeed()];

  return FractalModule(
    id: standardModule.id,
    displayName: standardModule.displayName,
    dimension: standardModule.dimension,
    shaderAsset: 'shaders/escape_time_family/core/escape_time_perturb_gpu.frag',
    parameters: parameters,
    defaultPreset: standardModule.defaultPreset,
    builtInPresets: standardModule.builtInPresets,
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 160)
          .clamp(4.0, 2000.0)
          .toInt();
      final bailout = readDouble(state.params, 'bailout', 4.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0.0);
      final cReal = readDouble(state.params, 'juliaCReal', -0.8);
      final cImag = readDouble(state.params, 'juliaCImag', 0.156);

      final paletteTex = PaletteShaderAdapter.instance.samplerPaletteTexture(
        colorScheme,
      );
      final orbitTex = _OrbitTextureCache.instance.juliaOrbitTexture(
        centerX: state.view.pan.x,
        centerY: state.view.pan.y,
        cReal: cReal,
        cImag: cImag,
        iterations: iterations,
      );

      shader.setFloat(0, time);
      shader.setFloat(1, size.width);
      shader.setFloat(2, size.height);
      shader.setFloat(3, state.view.pan.x);
      shader.setFloat(4, state.view.pan.y);
      shader.setFloat(5, state.view.zoom);
      shader.setFloat(6, iterations.toDouble());
      shader.setFloat(7, bailout);
      shader.setFloat(8, state.transparentBackground ? 1.0 : 0.0);
      shader.setFloat(9, 1.0); // uFormula = Julia
      final colorSpeed = readDouble(state.params, 'colorCycleSpeed', 0.0);
      shader.setFloat(10, 0.0); // uExtra0
      shader.setFloat(11, colorSpeed); // uExtra1 = color cycle speed (G15)
      shader.setFloat(12, 0.0); // uExtra2

      shader.setImageSampler(0, paletteTex);
      shader.setImageSampler(1, orbitTex);
    },
  );
}

class _OrbitTextureCache {
  _OrbitTextureCache._();

  static final _OrbitTextureCache instance = _OrbitTextureCache._();

  String _lastKey = '';
  ui.Image? _lastImage;

  ui.Image juliaOrbitTexture({
    required double centerX,
    required double centerY,
    required double cReal,
    required double cImag,
    required int iterations,
  }) {
    final key = '${centerX.toStringAsFixed(12)}|${centerY.toStringAsFixed(12)}|'
        '${cReal.toStringAsFixed(12)}|${cImag.toStringAsFixed(12)}|$iterations';
    final cached = _lastImage;
    if (key == _lastKey && cached != null) {
      return cached;
    }

    final bytes = computeJuliaPerturbOrbitBytes(
      centerX: centerX,
      centerY: centerY,
      cReal: cReal,
      cImag: cImag,
      iterations: iterations,
    );

    final image = rasterizePerturbOrbitBytes(bytes, iterations * 2);
    _lastImage?.dispose();
    _lastImage = image;
    _lastKey = key;
    return image;
  }

}

/// Computes the Julia reference orbit and encodes each z component into RGBA
/// bytes for the perturbation shader's orbit texture.
///
/// Layout matches `fetchOrbit` in escape_time_perturb_gpu.frag:
/// pixel[2n] = Re(Z(n+1)) encoded, pixel[2n+1] = Im(Z(n+1)) encoded.
/// Pure (no dart:ui) so the encode contract is testable without a GPU.
Uint8List computeJuliaPerturbOrbitBytes({
  required double centerX,
  required double centerY,
  required double cReal,
  required double cImag,
  required int iterations,
}) {
  final totalPx = iterations * 2;
  final bytes = Uint8List(totalPx * 4);

  double zr = centerX;
  double zi = centerY;

  for (int i = 0; i < iterations; i++) {
    final zr2 = zr * zr - zi * zi + cReal;
    final zi2 = 2.0 * zr * zi + cImag;
    zr = zr2;
    zi = zi2;

    _encodeToRgb(zr, bytes, i * 8);
    _encodeToRgb(zi, bytes, i * 8 + 4);
  }

  return bytes;
}

/// Encode one orbit component with the shared 24-bit packing that matches the
/// shader decode (`r + g/256 + b/65536`).
///
/// History: this module previously used a 16-bit integer packing
/// (`scaled >> 8` / `scaled & 0xFF`) that did NOT match the shader decode and
/// degraded the Julia reference orbit to ~8 effective bits (decode error
/// ~1.7e-2 vs the intended ~4.8e-7) — see julia_perturb_orbit_encoding_test.
void _encodeToRgb(double value, Uint8List out, int offset) {
  final (high, mid, low) = packPerturbOrbitComponent(value);
  out[offset + 0] = high;
  out[offset + 1] = mid;
  out[offset + 2] = low;
  out[offset + 3] = 255;
}
