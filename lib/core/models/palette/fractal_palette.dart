import 'dart:convert';

import 'package:flutter/material.dart';

const int maxFractalPaletteStops = 8;

const List<FractalColorStop> fallbackFractalPaletteStops = [
  FractalColorStop(position: 0.0, colorArgb: 0xFF000000),
  FractalColorStop(position: 1.0, colorArgb: 0xFFFFFFFF),
];

List<FractalColorStop> _snapshotPaletteStops(List<FractalColorStop> stops) {
  return List<FractalColorStop>.unmodifiable(stops);
}

/// Normalizes palette stops before display, persistence, or shader upload.
///
/// Imported palette JSON can contain empty, single-stop, overlong, out-of-range,
/// or non-finite stop positions. Keep this contract in the model so gradients
/// and shader paths cannot drift on which endpoint colors survive.
List<FractalColorStop> normalizeFractalPaletteStops(
  List<FractalColorStop> stops, {
  int maxStops = maxFractalPaletteStops,
}) {
  final effectiveMaxStops = maxStops < 2 ? 2 : maxStops;
  final finiteStops = _stopsWithFinitePositions(stops);
  if (finiteStops.isEmpty) return fallbackFractalPaletteStops;

  final sorted = [...finiteStops]
    ..sort((a, b) => a.position.compareTo(b.position));
  final clamped = sorted
      .map((stop) => stop.copyWith(
            position: _clampPaletteStopPosition(stop.position),
          ))
      .toList();

  final bounded = _capPaletteStopsPreservingEndpoint(
    clamped,
    maxStops: effectiveMaxStops,
  );
  final normalized = _ensurePaletteEndpointStops(bounded);

  assert(normalized.length >= 2);
  assert(normalized.length <= effectiveMaxStops);
  assert(normalized.first.position == 0.0);
  assert(normalized.last.position == 1.0);
  return normalized;
}

List<FractalColorStop> _stopsWithFinitePositions(
  List<FractalColorStop> stops,
) {
  return stops.where((stop) => stop.position.isFinite).toList();
}

List<FractalColorStop> _capPaletteStopsPreservingEndpoint(
  List<FractalColorStop> stops, {
  required int maxStops,
}) {
  assert(stops.isNotEmpty);
  return stops.length > maxStops
      ? [
          ...stops.take(maxStops - 1),
          stops.last,
        ]
      : stops;
}

List<FractalColorStop> _ensurePaletteEndpointStops(
  List<FractalColorStop> stops,
) {
  assert(stops.isNotEmpty);
  if (stops.length == 1) {
    final stop = stops.single;
    return [
      stop.copyWith(position: 0.0),
      stop.copyWith(position: 1.0),
    ];
  }

  return [
    stops.first.copyWith(position: 0.0),
    ...stops.skip(1).take(stops.length - 2),
    stops.last.copyWith(position: 1.0),
  ];
}

/// Clamp a finite palette stop position into the shader/gradient range.
double _clampPaletteStopPosition(double position) {
  assert(position.isFinite, 'Palette stop position must be finite');
  return position.clamp(0.0, 1.0).toDouble();
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
    final normalized = normalizeFractalPaletteStops(stops);
    return LinearGradient(
      colors: normalized.map((s) => s.color).toList(),
      stops: normalized.map((s) => s.position).toList(),
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
