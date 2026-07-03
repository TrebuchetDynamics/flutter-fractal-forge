import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('julia-seeded reference orbit', () {
    // Shader decode of one packed component (r + g/256 + b/65536 over [-4,4)).
    double decodeAt(List<int> bytes, int px) => decodePerturbOrbitComponent(
        bytes[px * 4], bytes[px * 4 + 1], bytes[px * 4 + 2]);

    test('z0 = center, c fixed; stores Z0 first; matches direct iteration',
        () {
      const cr = -1.0; // basilica: 0 -> -1 -> 0 exact 2-cycle from z0=0
      const ci = 0.0;
      const centerX = 0.3;
      const centerY = 0.2;
      const iterations = 100;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cr,
        juliaCImag: ci,
      );

      // pixel 0 must be Z0 = center (store-before-iterate convention).
      expect(decodeAt(result.bytes, 0), closeTo(centerX, 1e-6));
      expect(decodeAt(result.bytes, 1), closeTo(centerY, 1e-6));

      // Full orbit must match direct double iteration of z^2 + c.
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        if (zr.abs() < 3.9 && zi.abs() < 3.9) {
          expect(decodeAt(result.bytes, n * 2), closeTo(zr, 1e-6),
              reason: 'Re(Z$n)');
          expect(decodeAt(result.bytes, n * 2 + 1), closeTo(zi, 1e-6),
              reason: 'Im(Z$n)');
        }
        final nzr = zr * zr - zi * zi + cr;
        final nzi = 2.0 * zr * zi + ci;
        zr = nzr;
        zi = nzi;
        if (zr * zr + zi * zi > 1e6) break;
      }
    });

    test('period detection still works with a julia seed', () {
      // z0 = 0 with c = -1 is the exact 0,-1 2-cycle.
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: 0.0,
        centerY: 0.0,
        iterations: 500,
        juliaCReal: -1.0,
        juliaCImag: 0.0,
      );
      expect(result.detectedPeriod, 2);
      expect(result.computedIterations, lessThan(10));
    });

    test(
        'delta-recurrence mirror: julia-mode init tracks direct iteration '
        'and the old dz0=0 init provably renders flat (GPU-free regression)',
        () {
      // Mirrors the shader math for formula 0 (deltaMandelbrot):
      //   dzNew = 2*Zn*dz + dz^2 + dc
      // Julia mode: dz0 = pixel offset, dc = 0 (spec design).
      // Old behavior: dz0 = 0 with deltaJulia (no dc) => dz stays 0.
      const cr = -1.0, ci = 0.0;
      const centerX = -0.6180339887498949, centerY = 0.0; // repelling fixed pt
      const offX = 1e-9, offY = 5e-10; // pixel offset at deep zoom
      const iterations = 60;

      // Reference orbit Zn (raw doubles, same recurrence as production).
      final zn = List<(double, double)>.filled(iterations, (0, 0));
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        zn[n] = (zr, zi);
        final nzr = zr * zr - zi * zi + cr;
        final nzi = 2.0 * zr * zi + ci;
        zr = nzr;
        zi = nzi;
      }

      // New semantics: dz0 = offset, dc = 0.
      double dzr = offX, dzi = offY;
      // Direct iteration of the actual pixel point for comparison.
      double pr = centerX + offX, pi = centerY + offY;
      for (var n = 0; n < iterations; n++) {
        final (zrn, zin) = zn[n];
        final fullR = zrn + dzr, fullI = zin + dzi;
        expect(fullR, closeTo(pr, 1e-9 + pr.abs() * 1e-6),
            reason: 'Re mismatch at n=$n');
        expect(fullI, closeTo(pi, 1e-9 + pi.abs() * 1e-6),
            reason: 'Im mismatch at n=$n');
        // dzNew = 2*Zn*dz + dz^2 (dc = 0 in julia mode)
        final ndzr = 2.0 * (zrn * dzr - zin * dzi) + (dzr * dzr - dzi * dzi);
        final ndzi = 2.0 * (zrn * dzi + zin * dzr) + 2.0 * dzr * dzi;
        dzr = ndzr;
        dzi = ndzi;
        final npr = pr * pr - pi * pi + cr;
        final npi = 2.0 * pr * pi + ci;
        pr = npr;
        pi = npi;
      }

      // Old semantics: dz0 = 0 and no dc source term => dz identically 0,
      // i.e. every pixel collapses onto the reference orbit (flat frame).
      double odzr = 0.0, odzi = 0.0;
      for (var n = 0; n < iterations; n++) {
        final (zrn, zin) = zn[n];
        final ndzr =
            2.0 * (zrn * odzr - zin * odzi) + (odzr * odzr - odzi * odzi);
        final ndzi =
            2.0 * (zrn * odzi + zin * odzr) + 2.0 * odzr * odzi;
        odzr = ndzr;
        odzi = ndzi;
      }
      expect(odzr, 0.0);
      expect(odzi, 0.0);
    });

    test('variant base formulas iterate their own recurrence (celtic)', () {
      const cr = -0.70176, ci = -0.3842; // celtic_julia shader seed
      const centerX = 0.1, centerY = 0.1;
      const iterations = 50;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'celtic',
        centerX: centerX,
        centerY: centerY,
        iterations: iterations,
        juliaCReal: cr,
        juliaCImag: ci,
      );
      double zr = centerX, zi = centerY;
      for (var n = 0; n < iterations; n++) {
        if (zr.abs() < 3.9 && zi.abs() < 3.9) {
          expect(decodeAt(result.bytes, n * 2), closeTo(zr, 1e-6));
          expect(decodeAt(result.bytes, n * 2 + 1), closeTo(zi, 1e-6));
        }
        // Celtic: (|Re(z^2)|, Im(z^2)) + c
        final re2 = zr * zr - zi * zi;
        final im2 = 2.0 * zr * zi;
        zr = re2.abs() + cr;
        zi = im2 + ci;
        if (zr * zr + zi * zi > 1e6) break;
      }
    });
  });
}