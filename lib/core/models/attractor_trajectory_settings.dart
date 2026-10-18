import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The bounded continuous systems with an approved trajectory presentation.
enum AttractorSystem { thomas, fourWing, lorenz2d }

/// Projection from the three-dimensional trajectory to the visible plane.
enum OrbitProjection { xz, thomasOblique }

@immutable
class OrbitPoint {
  final double x;
  final double y;
  final double z;

  const OrbitPoint(this.x, this.y, this.z);

  bool get isFinite => x.isFinite && y.isFinite && z.isFinite;

  OrbitPoint operator +(OrbitPoint other) =>
      OrbitPoint(x + other.x, y + other.y, z + other.z);

  OrbitPoint operator -(OrbitPoint other) =>
      OrbitPoint(x - other.x, y - other.y, z - other.z);

  double get length => math.sqrt(x * x + y * y + z * z);

  OrbitPoint operator *(double scale) =>
      OrbitPoint(x * scale, y * scale, z * scale);
}

@immutable
class ProjectedOrbitPoint {
  final double x;
  final double y;

  const ProjectedOrbitPoint(this.x, this.y);
}

/// Persisted numerical and projection identity for a trajectory view.
@immutable
class OrbitTrajectorySettings {
  static const int currentVersion = 1;
  static const int maximumSteps = 25000;
  static const int maximumRetainedSamples = 20000;
  static const int defaultBurnInSteps = 5000;
  static const int defaultRetainedSteps = 20000;
  static const double defaultStepSize = 0.01;

  final int version;
  final AttractorSystem system;
  final OrbitPoint seed;
  final String integrator;
  final double stepSize;
  final int burnInSteps;
  final int retainedSteps;
  final OrbitProjection projection;

  OrbitTrajectorySettings({
    this.version = currentVersion,
    required this.system,
    this.seed = const OrbitPoint(0.1, 0.2, 0.3),
    this.integrator = 'rk4',
    this.stepSize = defaultStepSize,
    this.burnInSteps = defaultBurnInSteps,
    this.retainedSteps = defaultRetainedSteps,
    required this.projection,
  }) {
    _validate();
  }

  factory OrbitTrajectorySettings.defaultsFor(String moduleId) {
    final settings = defaultsForOrNull(moduleId);
    if (settings == null) {
      throw ArgumentError.value(
        moduleId,
        'moduleId',
        'No trajectory presentation is approved for this module',
      );
    }
    return settings;
  }

  static OrbitTrajectorySettings? defaultsForOrNull(String moduleId) {
    return switch (moduleId) {
      'thomas_attractor' => OrbitTrajectorySettings(
          system: AttractorSystem.thomas,
          projection: OrbitProjection.thomasOblique,
        ),
      'four_wing' => OrbitTrajectorySettings(
          system: AttractorSystem.fourWing,
          seed: const OrbitPoint(1, 1, 1),
          projection: OrbitProjection.xz,
        ),
      'lorenz_2d' => OrbitTrajectorySettings(
          system: AttractorSystem.lorenz2d,
          projection: OrbitProjection.xz,
        ),
      _ => null,
    };
  }

  void _validate() {
    if (version != currentVersion) {
      throw ArgumentError.value(version, 'version', 'Unsupported version');
    }
    if (!seed.isFinite) {
      throw ArgumentError.value(seed, 'seed', 'Must be finite');
    }
    if (integrator != 'rk4') {
      throw ArgumentError.value(integrator, 'integrator', 'Must be rk4');
    }
    if (!stepSize.isFinite || stepSize <= 0 || stepSize > 0.1) {
      throw ArgumentError.value(stepSize, 'stepSize', 'Out of range');
    }
    if (burnInSteps < 0 || retainedSteps <= 0) {
      throw ArgumentError('Trajectory step counts must be positive.');
    }
    if (retainedSteps > maximumRetainedSamples ||
        burnInSteps + retainedSteps > maximumSteps) {
      throw ArgumentError('Trajectory exceeds the accepted work cap.');
    }
  }

  OrbitTrajectorySettings copyWith({
    OrbitPoint? seed,
    double? stepSize,
    int? burnInSteps,
    int? retainedSteps,
    OrbitProjection? projection,
  }) {
    return OrbitTrajectorySettings(
      version: version,
      system: system,
      seed: seed ?? this.seed,
      integrator: integrator,
      stepSize: stepSize ?? this.stepSize,
      burnInSteps: burnInSteps ?? this.burnInSteps,
      retainedSteps: retainedSteps ?? this.retainedSteps,
      projection: projection ?? this.projection,
    );
  }

  Map<String, Object> toJson() => {
        'version': version,
        'system': system.name,
        'seed': [seed.x, seed.y, seed.z],
        'integrator': integrator,
        'stepSize': stepSize,
        'burnInSteps': burnInSteps,
        'retainedSteps': retainedSteps,
        'projection': projection.name,
      };

  factory OrbitTrajectorySettings.fromJson(Map<Object?, Object?> json) {
    final version = json['version'];
    final system = _enumValue(AttractorSystem.values, json['system']);
    final seed = json['seed'];
    final integrator = json['integrator'];
    final stepSize = json['stepSize'];
    final burnInSteps = json['burnInSteps'];
    final retainedSteps = json['retainedSteps'];
    final projection = _enumValue(OrbitProjection.values, json['projection']);
    if (version is! int ||
        system == null ||
        seed is! List ||
        seed.length != 3 ||
        seed.any((value) => value is! num || !value.isFinite) ||
        integrator is! String ||
        stepSize is! num ||
        burnInSteps is! int ||
        retainedSteps is! int ||
        projection == null) {
      throw const FormatException('Invalid trajectory representation.');
    }
    return OrbitTrajectorySettings(
      version: version,
      system: system,
      seed: OrbitPoint(
        (seed[0] as num).toDouble(),
        (seed[1] as num).toDouble(),
        (seed[2] as num).toDouble(),
      ),
      integrator: integrator,
      stepSize: stepSize.toDouble(),
      burnInSteps: burnInSteps,
      retainedSteps: retainedSteps,
      projection: projection,
    );
  }

  bool isCompatibleWith(String moduleId) {
    final defaults = defaultsForOrNull(moduleId);
    return defaults != null &&
        defaults.system == system &&
        defaults.projection == projection;
  }

  String get cacheKey =>
      '$version:${system.name}:${seed.x},${seed.y},${seed.z}:'
      '$integrator:$stepSize:$burnInSteps:$retainedSteps:${projection.name}';

  @override
  bool operator ==(Object other) =>
      other is OrbitTrajectorySettings && other.cacheKey == cacheKey;

  @override
  int get hashCode => cacheKey.hashCode;
}

OrbitTrajectorySettings? decodeOrbitTrajectorySettings(Object? value) {
  if (value == null) return null;
  if (value is! Map) {
    throw const FormatException('Invalid trajectory representation.');
  }
  return OrbitTrajectorySettings.fromJson(value.cast<Object?, Object?>());
}

T? _enumValue<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
