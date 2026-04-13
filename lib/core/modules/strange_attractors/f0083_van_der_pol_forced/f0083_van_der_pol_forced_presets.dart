// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0083VanDerPolForcedPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0083VanDerPolForcedPreset({required this.id, required this.name, required this.params});
}

class F0083VanDerPolForcedPresets {
  static const F0083VanDerPolForcedPreset classic = F0083VanDerPolForcedPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0083VanDerPolForcedPreset> all = [
    classic,
  ];
}
