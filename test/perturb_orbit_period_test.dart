import 'dart:typed_data';

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

/// Naive full-iteration reference (the pre-period-detection behavior):
/// iterates every entry, same encoding, same escape break.
Uint8List naiveMandelbrotOrbitBytes({
  required double cx,
  required double cy,
  required int iterations,
}) {
  final bytes = Uint8List(iterations * 2 * 4);
  double zr = 0.0;
  double zi = 0.0;
  for (int n = 0; n < iterations; n++) {
    for (final (value, offset) in [(zr, n * 8), (zi, n * 8 + 4)]) {
      final (high, mid, low) = packPerturbOrbitComponent(value);
      bytes[offset] = high;
      bytes[offset + 1] = mid;
      bytes[offset + 2] = low;
      bytes[offset + 3] = 255;
    }
    final nzr = zr * zr - zi * zi + cx;
    final nzi = 2.0 * zr * zi + cy;
    zr = nzr;
    zi = nzi;
    if (zr * zr + zi * zi > 1e6) break;
  }
  return bytes;
}

void main() {
  group('reference orbit period detection (TODO P1-1c)', () {
    test('c = 0: fixed point (period 1) detected, tail byte-identical', () {
      const iterations = 500;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: 0.0,
        centerY: 0.0,
        iterations: iterations,
      );
      expect(result.detectedPeriod, 1);
      expect(result.computedIterations, lessThan(10),
          reason: 'fixed point should stop iteration almost immediately');
      expect(
        result.bytes,
        naiveMandelbrotOrbitBytes(cx: 0, cy: 0, iterations: iterations),
        reason: 'cycle-filled bytes must match full iteration exactly',
      );
    });

    test('c = -1: exact 2-cycle detected, tail byte-identical', () {
      const iterations = 500;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: -1.0,
        centerY: 0.0,
        iterations: iterations,
      );
      expect(result.detectedPeriod, 2);
      expect(result.computedIterations, lessThan(10));
      expect(
        result.bytes,
        naiveMandelbrotOrbitBytes(cx: -1, cy: 0, iterations: iterations),
      );
    });

    test('c = -0.5: attracting fixed point detected after convergence', () {
      const iterations = 500;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: -0.5,
        centerY: 0.0,
        iterations: iterations,
      );
      // The fixed point's derivative is negative (~-0.73), so convergence
      // oscillates and the detector may lock onto the 2-cycle first; any
      // multiple of the fundamental period yields a correct fill.
      expect(result.detectedPeriod, anyOf(1, 2));
      expect(result.computedIterations, lessThan(150),
          reason: 'linear convergence reaches 1e-9 well within 150 iterations');
      // Approximate cycle: filled bytes may differ from full iteration by at
      // most one blue-channel LSB, i.e. decoded error stays below the 24-bit
      // texture quantum.
      final naive =
          naiveMandelbrotOrbitBytes(cx: -0.5, cy: 0, iterations: iterations);
      var maxError = 0.0;
      for (var px = 0; px < iterations * 2; px++) {
        final i = px * 4;
        final got = decodePerturbOrbitComponent(
            result.bytes[i], result.bytes[i + 1], result.bytes[i + 2]);
        final want = decodePerturbOrbitComponent(
            naive[i], naive[i + 1], naive[i + 2]);
        final error = (got - want).abs();
        if (error > maxError) maxError = error;
      }
      expect(maxError, lessThanOrEqualTo(8.0 / 16777216.0 * 1.5),
          reason: 'cycle fill must stay within one texture quantum of full '
              'iteration, got ${maxError.toStringAsExponential(3)}');
    });

    test('escaping center: unchanged behavior, no period claimed', () {
      const iterations = 200;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: 1.0,
        centerY: 0.0,
        iterations: iterations,
      );
      expect(result.detectedPeriod, 0);
      expect(
        result.bytes,
        naiveMandelbrotOrbitBytes(cx: 1, cy: 0, iterations: iterations),
      );
    });

    test('chaotic bounded center: no false period, byte-identical', () {
      // c = -1.9 on the real axis is chaotic (bounded, aperiodic).
      const iterations = 500;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'mandelbrot',
        centerX: -1.9,
        centerY: 0.0,
        iterations: iterations,
      );
      expect(result.detectedPeriod, 0);
      expect(result.computedIterations, iterations);
      expect(
        result.bytes,
        naiveMandelbrotOrbitBytes(cx: -1.9, cy: 0, iterations: iterations),
      );
    });

    test('phoenix memory term: detected cycle respects (z, z_prev) state', () {
      // Phoenix with p=0.3 at a converging center; the consecutive-pair
      // confirmation must not fire on a z-only coincidence.
      const iterations = 500;
      final result = computeEscapeTimePerturbOrbitBytes(
        moduleId: 'phoenix',
        centerX: -0.3,
        centerY: 0.0,
        iterations: iterations,
        phoenixP: 0.3,
      );
      // Whatever the detector decides, the produced orbit must match full
      // iteration to within one texture quantum.
      final full = _naivePhoenixOrbitBytes(
        cx: -0.3,
        cy: 0.0,
        p: 0.3,
        iterations: iterations,
      );
      var maxError = 0.0;
      for (var px = 0; px < iterations * 2; px++) {
        final i = px * 4;
        final got = decodePerturbOrbitComponent(
            result.bytes[i], result.bytes[i + 1], result.bytes[i + 2]);
        final want =
            decodePerturbOrbitComponent(full[i], full[i + 1], full[i + 2]);
        final error = (got - want).abs();
        if (error > maxError) maxError = error;
      }
      expect(maxError, lessThanOrEqualTo(8.0 / 16777216.0 * 1.5));
    });
  });
}

Uint8List _naivePhoenixOrbitBytes({
  required double cx,
  required double cy,
  required double p,
  required int iterations,
}) {
  final bytes = Uint8List(iterations * 2 * 4);
  double zr = 0.0, zi = 0.0, prevZr = 0.0, prevZi = 0.0;
  for (int n = 0; n < iterations; n++) {
    for (final (value, offset) in [(zr, n * 8), (zi, n * 8 + 4)]) {
      final (high, mid, low) = packPerturbOrbitComponent(value);
      bytes[offset] = high;
      bytes[offset + 1] = mid;
      bytes[offset + 2] = low;
      bytes[offset + 3] = 255;
    }
    final nzr = zr * zr - zi * zi + cx + p * prevZr;
    final nzi = 2.0 * zr * zi + cy + p * prevZi;
    prevZr = zr;
    prevZi = zi;
    zr = nzr;
    zi = nzi;
    if (zr * zr + zi * zi > 1e6) break;
  }
  return bytes;
}
