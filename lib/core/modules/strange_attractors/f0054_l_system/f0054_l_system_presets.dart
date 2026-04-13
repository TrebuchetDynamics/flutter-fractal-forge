// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0054LSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0054LSystemPreset({required this.id, required this.name, required this.params});
}

class F0054LSystemPresets {
  static const F0054LSystemPreset classic = F0054LSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0054LSystemPreset> all = [
    classic,
  ];
}
