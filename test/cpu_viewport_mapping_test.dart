import 'package:flutter_fractals/features/renderer/cpu_fractal_renderer.dart';
import 'package:flutter_fractals/features/renderer/cpu_render_isolate.dart';
import 'package:flutter_fractals/features/renderer/cpu_viewport_mapping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

void main() {
  group('CPU viewport mapping', () {
    test('subpixel samples stay inside the normalized viewport', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(
        viewport.normalizedSample(
          pixel: 0,
          extent: 2,
          sample: 0,
          samplesPerAxis: 1,
        ),
        closeTo(-0.5, 1e-12),
      );
      expect(
        viewport.normalizedSample(
          pixel: 1,
          extent: 2,
          sample: 0,
          samplesPerAxis: 1,
        ),
        closeTo(0.5, 1e-12),
      );
    });

    test('invalid subpixel sample candidates clamp to the pixel footprint', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(
        viewport.normalizedSample(
          pixel: 1,
          extent: 2,
          sample: 4,
          samplesPerAxis: 2,
        ),
        closeTo(0.75, 1e-12),
      );
      expect(
        viewport.normalizedSample(
          pixel: 0,
          extent: 2,
          sample: -1,
          samplesPerAxis: 2,
        ),
        closeTo(-0.75, 1e-12),
      );
    });

    test('edge pixels preserve iteration-buffer edge-inclusive contract', () {
      final viewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: 2,
      );

      expect(viewport.normalizedPixel(0, 2), -1.0);
      expect(viewport.normalizedPixel(1, 2), 1.0);
    });

    test('invalid zoom falls back to replayable unit-scale coordinates', () {
      for (final zoom in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final viewport = CpuViewportMapping(
          viewPan: Vector2.zero(),
          viewZoom: zoom,
          width: 2,
          height: 2,
        );

        expect(viewport.scale, 1.5, reason: 'zoom=$zoom');
        expect(
          viewport.coordinate(nx: 0.5, ny: -0.5),
          (0.75, -0.75),
          reason: 'zoom=$zoom',
        );
      }
    });

    test('invalid pan falls back to the replayable origin center', () {
      for (final pan in [
        Vector2(double.nan, 0.25),
        Vector2(double.infinity, double.negativeInfinity),
      ]) {
        final center = CpuViewportCenter.fromScalars(
          panX: pan.x,
          panY: pan.y,
        );
        final viewport = CpuViewportMapping(
          viewPan: pan,
          viewZoom: 1.0,
          width: 2,
          height: 2,
        );
        final expectedY = pan.y.isFinite ? pan.y : 0.0;

        expect(center.x, 0.0, reason: 'pan=$pan');
        expect(center.y, expectedY, reason: 'pan=$pan');
        expect(viewport.centerX, center.x, reason: 'pan=$pan');
        expect(viewport.centerY, center.y, reason: 'pan=$pan');
        expect(
          viewport.coordinate(nx: 0.5, ny: -0.5),
          (0.75, expectedY - 0.75),
          reason: 'pan=$pan',
        );
      }
    });

    test('invalid viewport dimensions fall back to square aspect', () {
      expect(
        CpuViewportDimensions.fromSize(width: 0, height: 2).aspect,
        1.0,
      );
      expect(
        CpuViewportDimensions.fromSize(width: 2, height: -1).aspect,
        1.0,
      );

      final zeroWidthViewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 0,
        height: 2,
      );
      final negativeHeightViewport = CpuViewportMapping(
        viewPan: Vector2.zero(),
        viewZoom: 1.0,
        width: 2,
        height: -1,
      );

      expect(zeroWidthViewport.coordinate(nx: 0.5, ny: -0.5), (0.75, -0.75));
      expect(
        negativeHeightViewport.coordinate(nx: 0.5, ny: -0.5),
        (0.75, -0.75),
      );
    });

    test('iteration buffer shares CPU render dimension validation', () async {
      await expectLater(
        renderCpuIterationBuffer(
          moduleId: 'mandelbrot',
          viewPan: Vector2.zero(),
          viewZoom: 1.0,
          iterations: 50,
          bailout: 4.0,
          juliaC: Vector2(-0.8, 0.156),
          width: 0,
          height: 2,
        ),
        throwsArgumentError,
      );

      await expectLater(
        renderCpuIterationBuffer(
          moduleId: 'mandelbrot',
          viewPan: Vector2.zero(),
          viewZoom: 1.0,
          iterations: 50,
          bailout: 4.0,
          juliaC: Vector2(-0.8, 0.156),
          width: 2,
          height: -1,
        ),
        throwsArgumentError,
      );
    });

    test('isolate sample mapping shares invalid zoom normalization', () {
      final coordinate = cpuViewportCoordinateForSample(
        panX: 0.0,
        panY: 0.0,
        zoom: double.nan,
        fullWidth: 2,
        fullHeight: 2,
        x: 1,
        y: 0,
        sampleOffsetX: 0.5,
        sampleOffsetY: 0.5,
      );

      expect(coordinate.x, 0.75);
      expect(coordinate.y, -0.75);
    });

    test('isolate sample mapping shares invalid pan normalization', () {
      final coordinate = cpuViewportCoordinateForSample(
        panX: double.nan,
        panY: double.infinity,
        zoom: 1.0,
        fullWidth: 2,
        fullHeight: 2,
        x: 1,
        y: 0,
        sampleOffsetX: 0.5,
        sampleOffsetY: 0.5,
      );

      expect(coordinate.x, 0.75);
      expect(coordinate.y, -0.75);
    });

    test('anti-aliasing grid makes non-square sample counts replayable', () {
      expect(CpuSampleGrid.fromRequestedCount(-1).samplesPerAxis, 1);
      expect(CpuSampleGrid.fromRequestedCount(1).totalSamples, 1);
      expect(CpuSampleGrid.fromRequestedCount(4).totalSamples, 4);
      expect(CpuSampleGrid.fromRequestedCount(8).samplesPerAxis, 3);
      expect(CpuSampleGrid.fromRequestedCount(8).totalSamples, 9);
    });

    test('anti-aliasing grid never drops requested multisample candidates', () {
      for (final requestedCount in [2, 3, 5, 6, 7, 8]) {
        final grid = CpuSampleGrid.fromRequestedCount(requestedCount);

        expect(
          grid.totalSamples,
          greaterThanOrEqualTo(requestedCount),
          reason: 'requestedCount=$requestedCount',
        );
        expect(grid.requestedCount, requestedCount);
        expect(grid.wasRoundedUp, isTrue);
      }
    });

    test('single-pixel iteration buffer samples the viewport center', () async {
      final buffer = await renderCpuIterationBuffer(
        moduleId: 'mandelbrot',
        viewPan: Vector2(-0.5, 0.0),
        viewZoom: 1.0,
        iterations: 50,
        bailout: 4.0,
        juliaC: Vector2(-0.8, 0.156),
        width: 1,
        height: 1,
      );

      expect(buffer, isNotNull);
      expect(buffer!.single, 50);
    });
  });
}
