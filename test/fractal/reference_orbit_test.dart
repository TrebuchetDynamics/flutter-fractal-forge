import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/features/renderer/cpu/reference_orbit.dart';

void main() {
  group('MandelbrotReferenceOrbit', () {
    test('records a replayable orbit until the reference point escapes', () {
      final orbit = MandelbrotReferenceOrbit.generate(
        cReal: 1.0,
        cImaginary: 0.0,
        maxIterations: 8,
        bailout: 2.0,
      );

      expect(orbit.escaped, isTrue);
      expect(orbit.escapeIteration, 3);
      expect(orbit.samples, hasLength(3));
      expect(orbit.samples.last.iteration, 3);
      expect(orbit.samples.last.real, 5.0);
      expect(orbit.samples.last.imaginary, 0.0);
    });

    test('flags delta samples that cancel the reference orbit for refine', () {
      final orbit = MandelbrotReferenceOrbit.generate(
        cReal: 1.0,
        cImaginary: 0.0,
        maxIterations: 8,
        bailout: 2.0,
      );

      final stable = orbit.refineDecisionForDelta(
        iteration: 1,
        deltaReal: 1e-8,
        deltaImaginary: 0.0,
      );
      expect(stable.needsRefine, isFalse);
      expect(stable.reason, ReferenceOrbitRefineReason.accepted);

      final cancelled = orbit.refineDecisionForDelta(
        iteration: 1,
        deltaReal: -1.0,
        deltaImaginary: 0.0,
      );
      expect(cancelled.needsRefine, isTrue);
      expect(
          cancelled.reason, ReferenceOrbitRefineReason.referenceCancellation);
      expect(cancelled.iteration, 1);
    });

    test('fixed-point orbit matches double orbit at shallow coordinates', () {
      final doubleOrbit = MandelbrotReferenceOrbit.generate(
        cReal: -0.5,
        cImaginary: 0.25,
        maxIterations: 6,
        bailout: 2.0,
      );
      final fixedOrbit = MandelbrotFixedPointReferenceOrbit.generate(
        cReal: -0.5,
        cImaginary: 0.25,
        maxIterations: 6,
        bailout: 2.0,
        fractionalBits: 40,
      );

      expect(fixedOrbit.escaped, doubleOrbit.escaped);
      expect(fixedOrbit.escapeIteration, doubleOrbit.escapeIteration);
      expect(fixedOrbit.samples, hasLength(doubleOrbit.samples.length));
      for (var i = 0; i < doubleOrbit.samples.length; i++) {
        expect(fixedOrbit.samples[i].realAsDouble,
            closeTo(doubleOrbit.samples[i].real, 1e-9));
        expect(fixedOrbit.samples[i].imaginaryAsDouble,
            closeTo(doubleOrbit.samples[i].imaginary, 1e-9));
      }
    });

    test('fixed-point decimal input preserves precision beyond double input',
        () {
      final orbit =
          MandelbrotFixedPointReferenceOrbit.generateFromDecimalStrings(
        cReal: '1.000000000000000001',
        cImaginary: '-0.000000000000000001',
        maxIterations: 1,
        bailout: '4',
        fractionalBits: 80,
      );

      final scale = BigInt.one << 80;
      final decimalDenominator = BigInt.parse('1000000000000000000');
      final tinyUnit =
          (scale + decimalDenominator ~/ BigInt.two) ~/ decimalDenominator;

      expect(orbit.cReal, scale + tinyUnit);
      expect(orbit.cImaginary, -tinyUnit);
      expect(orbit.samples.single.real, orbit.cReal);
      expect(orbit.samples.single.imaginary, orbit.cImaginary);
    });

    test('fixed-point decimal input distinguishes collapsed doubles', () {
      const firstCenter = '1.000000000000000001';
      const secondCenter = '1.000000000000000002';

      expect(double.parse(firstCenter), double.parse(secondCenter));

      final firstOrbit =
          MandelbrotFixedPointReferenceOrbit.generateFromDecimalStrings(
        cReal: firstCenter,
        cImaginary: '0',
        maxIterations: 1,
        bailout: '4',
        fractionalBits: 80,
      );
      final secondOrbit =
          MandelbrotFixedPointReferenceOrbit.generateFromDecimalStrings(
        cReal: secondCenter,
        cImaginary: '0',
        maxIterations: 1,
        bailout: '4',
        fractionalBits: 80,
      );

      expect(secondOrbit.cReal, greaterThan(firstOrbit.cReal));
      expect(
        secondOrbit.samples.single.real,
        greaterThan(firstOrbit.samples.single.real),
      );
    });
  });
}
