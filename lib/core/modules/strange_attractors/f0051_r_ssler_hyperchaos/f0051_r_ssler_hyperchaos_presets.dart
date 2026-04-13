// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0051RSslerHyperchaosPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0051RSslerHyperchaosPreset({required this.id, required this.name, required this.params});
}

class F0051RSslerHyperchaosPresets {
  static const F0051RSslerHyperchaosPreset classic = F0051RSslerHyperchaosPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0051RSslerHyperchaosPreset> all = [
    classic,
  ];
}
