import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:vector_math/vector_math.dart';

/// Read-only snapshot of controller parameters for public exposure.
///
/// [FractalController] owns parameter validation and listener notification.
/// Returning the backing map lets callers mutate controller state without
/// normalization or notifications, so public reads get a defensive top-level
/// copy instead.
Map<String, Object> snapshotFractalControllerParams(
  Map<String, Object> params,
) {
  return Map<String, Object>.unmodifiable(params);
}

/// Defensive copy of controller view state for public exposure.
///
/// [FractalViewState] is immutable by field assignment, but its vector fields
/// are mutable. Clone vectors at the controller boundary so external reads
/// cannot mutate pan/rotation without going through controller update methods.
FractalViewState snapshotFractalControllerView(FractalViewState view) {
  return FractalViewState(
    pan: Vector2.copy(view.pan),
    zoom: view.zoom,
    rotation: Vector3.copy(view.rotation),
  );
}
