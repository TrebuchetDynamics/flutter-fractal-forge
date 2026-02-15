import 'dart:math' as math;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas.dart';

/// Message used to request a CPU frame render from an isolate.
final class CpuRenderRequest {
  const CpuRenderRequest({
    required this.moduleId,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.iterations,
    required this.bailout,
    required this.juliaCX,
    required this.juliaCY,
    required this.width,
    required this.height,
    required this.sampleCount,
  });

  final String moduleId;
  final double panX;
  final double panY;
  final double zoom;
  final int iterations;
  final double bailout;
  final double juliaCX;
  final double juliaCY;
  final int width;
  final int height;
  final int sampleCount;
}

final class CpuRenderResponse {
  const CpuRenderResponse({
    required this.rgba,
    required this.width,
    required this.height,
  });

  /// RGBA8888 bytes.
  final Uint8List rgba;
  final int width;
  final int height;
}

/// Top-level entrypoint suitable for [Isolate.run].
CpuRenderResponse renderCpuFrameInIsolate(CpuRenderRequest req) {
  final centerX = req.panX;
  final centerY = req.panY;
  final zoom = req.zoom <= 0 ? 1.0 : req.zoom;

  final scale = 3.0 / zoom;
  final aspect = req.width / req.height;

  final bytes = Uint8List(req.width * req.height * 4);
  final samplesPerAxis = math.max(1, math.sqrt(req.sampleCount).round());
  final totalSamples = samplesPerAxis * samplesPerAxis;

  final juliaC = Vector2(req.juliaCX, req.juliaCY);

  final formula =
      cpuFormulasByModuleId[req.moduleId] ?? cpuFormulasByModuleId['mandelbrot']!;

  for (int y = 0; y < req.height; y++) {
    for (int x = 0; x < req.width; x++) {
      double rAcc = 0;
      double gAcc = 0;
      double bAcc = 0;

      for (int sy = 0; sy < samplesPerAxis; sy++) {
        for (int sx = 0; sx < samplesPerAxis; sx++) {
          final subX = (x + (sx + 0.5) / samplesPerAxis) / (req.width - 1);
          final subY = (y + (sy + 0.5) / samplesPerAxis) / (req.height - 1);
          final nx = subX * 2.0 - 1.0;
          final ny = subY * 2.0 - 1.0;

          final cx = centerX + nx * scale * aspect;
          final cy = centerY + ny * scale;

          final color = formula(cx, cy, req.iterations, req.bailout, juliaC);
          rAcc += color.$1;
          gAcc += color.$2;
          bAcc += color.$3;
        }
      }

      final idx = (y * req.width + x) * 4;
      bytes[idx + 0] = (rAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 1] = (gAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 2] = (bAcc / totalSamples).clamp(0, 255).round();
      bytes[idx + 3] = 255;
    }
  }

  return CpuRenderResponse(rgba: bytes, width: req.width, height: req.height);
}
