import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('perturbation reference orbit encoding (24-bit RGB)', () {
    // The orbit texture stores each component in 3 uint8 channels (24 bits) over
    // the [-4, 4) range, so the intended resolution is 8 / 2^24 ≈ 4.8e-7.
    const intendedResolution = 8.0 / 16777216.0;

    test('pack/decode round-trips to ~24-bit precision across [-4, 4)', () {
      var maxError = 0.0;
      for (var v = -3.9999; v < 4.0; v += 0.0003) {
        final (high, mid, low) = packPerturbOrbitComponent(v);
        final decoded = decodePerturbOrbitComponent(high, mid, low);
        final error = (decoded - v).abs();
        if (error > maxError) maxError = error;
      }
      // Require the full ~24-bit precision the 3-channel texture provides.
      // (The original 16-bit-integer packing degraded to ~8 effective bits.)
      expect(
        maxError,
        lessThanOrEqualTo(intendedResolution * 1.5),
        reason: 'round-trip error ${maxError.toStringAsExponential(3)} exceeds '
            'the intended 24-bit resolution '
            '${intendedResolution.toStringAsExponential(3)}',
      );
      final effectiveBits = math.log(8.0 / maxError) / math.ln2;
      expect(effectiveBits, greaterThan(23.0),
          reason: 'expected ~24 effective bits, got '
              '${effectiveBits.toStringAsFixed(1)}');
    });

    test('all three channels carry signal (none wasted)', () {
      // Steps far below 16-bit resolution must still change the encoding — this
      // fails if the blue (finest) byte is dropped, regressing to 16-bit.
      final a = packPerturbOrbitComponent(0.0);
      final b = packPerturbOrbitComponent(0.0 + intendedResolution * 4);
      expect(a == b, isFalse, reason: '24-bit-scale steps must change bytes');
    });

    test('endpoints and out-of-range inputs are safe', () {
      expect(packPerturbOrbitComponent(-4.0), (0, 0, 0));
      final (high, mid, low) = packPerturbOrbitComponent(3.999999);
      for (final c in [high, mid, low]) {
        expect(c, inInclusiveRange(0, 255));
      }
      expect(() => packPerturbOrbitComponent(100.0), returnsNormally);
      expect(() => packPerturbOrbitComponent(-100.0), returnsNormally);
    });
  });
}
