import 'dart:math' as math;
import 'dart:typed_data';

import '../models/fourier_grid.dart';
import '../services/fourier_transform_service.dart';
import 'discrete_cantor_mask.dart';

/// The finite operator `P_Y F P_X` for the unitary two-dimensional DFT.
final class RestrictedFourierOperator {
  RestrictedFourierOperator(
    this.spatialMask,
    this.spectralMask, {
    FourierTransformService? transformService,
  }) : _transformService = transformService ?? FourierTransformService() {
    if (spatialMask.sideLength != spectralMask.sideLength) {
      throw ArgumentError(
          'Spatial and spectral masks must have equal dimensions.');
    }
  }

  final DiscreteCantorMask spatialMask;
  final DiscreteCantorMask spectralMask;
  final FourierTransformService _transformService;

  int get sideLength => spatialMask.sideLength;
  int get vectorLength => sideLength * sideLength;

  Float64List apply(Float64List input) {
    _validateVector(input);
    final projected = _project(input, spatialMask);
    final transformed = _transformService.forward(
      FourierGrid.complex(
        width: sideLength,
        height: sideLength,
        values: projected,
      ),
    );
    return _project(transformed.toPackedFloat64List(), spectralMask);
  }

  Float64List applyAdjoint(Float64List input) {
    _validateVector(input);
    final projected = _project(input, spectralMask);
    final transformed = _transformService.inverse(
      FourierGrid.complex(
        width: sideLength,
        height: sideLength,
        values: projected,
      ),
    );
    return _project(transformed.toPackedFloat64List(), spatialMask);
  }

  Float64List applyNormal(Float64List input) => applyAdjoint(apply(input));

  void _validateVector(Float64List input) {
    if (input.length != vectorLength * 2) {
      throw ArgumentError.value(
        input.length,
        'input',
        'Expected ${vectorLength * 2} packed complex values.',
      );
    }
    for (final value in input) {
      if (!value.isFinite) {
        throw ArgumentError.value(value, 'input', 'Values must be finite.');
      }
    }
  }
}

/// Honest diagnostics for one finite power-iteration experiment.
final class FractalUncertaintyEstimate {
  const FractalUncertaintyEstimate({
    required this.base,
    required this.recursion,
    required this.sideLength,
    required this.spatialCardinality,
    required this.spectralCardinality,
    required this.iterations,
    required this.residual,
    required this.converged,
    required this.sigma,
    required this.hilbertSchmidtBound,
  });

  final int base;
  final int recursion;
  final int sideLength;
  final int spatialCardinality;
  final int spectralCardinality;
  final int iterations;
  final double residual;
  final bool converged;
  final double sigma;
  final double hilbertSchmidtBound;

  double get retainedEnergy => sigma * sigma;
  double get leakage => 1 - retainedEnergy;
  double get empiricalBeta => -math.log(sigma) / (recursion * math.log(base));
}

final class FractalUncertaintyEstimationCancelled implements Exception {
  const FractalUncertaintyEstimationCancelled();

  @override
  String toString() => 'Fractal uncertainty estimation cancelled.';
}

/// Deterministic multi-start largest-singular-value estimator.
final class FractalUncertaintyEstimator {
  FractalUncertaintyEstimator({
    this.maximumIterations = 200,
    this.tolerance = 1e-11,
    this.startCount = 4,
  }) {
    if (maximumIterations < 1 || tolerance <= 0 || startCount < 1) {
      throw ArgumentError('Iteration settings must be positive.');
    }
  }

  final int maximumIterations;
  final double tolerance;
  final int startCount;

  FractalUncertaintyEstimate estimate(
    DiscreteCantorMask spatialMask,
    DiscreteCantorMask spectralMask, {
    bool Function()? isCancelled,
  }) {
    if (spatialMask.sideLength != spectralMask.sideLength ||
        spatialMask.recursion != spectralMask.recursion ||
        spatialMask.alphabet.base != spectralMask.alphabet.base) {
      throw ArgumentError(
          'Masks must use the same base, recursion, and grid size.');
    }
    _throwIfCancelled(isCancelled);
    final operator = RestrictedFourierOperator(spatialMask, spectralMask);
    _IterationResult? best;

    for (var start = 0; start < startCount; start++) {
      var vector = _initialVector(spatialMask, start);
      var iteration = 0;
      var residual = double.infinity;
      var eigenvalue = 0.0;
      for (; iteration < maximumIterations; iteration++) {
        _throwIfCancelled(isCancelled);
        final normal = operator.applyNormal(vector);
        final norm = _norm(normal);
        if (norm == 0) {
          eigenvalue = 0;
          residual = 0;
          break;
        }
        _scaleInPlace(normal, 1 / norm);
        vector = normal;
        final image = operator.applyNormal(vector);
        eigenvalue = _innerReal(vector, image).clamp(0.0, 1.0).toDouble();
        residual = _residualNorm(image, vector, eigenvalue);
        if (residual <= tolerance) {
          iteration++;
          break;
        }
      }
      final candidate = _IterationResult(
        eigenvalue: eigenvalue,
        iterations: iteration,
        residual: residual,
      );
      if (best == null || candidate.eigenvalue > best.eigenvalue)
        best = candidate;
    }

    final selected = best!;
    final sigma = math.sqrt(selected.eigenvalue).clamp(0.0, 1.0).toDouble();
    final n = spatialMask.sideLength.toDouble();
    final hsBound = math.min(
      1.0,
      math.sqrt(
        spatialMask.cardinality * spectralMask.cardinality / (n * n),
      ),
    );
    return FractalUncertaintyEstimate(
      base: spatialMask.alphabet.base,
      recursion: spatialMask.recursion,
      sideLength: spatialMask.sideLength,
      spatialCardinality: spatialMask.cardinality,
      spectralCardinality: spectralMask.cardinality,
      iterations: selected.iterations,
      residual: selected.residual,
      converged: selected.residual <= tolerance,
      sigma: sigma,
      hilbertSchmidtBound: hsBound,
    );
  }
}

/// Least-squares fit of `log(sigma_k)` against `k log(M)`.
final class FiniteDecayFit {
  const FiniteDecayFit({
    required this.beta,
    required this.rSquared,
    required this.sampleCount,
  });

  factory FiniteDecayFit.fromResults(
    List<FractalUncertaintyEstimate> results,
  ) {
    if (results.length < 2) {
      throw ArgumentError.value(
          results.length, 'results', 'Need at least two estimates.');
    }
    final base = results.first.base;
    if (results.any((result) => result.base != base || result.sigma <= 0)) {
      throw ArgumentError('Results must share a base and have positive sigma.');
    }
    final xs = [
      for (final result in results) result.recursion * math.log(base)
    ];
    final ys = [for (final result in results) math.log(result.sigma)];
    final meanX = xs.reduce((a, b) => a + b) / xs.length;
    final meanY = ys.reduce((a, b) => a + b) / ys.length;
    var covariance = 0.0;
    var varianceX = 0.0;
    for (var index = 0; index < xs.length; index++) {
      covariance += (xs[index] - meanX) * (ys[index] - meanY);
      varianceX += math.pow(xs[index] - meanX, 2);
    }
    if (varianceX == 0) {
      throw ArgumentError('Results must contain distinct recursion levels.');
    }
    final slope = covariance / varianceX;
    final intercept = meanY - slope * meanX;
    var residualSquares = 0.0;
    var totalSquares = 0.0;
    for (var index = 0; index < xs.length; index++) {
      residualSquares +=
          math.pow(ys[index] - (intercept + slope * xs[index]), 2);
      totalSquares += math.pow(ys[index] - meanY, 2);
    }
    final rSquared =
        totalSquares == 0 ? 1.0 : 1 - residualSquares / totalSquares;
    return FiniteDecayFit(
      beta: -slope,
      rSquared: rSquared.clamp(0.0, 1.0).toDouble(),
      sampleCount: results.length,
    );
  }

  String get label => 'finite empirical estimate';
  final double beta;
  final double rSquared;
  final int sampleCount;
}

final class _IterationResult {
  const _IterationResult({
    required this.eigenvalue,
    required this.iterations,
    required this.residual,
  });

  final double eigenvalue;
  final int iterations;
  final double residual;
}

Float64List _project(Float64List input, DiscreteCantorMask mask) {
  final result = Float64List(input.length);
  for (final cell in mask.activeCoordinates) {
    final index = (cell.y * mask.sideLength + cell.x) * 2;
    result[index] = input[index];
    result[index + 1] = input[index + 1];
  }
  return result;
}

Float64List _initialVector(DiscreteCantorMask mask, int start) {
  final result = Float64List(mask.sideLength * mask.sideLength * 2);
  for (var activeIndex = 0;
      activeIndex < mask.activeCoordinates.length;
      activeIndex++) {
    final cell = mask.activeCoordinates[activeIndex];
    final index = (cell.y * mask.sideLength + cell.x) * 2;
    final angle = (activeIndex + 1) * (start + 1) * 0.6180339887498949;
    result[index] = math.cos(angle);
    result[index + 1] = math.sin(angle);
  }
  _scaleInPlace(result, 1 / _norm(result));
  return result;
}

void _throwIfCancelled(bool Function()? isCancelled) {
  if (isCancelled?.call() ?? false) {
    throw const FractalUncertaintyEstimationCancelled();
  }
}

double _norm(Float64List vector) {
  var squared = 0.0;
  for (var index = 0; index < vector.length; index += 2) {
    squared +=
        vector[index] * vector[index] + vector[index + 1] * vector[index + 1];
  }
  return math.sqrt(squared);
}

void _scaleInPlace(Float64List vector, double scale) {
  for (var index = 0; index < vector.length; index++) {
    vector[index] *= scale;
  }
}

double _innerReal(Float64List left, Float64List right) {
  var result = 0.0;
  for (var index = 0; index < left.length; index += 2) {
    result += left[index] * right[index] + left[index + 1] * right[index + 1];
  }
  return result;
}

double _residualNorm(
  Float64List image,
  Float64List vector,
  double eigenvalue,
) {
  var squared = 0.0;
  for (var index = 0; index < image.length; index++) {
    final difference = image[index] - eigenvalue * vector[index];
    squared += difference * difference;
  }
  return math.sqrt(squared);
}
