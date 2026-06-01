import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';

/// Creates an immutable-by-convention history snapshot of a mutable view state.
///
/// [FractalViewState] stores mutable vector_math objects, so history must clone
/// those vectors at the record boundary to keep debounced writes replayable.
FractalViewState snapshotHistoryView(FractalViewState view) {
  return FractalViewState(
    pan: Vector2.copy(view.pan),
    zoom: view.zoom,
    rotation: Vector3.copy(view.rotation),
  );
}

/// Creates a shallow snapshot of the parameter map at the record boundary.
Map<String, Object> snapshotHistoryParams(Map<String, Object> params) {
  return Map<String, Object>.from(params);
}

/// Pure location-equivalence contract for history de-duplication.
///
/// A history location is the restorable fractal state: module, view, and
/// parameters. Metadata such as entry id, favorite name, and timestamp is not
/// part of location identity.
bool isSameHistoryLocation({
  required String moduleId,
  required FractalViewState view,
  required Map<String, Object> params,
  required String otherModuleId,
  required FractalViewState otherView,
  required Map<String, Object> otherParams,
}) {
  if (moduleId != otherModuleId) {
    return false;
  }
  if (view.zoom != otherView.zoom) {
    return false;
  }
  if (view.pan.x != otherView.pan.x || view.pan.y != otherView.pan.y) {
    return false;
  }
  if (view.rotation.x != otherView.rotation.x ||
      view.rotation.y != otherView.rotation.y ||
      view.rotation.z != otherView.rotation.z) {
    return false;
  }
  return haveSameHistoryParams(params, otherParams);
}

/// Compares history parameter snapshots without relying on map iteration order.
bool haveSameHistoryParams(
  Map<String, Object> params,
  Map<String, Object> otherParams,
) {
  if (params.length != otherParams.length) {
    return false;
  }

  for (final entry in params.entries) {
    if (!otherParams.containsKey(entry.key)) {
      return false;
    }
    if (otherParams[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}
