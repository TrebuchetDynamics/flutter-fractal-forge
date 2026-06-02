import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' show Vector2;

import 'cpu_formulas.dart';
import 'cpu_viewport_mapping.dart';

export 'cpu_viewport_mapping.dart'
    show CpuRenderDimensions, CpuRenderRect, CpuRenderSamplePoint;

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
  final bytes = renderCpuRectRgba(
    moduleId: req.moduleId,
    panX: req.panX,
    panY: req.panY,
    zoom: req.zoom,
    iterations: req.iterations,
    bailout: req.bailout,
    juliaCX: req.juliaCX,
    juliaCY: req.juliaCY,
    // Full viewport
    fullWidth: req.width,
    fullHeight: req.height,
    // Tile == full
    x0: 0,
    y0: 0,
    w: req.width,
    h: req.height,
    sampleCount: req.sampleCount,
  );
  return CpuRenderResponse(rgba: bytes, width: req.width, height: req.height);
}

final class CpuTileRenderRequest {
  const CpuTileRenderRequest({
    required this.moduleId,
    required this.panX,
    required this.panY,
    required this.zoom,
    required this.iterations,
    required this.bailout,
    required this.juliaCX,
    required this.juliaCY,
    required this.fullWidth,
    required this.fullHeight,
    required this.x0,
    required this.y0,
    required this.w,
    required this.h,
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

  final int fullWidth;
  final int fullHeight;
  final int x0;
  final int y0;
  final int w;
  final int h;
  final int sampleCount;
}

final class CpuTileRenderResponse {
  const CpuTileRenderResponse({
    required this.x0,
    required this.y0,
    required this.w,
    required this.h,
    required this.rgba,
  });

  final int x0;
  final int y0;
  final int w;
  final int h;
  final Uint8List rgba;
}

final class CpuViewportCoordinate {
  const CpuViewportCoordinate(this.x, this.y);

  final double x;
  final double y;
}

/// Maps a pixel sample to the CPU fractal plane.
///
/// [sampleOffsetX] and [sampleOffsetY] are normalized offsets within the pixel
/// (0.5 means pixel center). Dividing by the full dimensions keeps one-pixel
/// renders centered on pan and keeps opposite edge pixel centers symmetric.
CpuViewportCoordinate cpuViewportCoordinateForSample({
  required double panX,
  required double panY,
  required double zoom,
  required int fullWidth,
  required int fullHeight,
  required int x,
  required int y,
  required double sampleOffsetX,
  required double sampleOffsetY,
}) {
  CpuRenderSamplePoint(
    fullWidth: fullWidth,
    fullHeight: fullHeight,
    x: x,
    y: y,
  ).validate();

  final viewport = CpuViewportMapping.fromScalars(
    panX: panX,
    panY: panY,
    viewZoom: zoom,
    width: fullWidth,
    height: fullHeight,
  );
  final nx = viewport.normalizedSampleOffset(
    pixel: x,
    extent: fullWidth,
    sampleOffset: sampleOffsetX,
  );
  final ny = viewport.normalizedSampleOffset(
    pixel: y,
    extent: fullHeight,
    sampleOffset: sampleOffsetY,
  );
  final coordinate = viewport.coordinate(nx: nx, ny: ny);

  return CpuViewportCoordinate(coordinate.$1, coordinate.$2);
}

CpuTileRenderResponse renderCpuTileInIsolate(CpuTileRenderRequest req) {
  final bytes = renderCpuRectRgba(
    moduleId: req.moduleId,
    panX: req.panX,
    panY: req.panY,
    zoom: req.zoom,
    iterations: req.iterations,
    bailout: req.bailout,
    juliaCX: req.juliaCX,
    juliaCY: req.juliaCY,
    fullWidth: req.fullWidth,
    fullHeight: req.fullHeight,
    x0: req.x0,
    y0: req.y0,
    w: req.w,
    h: req.h,
    sampleCount: req.sampleCount,
  );

  return CpuTileRenderResponse(
    x0: req.x0,
    y0: req.y0,
    w: req.w,
    h: req.h,
    rgba: bytes,
  );
}

/// Renders one CPU RGBA tile from an explicit full-viewport rectangle.
///
/// This pure raster helper is shared by direct, full-frame isolate, and tile
/// isolate render paths so they fail on the same invalid dimensions and sample
/// the same viewport coordinates.
Uint8List renderCpuRectRgba({
  required String moduleId,
  required double panX,
  required double panY,
  required double zoom,
  required int iterations,
  required double bailout,
  required double juliaCX,
  required double juliaCY,
  required int fullWidth,
  required int fullHeight,
  required int x0,
  required int y0,
  required int w,
  required int h,
  required int sampleCount,
}) {
  CpuRenderRect(
    fullWidth: fullWidth,
    fullHeight: fullHeight,
    x0: x0,
    y0: y0,
    w: w,
    h: h,
  ).validate();

  final bytes = Uint8List(w * h * 4);
  final sampleGrid = CpuSampleGrid.fromRequestedCount(sampleCount);

  final juliaC = Vector2(juliaCX, juliaCY);
  final formula = cpuFormulaForModuleId(moduleId);
  final viewport = CpuViewportMapping.fromScalars(
    panX: panX,
    panY: panY,
    viewZoom: zoom,
    width: fullWidth,
    height: fullHeight,
  );

  for (int ty = 0; ty < h; ty++) {
    final y = y0 + ty;
    for (int tx = 0; tx < w; tx++) {
      final x = x0 + tx;

      double rAcc = 0;
      double gAcc = 0;
      double bAcc = 0;

      for (int sy = 0; sy < sampleGrid.samplesPerAxis; sy++) {
        for (int sx = 0; sx < sampleGrid.samplesPerAxis; sx++) {
          final nx = viewport.normalizedSample(
            pixel: x,
            extent: fullWidth,
            sample: sx,
            samplesPerAxis: sampleGrid.samplesPerAxis,
          );
          final ny = viewport.normalizedSample(
            pixel: y,
            extent: fullHeight,
            sample: sy,
            samplesPerAxis: sampleGrid.samplesPerAxis,
          );
          final coordinate = viewport.coordinate(nx: nx, ny: ny);

          final color = formula(
            coordinate.$1,
            coordinate.$2,
            iterations,
            bailout,
            juliaC,
          );
          rAcc += color.$1;
          gAcc += color.$2;
          bAcc += color.$3;
        }
      }

      final idx = (ty * w + tx) * 4;
      bytes[idx + 0] = (rAcc / sampleGrid.totalSamples).clamp(0, 255).round();
      bytes[idx + 1] = (gAcc / sampleGrid.totalSamples).clamp(0, 255).round();
      bytes[idx + 2] = (bAcc / sampleGrid.totalSamples).clamp(0, 255).round();
      bytes[idx + 3] = 255;
    }
  }

  return bytes;
}
