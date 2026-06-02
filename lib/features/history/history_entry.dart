import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/features/history/history_location.dart';

/// Represents a visited location in fractal exploration history.
///
/// Each entry captures the complete state needed to restore a viewpoint:
/// - The fractal module (type) being viewed
/// - The view state (pan, zoom, rotation)
/// - The fractal parameters at that time
/// - Optional metadata like name (for favorites) and timestamp
///
/// {@category Models}
@immutable
class HistoryEntry {
  /// Unique identifier for this history entry.
  final String id;

  /// The fractal module ID (e.g., 'mandelbrot', 'julia').
  final String moduleId;

  /// The view state (pan, zoom, rotation) at this location.
  final FractalViewState view;

  /// The fractal parameters at this location.
  final Map<String, Object> params;

  /// When this location was visited.
  final DateTime visitedAt;

  /// Optional user-defined name for favorites.
  ///
  /// If non-null, this entry is considered a favorite.
  final String? name;

  /// Whether this entry is marked as a favorite.
  bool get isFavorite => name != null;

  /// Creates a new [HistoryEntry].
  ///
  /// The supplied view vectors and parameter collections are snapshotted so a
  /// history entry remains replayable even when callers mutate their originals.
  HistoryEntry({
    required this.id,
    required this.moduleId,
    required FractalViewState view,
    required Map<String, Object> params,
    required this.visitedAt,
    this.name,
  })  : view = snapshotHistoryView(view),
        params = snapshotHistoryParams(params);

  /// Creates a history entry from the current fractal state.
  factory HistoryEntry.fromState({
    required String moduleId,
    required FractalViewState view,
    required Map<String, Object> params,
    String? name,
  }) {
    return HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      moduleId: moduleId,
      view: view,
      params: params,
      visitedAt: DateTime.now(),
      name: name,
    );
  }

  /// Creates a copy with the given fields replaced.
  HistoryEntry copyWith({
    String? id,
    String? moduleId,
    FractalViewState? view,
    Map<String, Object>? params,
    DateTime? visitedAt,
    String? name,
    bool clearName = false,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      view: view ?? this.view,
      params: params ?? this.params,
      visitedAt: visitedAt ?? this.visitedAt,
      name: clearName ? null : (name ?? this.name),
    );
  }

  /// Serializes this entry to a JSON-compatible map.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'view': {
        'panX': view.pan.x,
        'panY': view.pan.y,
        'zoom': view.zoom,
        'rotX': view.rotation.x,
        'rotY': view.rotation.y,
        'rotZ': view.rotation.z,
      },
      'params': params,
      'visitedAt': visitedAt.toIso8601String(),
      'name': name,
    };
  }

  /// Deserializes a history entry from a JSON map.
  static HistoryEntry fromJson(Map<String, Object?> json) {
    final viewJson = json['view'] as Map<String, Object?>? ?? {};
    return HistoryEntry(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      view: FractalViewState(
        pan: Vector2(
          (viewJson['panX'] as num? ?? 0).toDouble(),
          (viewJson['panY'] as num? ?? 0).toDouble(),
        ),
        zoom: (viewJson['zoom'] as num? ?? 1).toDouble(),
        rotation: Vector3(
          (viewJson['rotX'] as num? ?? 0).toDouble(),
          (viewJson['rotY'] as num? ?? 0).toDouble(),
          (viewJson['rotZ'] as num? ?? 0).toDouble(),
        ),
      ),
      params: (json['params'] as Map?)?.map(
            (key, value) => MapEntry(key as String, value as Object),
          ) ??
          {},
      visitedAt: DateTime.tryParse(json['visitedAt'] as String? ?? '') ??
          DateTime.now(),
      name: json['name'] as String?,
    );
  }

  /// Generates a display label for this entry.
  ///
  /// If named, returns the name. Otherwise, returns a
  /// formatted description of the location.
  String get displayLabel {
    if (name != null) return name!;
    final zoomStr = view.zoom >= 10
        ? '${view.zoom.toStringAsFixed(0)}x'
        : '${view.zoom.toStringAsFixed(1)}x';
    return '$moduleId @ $zoomStr';
  }

  /// Checks if this entry represents the same location as another.
  ///
  /// Two entries are at the same location if they have the same
  /// module, view state, and parameters.
  bool isSameLocation(HistoryEntry other) {
    return isSameHistoryLocation(
      moduleId: moduleId,
      view: view,
      params: params,
      otherModuleId: other.moduleId,
      otherView: other.view,
      otherParams: other.params,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
