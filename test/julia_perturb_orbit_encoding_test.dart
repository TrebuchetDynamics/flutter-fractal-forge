import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_fractals/core/modules/julia_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Julia perturbation reference orbit encoding', () {
    // The perturbation shader decodes every orbit texture (all formulas,
    // including Julia) as 24-bit RGB fixed point over [-4, 4):
    //   value = r*8 - 4 + g/256*8 + b/65536*8
    // so the Julia orbit bytes must round-trip at that resolution too.
    const intendedResolution = 8.0 / 16777216.0;

    test('orbit bytes decode to ~24-bit precision against direct iteration',
        () {
      const cReal = -0.8;
      const cImag = 0.156;
      const centerX = 0.05;
      const centerY = 0.02;
      const iterations = 200;

      final bytes = computeJuliaPerturbOrbitBytes(
        centerX: centerX,
        centerY: centerY,
        cReal: cReal,
        cImag: cImag,
        iterations: iterations,
      );

      // Reference: the same orbit in raw double precision.
      double zr = centerX;
      double zi = centerY;
      var maxError = 0.0;
      var compared = 0;
      for (var n = 0; n < iterations; n++) {
        final zr2 = zr * zr - zi * zi + cReal;
        final zi2 = 2.0 * zr * zi + cImag;
        zr = zr2;
        zi = zi2;

        for (final (value, px) in [(zr, n * 2), (zi, n * 2 + 1)]) {
          // Skip values clamped by the [-4, 4) encoding range.
          if (value.abs() >= 3.9) continue;
          final i = px * 4;
          final decoded = decodePerturbOrbitComponent(
            bytes[i],
            bytes[i + 1],
            bytes[i + 2],
          );
          final error = (decoded - value).abs();
          if (error > maxError) maxError = error;
          compared++;
        }
      }

      expect(compared, greaterThan(100),
          reason: 'orbit should stay in encodable range for this seed');
      expect(
        maxError,
        lessThanOrEqualTo(intendedResolution * 1.5),
        reason:
            'orbit decode error ${maxError.toStringAsExponential(3)} exceeds '
            'the shader\'s 24-bit resolution '
            '${intendedResolution.toStringAsExponential(3)} — the encode does '
            'not match fetchOrbit() in escape_time_perturb_gpu.frag',
      );
    });

    test('finest (blue) channel carries signal', () {
      // A step of a few 24-bit quanta must change the bytes; this fails if
      // the encoding regresses to 16-bit (blue channel always zero).
      final a = computeJuliaPerturbOrbitBytes(
        centerX: 0.1,
        centerY: 0.1,
        cReal: -0.8,
        cImag: 0.156,
        iterations: 32,
      );
      final blueUsed = List<int>.generate(32 * 2, (px) => a[px * 4 + 2])
          .any((b) => b != 0);
      expect(blueUsed, isTrue,
          reason: 'blue channel unused — encoding is not 24-bit');
    });
  });
}
