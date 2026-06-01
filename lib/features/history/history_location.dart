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

/// Creates a deep JSON-like snapshot of parameters at the record boundary.
Map<String, Object> snapshotHistoryParams(Map<String, Object> params) {
  return {
    for (final entry in params.entries)
      entry.key: snapshotHistoryParamValue(entry.value),
  };
}

/// Deep-copies JSON-like parameter values so history replay is not affected by
/// later mutations of nested list/map values owned by controllers or widgets.
///
/// Nested map keys are normalized to strings because history entries are
/// persisted as JSON objects. Without this, a controller-owned metadata map
/// with enum/int keys can make the whole history save fail during jsonEncode.
Object snapshotHistoryParamValue(Object value) {
  if (value is List) {
    return [
      for (final item in value)
        item is Object ? snapshotHistoryParamValue(item) : item,
    ];
  }

  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): entry.value is Object
            ? snapshotHistoryParamValue(entry.value as Object)
            : entry.value,
    };
  }

  return value;
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
    if (!areSameHistoryParamValue(entry.value, otherParams[entry.key])) {
      return false;
    }
  }

  return true;
}

/// Compares JSON-like history parameter values by value rather than identity.
///
/// Persisted params can contain nested lists/maps after JSON decode. Dart's
/// collection equality is identity-based, which would make two replayed
/// locations look different even when their serialized parameter values match.
bool areSameHistoryParamValue(Object? value, Object? otherValue) {
  if (identical(value, otherValue)) return true;

  if (value is List && otherValue is List) {
    if (value.length != otherValue.length) return false;
    for (var i = 0; i < value.length; i++) {
      if (!areSameHistoryParamValue(
          value[i] as Object?, otherValue[i] as Object?)) {
        return false;
      }
    }
    return true;
  }

  if (value is Map && otherValue is Map) {
    if (value.length != otherValue.length) return false;
    for (final entry in value.entries) {
      if (!otherValue.containsKey(entry.key)) return false;
      if (!areSameHistoryParamValue(
        entry.value as Object?,
        otherValue[entry.key] as Object?,
      )) {
        return false;
      }
    }
    return true;
  }

  return value == otherValue;
}
