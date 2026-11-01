/// CPU-side reference orbit model for Mandelbrot-family deep-zoom experiments.
///
/// This is intentionally independent from shader code. It gives the Precision
/// Ladder a tested data shape before GPU perturbation wiring is added.
final class MandelbrotReferenceOrbit {
  const MandelbrotReferenceOrbit({
    required this.cReal,
    required this.cImaginary,
    required this.maxIterations,
    required this.bailout,
    required this.samples,
    required this.escapeIteration,
  });

  final double cReal;
  final double cImaginary;
  final int maxIterations;
  final double bailout;
  final List<ReferenceOrbitSample> samples;
  final int? escapeIteration;

  bool get escaped => escapeIteration != null;

  ReferenceOrbitRefineDecision refineDecisionForDelta({
    required int iteration,
    required double deltaReal,
    required double deltaImaginary,
    double glitchTolerance = 1e-6,
  }) {
    final sample = sampleAt(iteration);
    if (sample == null) {
      return ReferenceOrbitRefineDecision(
        iteration: iteration,
        reason: ReferenceOrbitRefineReason.missingReferenceSample,
        referenceMagnitudeSquared: 0.0,
        reconstructedMagnitudeSquared: 0.0,
      );
    }

    final reconstructedReal = sample.real + deltaReal;
    final reconstructedImaginary = sample.imaginary + deltaImaginary;
    final reconstructedMagnitudeSquared =
        reconstructedReal * reconstructedReal +
            reconstructedImaginary * reconstructedImaginary;
    final threshold = sample.magnitudeSquared * glitchTolerance;
    final reason = reconstructedMagnitudeSquared < threshold
        ? ReferenceOrbitRefineReason.referenceCancellation
        : ReferenceOrbitRefineReason.accepted;

    return ReferenceOrbitRefineDecision(
      iteration: iteration,
      reason: reason,
      referenceMagnitudeSquared: sample.magnitudeSquared,
      reconstructedMagnitudeSquared: reconstructedMagnitudeSquared,
    );
  }

  ReferenceOrbitSample? sampleAt(int iteration) {
    for (final sample in samples) {
      if (sample.iteration == iteration) return sample;
    }
    return null;
  }

  static MandelbrotReferenceOrbit generate({
    required double cReal,
    required double cImaginary,
    required int maxIterations,
    double bailout = 2.0,
  }) {
    final samples = <ReferenceOrbitSample>[];
    final bailoutSquared = bailout * bailout;
    var real = 0.0;
    var imaginary = 0.0;
    int? escapeIteration;

    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final nextReal = real * real - imaginary * imaginary + cReal;
      final nextImaginary = 2.0 * real * imaginary + cImaginary;
      real = nextReal;
      imaginary = nextImaginary;
      final magnitudeSquared = real * real + imaginary * imaginary;

      samples.add(
        ReferenceOrbitSample(
          iteration: iteration,
          real: real,
          imaginary: imaginary,
          magnitudeSquared: magnitudeSquared,
        ),
      );

      if (magnitudeSquared > bailoutSquared) {
        escapeIteration = iteration;
        break;
      }
    }

    return MandelbrotReferenceOrbit(
      cReal: cReal,
      cImaginary: cImaginary,
      maxIterations: maxIterations,
      bailout: bailout,
      samples: List.unmodifiable(samples),
      escapeIteration: escapeIteration,
    );
  }
}

final class MandelbrotFixedPointReferenceOrbit {
  const MandelbrotFixedPointReferenceOrbit({
    required this.cReal,
    required this.cImaginary,
    required this.maxIterations,
    required this.bailout,
    required this.fractionalBits,
    required this.scale,
    required this.samples,
    required this.escapeIteration,
  });

  final BigInt cReal;
  final BigInt cImaginary;
  final int maxIterations;
  final BigInt bailout;
  final int fractionalBits;
  final BigInt scale;
  final List<FixedPointReferenceOrbitSample> samples;
  final int? escapeIteration;

  bool get escaped => escapeIteration != null;

  static MandelbrotFixedPointReferenceOrbit generate({
    required double cReal,
    required double cImaginary,
    required int maxIterations,
    double bailout = 2.0,
    int fractionalBits = 40,
  }) {
    final scale = BigInt.one << fractionalBits;
    return _generateFromFixed(
      cReal: _fromDouble(cReal, scale),
      cImaginary: _fromDouble(cImaginary, scale),
      maxIterations: maxIterations,
      bailout: _fromDouble(bailout, scale),
      fractionalBits: fractionalBits,
      scale: scale,
    );
  }

  static MandelbrotFixedPointReferenceOrbit generateFromDecimalStrings({
    required String cReal,
    required String cImaginary,
    required int maxIterations,
    String bailout = '2.0',
    int fractionalBits = 40,
  }) {
    final scale = BigInt.one << fractionalBits;
    return _generateFromFixed(
      cReal: _fromDecimalString(cReal, scale),
      cImaginary: _fromDecimalString(cImaginary, scale),
      maxIterations: maxIterations,
      bailout: _fromDecimalString(bailout, scale),
      fractionalBits: fractionalBits,
      scale: scale,
    );
  }

  static MandelbrotFixedPointReferenceOrbit _generateFromFixed({
    required BigInt cReal,
    required BigInt cImaginary,
    required int maxIterations,
    required BigInt bailout,
    required int fractionalBits,
    required BigInt scale,
  }) {
    final bailoutSquared = _multiply(bailout, bailout, scale);
    final samples = <FixedPointReferenceOrbitSample>[];
    var real = BigInt.zero;
    var imaginary = BigInt.zero;
    int? escapeIteration;

    for (var iteration = 1; iteration <= maxIterations; iteration++) {
      final nextReal = _multiply(real, real, scale) -
          _multiply(imaginary, imaginary, scale) +
          cReal;
      final nextImaginary =
          BigInt.two * _multiply(real, imaginary, scale) + cImaginary;
      real = nextReal;
      imaginary = nextImaginary;
      final magnitudeSquared =
          _multiply(real, real, scale) + _multiply(imaginary, imaginary, scale);

      samples.add(
        FixedPointReferenceOrbitSample(
          iteration: iteration,
          real: real,
          imaginary: imaginary,
          magnitudeSquared: magnitudeSquared,
          scale: scale,
        ),
      );

      if (magnitudeSquared > bailoutSquared) {
        escapeIteration = iteration;
        break;
      }
    }

    return MandelbrotFixedPointReferenceOrbit(
      cReal: cReal,
      cImaginary: cImaginary,
      maxIterations: maxIterations,
      bailout: bailout,
      fractionalBits: fractionalBits,
      scale: scale,
      samples: List.unmodifiable(samples),
      escapeIteration: escapeIteration,
    );
  }

  static BigInt _fromDouble(double value, BigInt scale) {
    return BigInt.from((value * scale.toDouble()).round());
  }

  static BigInt _fromDecimalString(String value, BigInt scale) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Decimal string must not be empty');
    }

    var sign = BigInt.one;
    var body = trimmed;
    if (body.startsWith('-')) {
      sign = -BigInt.one;
      body = body.substring(1);
    } else if (body.startsWith('+')) {
      body = body.substring(1);
    }

    final parts = body.split('.');
    if (parts.length > 2) {
      throw FormatException('Invalid decimal string: $value');
    }

    final whole = parts[0].isEmpty ? '0' : parts[0];
    final fraction = parts.length == 2 ? parts[1] : '';
    final digits = '$whole$fraction';
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) {
      throw FormatException('Invalid decimal string: $value');
    }

    final numerator = BigInt.parse(digits);
    final denominator = BigInt.from(10).pow(fraction.length);
    final rounded =
        (numerator * scale + denominator ~/ BigInt.two) ~/ denominator;
    return sign * rounded;
  }

  static BigInt _multiply(BigInt left, BigInt right, BigInt scale) {
    return (left * right) ~/ scale;
  }
}

final class FixedPointReferenceOrbitSample {
  const FixedPointReferenceOrbitSample({
    required this.iteration,
    required this.real,
    required this.imaginary,
    required this.magnitudeSquared,
    required this.scale,
  });

  final int iteration;
  final BigInt real;
  final BigInt imaginary;
  final BigInt magnitudeSquared;
  final BigInt scale;

  double get realAsDouble => real.toDouble() / scale.toDouble();
  double get imaginaryAsDouble => imaginary.toDouble() / scale.toDouble();
  double get magnitudeSquaredAsDouble =>
      magnitudeSquared.toDouble() / scale.toDouble();
}

enum ReferenceOrbitRefineReason {
  accepted,
  missingReferenceSample,
  referenceCancellation,
}

final class ReferenceOrbitRefineDecision {
  const ReferenceOrbitRefineDecision({
    required this.iteration,
    required this.reason,
    required this.referenceMagnitudeSquared,
    required this.reconstructedMagnitudeSquared,
  });

  final int iteration;
  final ReferenceOrbitRefineReason reason;
  final double referenceMagnitudeSquared;
  final double reconstructedMagnitudeSquared;

  bool get needsRefine => reason != ReferenceOrbitRefineReason.accepted;
}

final class ReferenceOrbitSample {
  const ReferenceOrbitSample({
    required this.iteration,
    required this.real,
    required this.imaginary,
    required this.magnitudeSquared,
  });

  final int iteration;
  final double real;
  final double imaginary;
  final double magnitudeSquared;
}
