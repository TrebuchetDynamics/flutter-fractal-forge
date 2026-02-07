import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'fractal_view_state.dart';

@immutable
class FractalPreset {
  final String id;
  final String moduleId;
  final String name;
  final Map<String, Object> params;
  final FractalViewState view;
  final DateTime createdAt;
  final bool isBuiltIn;
  final String? thumbnailPath;

  const FractalPreset({
    required this.id,
    required this.moduleId,
    required this.name,
    required this.params,
    required this.view,
    required this.createdAt,
    this.isBuiltIn = false,
    this.thumbnailPath,
  });

  FractalPreset copyWith({
    String? id,
    String? moduleId,
    String? name,
    Map<String, Object>? params,
    FractalViewState? view,
    DateTime? createdAt,
    bool? isBuiltIn,
    String? thumbnailPath,
  }) {
    return FractalPreset(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      params: params ?? this.params,
      view: view ?? this.view,
      createdAt: createdAt ?? this.createdAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

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

  static FractalPreset fromJson(Map<String, Object?> json) {
    final view = json['view'] as Map<String, Object?>? ?? {};
    return FractalPreset(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      name: json['name'] as String,
      params: (json['params'] as Map).map((key, value) => MapEntry(key as String, value as Object)),
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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  static List<FractalPreset> listFromPrefs(String? payload) {
    if (payload == null || payload.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(payload) as List;
    return decoded
        .map((item) => FractalPreset.fromJson((item as Map).cast<String, Object?>()))
        .toList();
  }

  static String listToPrefs(List<FractalPreset> presets) {
    return jsonEncode(presets.map((preset) => preset.toJson()).toList());
  }
}
