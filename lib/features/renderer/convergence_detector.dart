import 'dart:typed_data';
import 'dart:math' as math;

/// Result of convergence detection analysis.
class ConvergenceResult {
  /// Whether the image has converged (stabilized).
  final bool converged;

  /// The ratio of pixels that changed between frames (0.0 to 1.0).
  final double changeRatio;

  /// Suggested number of iterations for the next render.
  final int suggestedIterations;

  const ConvergenceResult({
    required this.converged,
    required this.changeRatio,
    required this.suggestedIterations,
  });

  @override
  String toString() {
    return 'ConvergenceResult(converged: $converged, '
        'changeRatio: ${changeRatio.toStringAsFixed(6)}, '
        'suggestedIterations: $suggestedIterations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConvergenceResult &&
        other.converged == converged &&
        (other.changeRatio - changeRatio).abs() < 1e-9 &&
        other.suggestedIterations == suggestedIterations;
  }

  @override
  int get hashCode =>
      converged.hashCode ^ changeRatio.hashCode ^ suggestedIterations.hashCode;
}

/// Detects convergence between two rendered frames to enable adaptive iteration refinement.
///
/// Compares two RGBA frame buffers and determines if the rendering has stabilized.
/// Uses downsampling to ~64x64 resolution for performance.
class ConvergenceDetector {
  /// Threshold for considering a pixel as "changed" (per channel, 0-255).
  final int pixelDifferenceThreshold;

  /// Target downsample resolution for comparison (approximate).
  final int downsampleTarget;

  /// Convergence threshold: below this ratio, the image is considered converged.
  static const double convergenceThreshold = 0.001;

  /// Change threshold: above this ratio, suggest increasing iterations.
  static const double changeThreshold = 0.01;

  /// Multiplier for suggested iterations when image hasn't converged.
  static const double iterationMultiplier = 1.5;

  const ConvergenceDetector({
    this.pixelDifferenceThreshold = 5,
    this.downsampleTarget = 64,
  });

  /// Compares two RGBA frame buffers and returns convergence analysis.
  ///
  /// [previous] and [current] must be RGBA Uint8List buffers of identical dimensions.
  /// [width] and [height] are the original buffer dimensions in pixels.
  /// [currentIterations] is the iteration count used to render [current].
  ///
  /// Returns a [ConvergenceResult] indicating whether the image has converged,
  /// the change ratio, and suggested iterations for the next render.
  ConvergenceResult detect({
    required Uint8List previous,
    required Uint8List current,
    required int width,
    required int height,
    required int currentIterations,
  }) {
    // Validate inputs
    if (previous.length != current.length) {
      throw ArgumentError(
        'Buffer size mismatch: previous=${previous.length}, current=${current.length}',
      );
    }

    final expectedLength = width * height * 4; // RGBA
    if (previous.length != expectedLength) {
      throw ArgumentError(
        'Buffer size mismatch: expected=$expectedLength (${width}x$height RGBA), '
        'got=${previous.length}',
      );
    }

    if (width <= 0 || height <= 0) {
      throw ArgumentError('Invalid dimensions: ${width}x$height');
    }

    if (currentIterations <= 0) {
      throw ArgumentError('Invalid currentIterations: $currentIterations');
    }

    // Calculate downsample factor
    final downsampleFactor = _calculateDownsampleFactor(width, height);
    final downsampledWidth = (width / downsampleFactor).ceil();
    final downsampledHeight = (height / downsampleFactor).ceil();

    // Compare downsampled images
    int changedPixels = 0;
    int totalPixels = 0;

    for (int y = 0; y < downsampledHeight; y++) {
      for (int x = 0; x < downsampledWidth; x++) {
        // Sample from the original buffers
        final srcX = (x * downsampleFactor).clamp(0, width - 1);
        final srcY = (y * downsampleFactor).clamp(0, height - 1);
        final pixelIndex = (srcY * width + srcX) * 4;

        // Compare RGB channels (ignore alpha)
        bool pixelChanged = false;
        for (int channel = 0; channel < 3; channel++) {
          final diff = (previous[pixelIndex + channel] - current[pixelIndex + channel]).abs();
          if (diff > pixelDifferenceThreshold) {
            pixelChanged = true;
            break;
          }
        }

        if (pixelChanged) {
          changedPixels++;
        }
        totalPixels++;
      }
    }

    // Calculate change ratio
    final changeRatio = totalPixels > 0 ? changedPixels / totalPixels : 0.0;

    // Determine convergence and suggested iterations
    final bool converged = changeRatio < convergenceThreshold;
    final int suggestedIterations;

    if (changeRatio > changeThreshold) {
      // Significant changes detected, increase iterations
      suggestedIterations = (currentIterations * iterationMultiplier).round();
    } else {
      // Minor or no changes, keep current iterations
      suggestedIterations = currentIterations;
    }

    return ConvergenceResult(
      converged: converged,
      changeRatio: changeRatio,
      suggestedIterations: suggestedIterations,
    );
  }

  /// Calculates the downsample factor to achieve approximately [downsampleTarget]x[downsampleTarget] resolution.
  int _calculateDownsampleFactor(int width, int height) {
    final maxDimension = math.max(width, height);
    final factor = (maxDimension / downsampleTarget).ceil();
    return math.max(1, factor);
  }
}
