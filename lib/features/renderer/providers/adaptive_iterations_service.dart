import 'dart:math';

import 'package:flutter_fractals/core/models/fractal_parameter.dart';

/// Callback type for logging changes.
typedef LogChangeCallback = void Function(
  String type,
  String category,
  String message, {
  Map<String, dynamic>? metadata,
});

/// Handles zoom-based adaptive iteration adjustment.
///
/// Responsibilities:
/// - Calculate optimal iteration count based on zoom level
/// - Suggest stepped iteration increases for performance
/// - Clamp iterations to valid parameter ranges
///
/// Extracted from FractalController to follow Single Responsibility Principle.
class AdaptiveIterationsService {
  static const bool _adaptiveIterationsEnabled = bool.fromEnvironment(
    'ADAPTIVE_ITERATIONS',
    defaultValue: true,
  );
  static const int _adaptiveIterationsMinStep = 8;

  /// Calculates the target iteration count for a given zoom level.
  ///
  /// Uses logarithmic scaling: each doubling of zoom adds ~48 iterations.
  int suggestIterationsForZoom({
    required double zoom,
    required int baseIterations,
    required int minIterations,
    required int maxIterations,
  }) {
    final safeZoom = max(1.0, zoom);
    final zoomOctaves = log(safeZoom) / ln2;
    final extra = max(0, (zoomOctaves * 48.0).round());
    final raw = baseIterations + extra;
    // Snap to a small step to avoid jittery one-by-one jumps.
    final snapped = ((raw + 3) ~/ 4) * 4;
    return snapped.clamp(minIterations, maxIterations);
  }

  /// Applies adaptive iteration adjustment if conditions are met.
  ///
  /// Returns the new iteration value if adjusted, null otherwise.
  /// Updates params via [updateParams] callback when returning a value.
  int? applyAdaptiveIterationsForZoom({
    required double zoom,
    required bool zoomingIn,
    required bool is2D,
    required FractalParameter? iterationsSchema,
    required Map<String, Object> params,
    required void Function(Map<String, Object>) updateParams,
    required LogChangeCallback logChange,
    required String moduleId,
  }) {
    if (!_adaptiveIterationsEnabled || !zoomingIn) {
      return null;
    }
    if (!is2D) {
      return null;
    }

    if (iterationsSchema == null ||
        iterationsSchema.type != FractalParamType.integer) {
      return null;
    }

    final minIterations = iterationsSchema.min.round();
    final maxIterations = iterationsSchema.max.round();
    final currentValue = params['iterations'];
    final currentIterations = currentValue is num
        ? currentValue.round()
        : (iterationsSchema.defaultValue as num).round();
    final baseIterations = (iterationsSchema.defaultValue as num).round();

    final targetIterations = suggestIterationsForZoom(
      zoom: zoom,
      baseIterations: baseIterations,
      minIterations: minIterations,
      maxIterations: maxIterations,
    );
    if (targetIterations <= currentIterations) {
      return null;
    }

    final delta = targetIterations - currentIterations;
    final step = delta >= 256
        ? 64
        : delta >= 96
            ? 32
            : delta >= 32
                ? 16
                : _adaptiveIterationsMinStep;
    final nextIterations =
        (currentIterations + step).clamp(minIterations, maxIterations);
    if (nextIterations <= currentIterations) {
      return null;
    }

    final updatedParams = Map<String, Object>.from(params);
    updatedParams['iterations'] = nextIterations;
    updateParams(updatedParams);

    logChange(
      'stateChange',
      'adaptiveIterations',
      'Adaptive iterations increased',
      metadata: <String, dynamic>{
        'module': moduleId,
        'zoom': zoom,
        'from': currentIterations,
        'to': nextIterations,
        'target': targetIterations,
      },
    );
    return nextIterations;
  }
}
