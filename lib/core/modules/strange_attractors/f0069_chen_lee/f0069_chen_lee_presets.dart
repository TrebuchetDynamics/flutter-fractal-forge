// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0069ChenLeePreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0069ChenLeePreset({required this.id, required this.name, required this.params});
}

class F0069ChenLeePresets {
  static const F0069ChenLeePreset classic = F0069ChenLeePreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0069ChenLeePreset> all = [
    classic,
  ];
}
