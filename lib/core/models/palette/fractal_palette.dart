import 'dart:convert';

import 'package:flutter/material.dart';

List<FractalColorStop> _snapshotPaletteStops(List<FractalColorStop> stops) {
  return List<FractalColorStop>.unmodifiable(stops);
}

@immutable
class FractalColorStop {
  final double position; // 0..1
  final int colorArgb; // 0xAARRGGBB

  const FractalColorStop({
    required this.position,
    required this.colorArgb,
  });

  Color get color => Color(colorArgb);

  FractalColorStop copyWith({
    double? position,
    int? colorArgb,
  }) {
    return FractalColorStop(
      position: position ?? this.position,
      colorArgb: colorArgb ?? this.colorArgb,
    );
  }

  Map<String, Object?> toJson() => {
        'p': position,
        'c': colorArgb,
      };

  static FractalColorStop fromJson(Map<String, Object?> json) {
    final p = (json['p'] as num?)?.toDouble() ?? 0.0;
    final c = (json['c'] as num?)?.toInt() ?? 0xFFFFFFFF;
    return FractalColorStop(position: p, colorArgb: c);
  }
}

@immutable
class FractalPalette {
  final String id;
  final String name;
  final List<FractalColorStop> stops;
  final bool isBuiltIn;

  FractalPalette({
    required this.id,
    required this.name,
    required List<FractalColorStop> stops,
    this.isBuiltIn = false,
  }) : stops = _snapshotPaletteStops(stops);

  FractalPalette copyWith({
    String? id,
    String? name,
    List<FractalColorStop>? stops,
    bool? isBuiltIn,
  }) {
    return FractalPalette(
      id: id ?? this.id,
      name: name ?? this.name,
      stops: stops ?? this.stops,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  LinearGradient toLinearGradient() {
    final sorted = [...stops]..sort((a, b) => a.position.compareTo(b.position));
    return LinearGradient(
      colors: sorted.map((s) => s.color).toList(),
      stops: sorted.map((s) => s.position.clamp(0.0, 1.0)).toList(),
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'stops': stops.map((s) => s.toJson()).toList(),
      };

  static FractalPalette fromJson(Map<String, Object?> json) {
    final id = (json['id'] as String?) ?? '';
    final name = (json['name'] as String?) ?? 'Palette';
    final rawStops = (json['stops'] as List?) ?? const [];
    final stops = rawStops
        .whereType<Map>()
        .map((m) => FractalColorStop.fromJson(m.cast<String, Object?>()))
        .toList();

    return FractalPalette(
      id: id,
      name: name,
      stops: stops,
      isBuiltIn: false,
    );
  }

  String toJsonString({bool pretty = true}) {
    final map = toJson();
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(map)
        : jsonEncode(map);
  }

  static FractalPalette fromJsonString(String input) {
    final decoded = jsonDecode(input);
    if (decoded is! Map) {
      throw const FormatException('Palette JSON must be an object');
    }
    return FractalPalette.fromJson(decoded.cast<String, Object?>());
  }
}
