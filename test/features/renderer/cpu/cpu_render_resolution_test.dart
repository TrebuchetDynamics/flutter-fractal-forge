import 'package:flutter_fractals/features/renderer/cpu/cpu_render_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpuRenderResolution', () {
    test('preserves interactive preview sizing for normal viewports', () {
      final resolution = CpuRenderResolution.forPass(
        targetWidth: 360,
        targetHeight: 300,
        resolutionScale: 0.8,
      );

      expect(resolution.width, 288);
      expect(resolution.height, 240);
    });

    test('keeps interactive preview above the visible floor when possible', () {
      final resolution = CpuRenderResolution.forPass(
        targetWidth: 240,
        targetHeight: 240,
        resolutionScale: 0.5,
      );

      expect(resolution.width, CpuRenderResolution.minInteractiveDimension);
      expect(resolution.height, CpuRenderResolution.minInteractiveDimension);
    });

    test('does not invert clamp bounds for tiny preview viewports', () {
      final resolution = CpuRenderResolution.forPass(
        targetWidth: 120,
        targetHeight: 80,
        resolutionScale: 0.8,
      );

      expect(resolution.width, 120);
      expect(resolution.height, 80);
    });

    test('keeps refine pass at target size', () {
      final resolution = CpuRenderResolution.forPass(
        targetWidth: 120,
        targetHeight: 80,
        resolutionScale: 1.0,
      );

      expect(resolution.width, 120);
      expect(resolution.height, 80);
    });

    test('treats malformed resolution scales as full target size', () {
      for (final scale in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final resolution = CpuRenderResolution.forPass(
          targetWidth: 120,
          targetHeight: 80,
          resolutionScale: scale,
        );

        expect(resolution.width, 120, reason: 'scale=$scale');
        expect(resolution.height, 80, reason: 'scale=$scale');
      }
    });

    test('applies slow-mode high-resolution floor and cap', () {
      final small = CpuRenderResolution.forSlowMode(
        targetWidth: 120,
        targetHeight: 80,
      );
      final huge = CpuRenderResolution.forSlowMode(
        targetWidth: 5000,
        targetHeight: 5000,
      );

      expect(small.width, CpuRenderResolution.minSlowModeWidth);
      expect(small.height, CpuRenderResolution.minSlowModeHeight);
      expect(huge.width, CpuRenderResolution.maxSlowModeWidth);
      expect(huge.height, CpuRenderResolution.maxSlowModeHeight);
    });
  });
}
