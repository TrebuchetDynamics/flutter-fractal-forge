import 'dart:math' as math;

import 'package:flutter_fractals/core/modules/escape_time_perturb_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('perturbation reference orbit encoding', () {
    // The orbit texture stores each component in 2 uint8 channels (16 bits) over
    // the [-4, 4) range, so the intended resolution is 8 / 65535 ≈ 1.22e-4.
    const intendedResolution = 8.0 / 65535.0;

    test('pack/decode round-trips to ~16-bit precision across [-4, 4)', () {
      var maxError = 0.0;
      for (var v = -3.9999; v < 4.0; v += 0.0003) {
        final (high, low) = packPerturbOrbitComponent(v);
        final decoded = decodePerturbOrbitComponent(high, low);
        final error = (decoded - v).abs();
        if (error > maxError) maxError = error;
      }
      // Regression guard: the earlier 16-bit-integer packing fed through the
      // shader's `r + g/256` decode degraded to ~8 bits (~3e-2 error). Require
      // the full ~16-bit precision the texture was sized for.
      expect(
        maxError,
        lessThanOrEqualTo(intendedResolution),
        reason: 'round-trip error ${maxError.toStringAsExponential(3)} exceeds '
            'the intended 16-bit resolution '
            '${intendedResolution.toStringAsExponential(3)}',
      );
      // Sanity: effective bits should be ~16, not ~8.
      final effectiveBits = math.log(8.0 / maxError) / math.ln2;
      expect(effectiveBits, greaterThan(15.0));
    });

    test('low byte is actually used (not wasted)', () {
      // Two values one intended-resolution step apart must differ in the encoded
      // bytes — the bug left adjacent fine steps encoding identically.
      final a = packPerturbOrbitComponent(0.0);
      final b = packPerturbOrbitComponent(0.0 + intendedResolution * 4);
      expect(a == b, isFalse, reason: 'fine steps must change the encoding');
    });

    test('endpoints encode within range', () {
      expect(packPerturbOrbitComponent(-4.0), (0, 0));
      final (high, low) = packPerturbOrbitComponent(3.999999);
      expect(high, inInclusiveRange(0, 255));
      expect(low, inInclusiveRange(0, 255));
      // Out-of-range inputs are clamped, not crashing.
      expect(() => packPerturbOrbitComponent(100.0), returnsNormally);
      expect(() => packPerturbOrbitComponent(-100.0), returnsNormally);
    });
  });
}
