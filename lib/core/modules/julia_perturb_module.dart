import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:flutter_fractals/core/services/palette_service.dart';

/// Wraps the Julia module with perturbation-theory GPU shader at deep zoom.
FractalModule buildJuliaPerturbModule(FractalModule standardModule) {
  return FractalModule(
    id: standardModule.id,
    displayName: standardModule.displayName,
    dimension: standardModule.dimension,
    shaderAsset: 'shaders/escape_time_perturb_gpu.frag',
    parameters: standardModule.parameters,
    defaultPreset: standardModule.defaultPreset,
    builtInPresets: standardModule.builtInPresets,
    setUniforms: (shader, state, size, time) {
      final iterations = readDouble(state.params, 'iterations', 160)
          .clamp(4.0, 2000.0)
          .toInt();
      final bailout = readDouble(state.params, 'bailout', 4.0);
      final colorScheme = readDouble(state.params, 'colorScheme', 0.0).round();
      final cReal = readDouble(state.params, 'juliaCReal', -0.8);
      final cImag = readDouble(state.params, 'juliaCImag', 0.156);

      final palette = PaletteService.instance.paletteAtIndex(colorScheme);
      final paletteTex = PaletteService.instance.paletteTexture(palette);
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
      shader.setFloat(10, 0.0); // uExtra0
      shader.setFloat(11, 0.0); // uExtra1
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

    final totalPx = iterations * 2;
    final bytes = Uint8List(totalPx * 4);

    double zr = centerX;
    double zi = centerY;

    for (int i = 0; i < iterations; i++) {
      final zr2 = zr * zr - zi * zi + cReal;
      final zi2 = 2.0 * zr * zi + cImag;
      zr = zr2;
      zi = zi2;

      _encodeToRg(zr, bytes, i * 8);
      _encodeToRg(zi, bytes, i * 8 + 4);
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, totalPx.toDouble(), 1),
    );
    final paint = ui.Paint();
    for (int x = 0; x < totalPx; x++) {
      final i = x * 4;
      paint.color = ui.Color.fromARGB(
        bytes[i + 3],
        bytes[i + 0],
        bytes[i + 1],
        bytes[i + 2],
      );
      canvas.drawRect(ui.Rect.fromLTWH(x.toDouble(), 0, 1, 1), paint);
    }

    final image = recorder.endRecording().toImageSync(totalPx, 1);
    _lastImage?.dispose();
    _lastImage = image;
    _lastKey = key;
    return image;
  }

  void _encodeToRg(double value, Uint8List out, int offset) {
    final clamped = value.clamp(-4.0, 3.999999).toDouble();
    final normalized = ((clamped + 4.0) / 8.0).clamp(0.0, 1.0);
    final scaled = (normalized * 65535.0).round().clamp(0, 65535);
    final r = (scaled >> 8) & 0xFF;
    final g = scaled & 0xFF;
    out[offset + 0] = r;
    out[offset + 1] = g;
    out[offset + 2] = 0;
    out[offset + 3] = 255;
  }
}
