import 'dart:convert';

/// Tracks exploration statistics across sessions.
class _ExplorationStatsFractalIds {
  const _ExplorationStatsFractalIds._();

  static Set<String> snapshot(Iterable<Object?>? ids) {
    if (ids == null) return const <String>{};

    final safeIds = <String>{};
    for (final id in ids) {
      if (id is String && id.isNotEmpty) {
        safeIds.add(id);
      }
    }
    return Set<String>.unmodifiable(safeIds);
  }

  static Set<String> fromJsonValue(Object? value) {
    if (value is! Iterable) return const <String>{};
    return snapshot(value.cast<Object?>());
  }
}

class ExplorationStats {
  final double totalZoomDistance;
  final int totalTimeSeconds;
  final int screenshotsTaken;
  final Set<String> uniqueFractalsExplored;
  final DateTime? firstExplorationDate;
  final DateTime lastUpdated;

  ExplorationStats({
    this.totalZoomDistance = 0.0,
    this.totalTimeSeconds = 0,
    this.screenshotsTaken = 0,
    Set<String>? uniqueFractalsExplored,
    this.firstExplorationDate,
    DateTime? lastUpdated,
  })  : uniqueFractalsExplored = _ExplorationStatsFractalIds.snapshot(
          uniqueFractalsExplored,
        ),
        lastUpdated = lastUpdated ?? DateTime.now();

  ExplorationStats copyWith({
    double? totalZoomDistance,
    int? totalTimeSeconds,
    int? screenshotsTaken,
    Set<String>? uniqueFractalsExplored,
    DateTime? firstExplorationDate,
    DateTime? lastUpdated,
  }) {
    return ExplorationStats(
      totalZoomDistance: totalZoomDistance ?? this.totalZoomDistance,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      screenshotsTaken: screenshotsTaken ?? this.screenshotsTaken,
      uniqueFractalsExplored:
          uniqueFractalsExplored ?? this.uniqueFractalsExplored,
      firstExplorationDate: firstExplorationDate ?? this.firstExplorationDate,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalZoomDistance': totalZoomDistance,
        'totalTimeSeconds': totalTimeSeconds,
        'screenshotsTaken': screenshotsTaken,
        'uniqueFractalsExplored': uniqueFractalsExplored.toList(),
        'firstExplorationDate': firstExplorationDate?.toIso8601String(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory ExplorationStats.fromJson(Map<String, dynamic> json) {
    return ExplorationStats(
      totalZoomDistance: (json['totalZoomDistance'] as num?)?.toDouble() ?? 0.0,
      totalTimeSeconds: json['totalTimeSeconds'] as int? ?? 0,
      screenshotsTaken: json['screenshotsTaken'] as int? ?? 0,
      uniqueFractalsExplored: _ExplorationStatsFractalIds.fromJsonValue(
        json['uniqueFractalsExplored'],
      ),
      firstExplorationDate: json['firstExplorationDate'] != null
          ? DateTime.tryParse(json['firstExplorationDate'] as String)
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String encode() => jsonEncode(toJson());

  static ExplorationStats decode(String source) {
    try {
      return ExplorationStats.fromJson(
          jsonDecode(source) as Map<String, dynamic>);
    } catch (_) {
      return ExplorationStats();
    }
  }
}
