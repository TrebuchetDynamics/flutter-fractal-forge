import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Julia perturbation reference orbit encoding (unified path)', () {
    const intendedResolution = 8.0 / 16777216.0;

    test('orbit bytes decode to ~24-bit precision against direct iteration',
        () {
      const cReal = -0.8;
      const cImag = 0.156;
      const centerX = 0.05;
      const centerY = 0.02;
      const iterations = 200;

      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cReal,
        juliaCImag: cImag,
      );

      // Store-Z0-first: pixel 0 is the center itself.
      double zr = centerX;
      double zi = centerY;
      var maxError = 0.0;
      var compared = 0;
      for (var n = 0; n < iterations; n++) {
        for (final (value, px) in [(zr, n * 2), (zi, n * 2 + 1)]) {
          if (value.abs() >= 3.9) continue;
          final i = px * 4;
          final decoded = decodePerturbOrbitComponent(
              result.bytes[i], result.bytes[i + 1], result.bytes[i + 2]);
          final error = (decoded - value).abs();
          if (error > maxError) maxError = error;
          compared++;
        }
        final nzr = zr * zr - zi * zi + cReal;
        final nzi = 2.0 * zr * zi + cImag;
        zr = nzr;
        zi = nzi;
        if (zr * zr + zi * zi > 1e6) break;
      }

      expect(compared, greaterThan(100));
      expect(maxError, lessThanOrEqualTo(intendedResolution * 1.5));
    });
  });
}