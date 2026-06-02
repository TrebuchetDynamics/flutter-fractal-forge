import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'fractal_view_state.dart';

FractalViewState _snapshotPresetView(FractalViewState view) {
  return FractalViewState(
    pan: view.pan,
    zoom: view.zoom,
    rotation: view.rotation,
  );
}

Map<String, Object> _snapshotPresetParams(Map<String, Object> params) {
  return Map<String, Object>.unmodifiable({
    for (final entry in params.entries)
      entry.key: _snapshotPresetParamValue(entry.value),
  });
}

Map<String, Object> _decodePresetParams(Map params) {
  final decoded = <String, Object>{};
  for (final entry in params.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key == null || value == null) continue;
    decoded[key.toString()] = _snapshotPresetParamValue(value as Object);
  }
  return Map<String, Object>.unmodifiable(decoded);
}

Object _snapshotPresetParamValue(Object value) {
  if (value is List) {
    return List<Object?>.unmodifiable([
      for (final item in value)
        item is Object ? _snapshotPresetParamValue(item) : item,
    ]);
  }

  if (value is Map) {
    return Map<String, Object?>.unmodifiable({
      for (final entry in value.entries)
        entry.key.toString(): entry.value is Object
            ? _snapshotPresetParamValue(entry.value as Object)
            : entry.value,
    });
  }

  return value;
}

/// A saved configuration of fractal parameters and view state.
///
/// Presets allow users to save and restore specific fractal configurations,
/// including both the mathematical parameters (iterations, bailout, etc.)
/// and the view state (pan, zoom, rotation).
///
/// Presets can be:
/// - **Built-in**: Included with the app and read-only
/// - **User-created**: Saved by the user with custom thumbnails
///
/// Presets are serializable to JSON for persistent storage.
///
/// {@category Models}
///
/// Example:
/// ```dart
/// final preset = FractalPreset(
///   id: 'my-preset',
///   moduleId: 'mandelbrot',
///   name: 'Deep Zoom',
///   params: {'iterations': 200, 'colorScheme': 2},
///   view: FractalViewState(
///     pan: Vector2(-0.75, 0.1),
///     zoom: 50.0,
///     rotation: Vector3.zero(),
///   ),
///   createdAt: DateTime.now(),
/// );
/// ```
@immutable
class FractalPreset {
  /// Unique identifier for this preset.
  ///
  /// For built-in presets, use a pattern like 'module-name'.
  /// For user presets, typically a UUID.
  final String id;

  /// The fractal module this preset belongs to.
  ///
  /// Must match a [FractalModule.id] in the registry.
  /// Presets are only applicable to their target module.
  final String moduleId;

  /// User-visible name for this preset.
  ///
  /// Should be descriptive and unique within the module's presets.
  final String name;

  /// The fractal parameter values.
  ///
  /// Keys are parameter IDs (e.g., 'iterations', 'colorScheme').
  /// Values are typed according to [FractalParamType].
  final Map<String, Object> params;

  /// The view state (pan, zoom, rotation) for this preset.
  ///
  /// Defines the camera position and orientation when
  /// the preset is applied.
  final FractalViewState view;

  /// When this preset was created.
  ///
  /// Used for sorting and display purposes.
  final DateTime createdAt;

  /// Whether this is a built-in (read-only) preset.
  ///
  /// Built-in presets cannot be edited or deleted by the user.
  final bool isBuiltIn;

  /// Path to the preset's thumbnail image.
  ///
  /// For user presets, this is typically a file path to a
  /// captured PNG. Built-in presets may use asset paths.
  final String? thumbnailPath;

  /// Creates a new [FractalPreset] with the specified configuration.
  ///
  /// The supplied view vectors and parameter collections are snapshotted so a
  /// preset remains replayable even when callers mutate their originals.
  FractalPreset({
    required this.id,
    required this.moduleId,
    required this.name,
    required Map<String, Object> params,
    required FractalViewState view,
    required this.createdAt,
    this.isBuiltIn = false,
    this.thumbnailPath,
  })  : params = _snapshotPresetParams(params),
        view = _snapshotPresetView(view);

  /// Creates a copy of this preset with the given fields replaced.
  ///
  /// Useful for creating variations of existing presets. Because `null` means
  /// "keep the existing value" for optional fields, set [clearThumbnailPath]
  /// when a copy must remove an existing thumbnail.
  FractalPreset copyWith({
    String? id,
    String? moduleId,
    String? name,
    Map<String, Object>? params,
    FractalViewState? view,
    DateTime? createdAt,
    bool? isBuiltIn,
    String? thumbnailPath,
    bool clearThumbnailPath = false,
  }) {
    assert(
      !clearThumbnailPath || thumbnailPath == null,
      'thumbnailPath cannot be provided when clearThumbnailPath is true',
    );
    return FractalPreset(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      params: params ?? this.params,
      view: view ?? this.view,
      createdAt: createdAt ?? this.createdAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      thumbnailPath:
          clearThumbnailPath ? null : thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Serializes this preset to a JSON-compatible map.
  ///
  /// Used for persistent storage in SharedPreferences.
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'name': name,
      'params': params,
      'view': {
        'panX': view.pan.x,
        'panY': view.pan.y,
        'zoom': view.zoom,
        'rotX': view.rotation.x,
        'rotY': view.rotation.y,
        'rotZ': view.rotation.z,
      },
      'createdAt': createdAt.toIso8601String(),
      'isBuiltIn': isBuiltIn,
      'thumbnailPath': thumbnailPath,
    };
  }

  /// Deserializes a preset from a JSON map.
  ///
  /// Throws if required fields are missing.
  static FractalPreset fromJson(Map<String, Object?> json) {
    final view = json['view'] as Map<String, Object?>? ?? {};
    return FractalPreset(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      name: json['name'] as String,
      params: _decodePresetParams(json['params'] as Map),
      view: FractalViewState(
        pan: Vector2(
          (view['panX'] as num? ?? 0).toDouble(),
          (view['panY'] as num? ?? 0).toDouble(),
        ),
        zoom: (view['zoom'] as num? ?? 1).toDouble(),
        rotation: Vector3(
          (view['rotX'] as num? ?? 0).toDouble(),
          (view['rotY'] as num? ?? 0).toDouble(),
          (view['rotZ'] as num? ?? 0).toDouble(),
        ),
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  /// Parses a list of presets from a JSON string.
  ///
  /// Returns an empty list if [payload] is null or empty.
  /// Skips corrupted entries and continues parsing valid ones.
  /// Used for reading from SharedPreferences.
  static List<FractalPreset> listFromPrefs(String? payload) {
    if (payload == null || payload.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(payload) as List;
      final presets = <FractalPreset>[];
      for (final item in decoded) {
        try {
          final preset =
              FractalPreset.fromJson((item as Map).cast<String, Object?>());
          presets.add(preset);
        } catch (e) {
          // Skip corrupted preset, continue with others
          if (kDebugMode) debugPrint('Failed to parse preset: $e');
        }
      }
      return presets;
    } catch (e) {
      // Corrupted JSON, return empty list
      if (kDebugMode) debugPrint('Failed to parse presets JSON: $e');
      return [];
    }
  }

  /// Serializes a list of presets to a JSON string.
  ///
  /// Used for writing to SharedPreferences.
  static String listToPrefs(List<FractalPreset> presets) {
    return jsonEncode(presets.map((preset) => preset.toJson()).toList());
  }
}
