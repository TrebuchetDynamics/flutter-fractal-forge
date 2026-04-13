// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0082DuffingOscillatorForcedPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0082DuffingOscillatorForcedPreset({required this.id, required this.name, required this.params});
}

class F0082DuffingOscillatorForcedPresets {
  static const F0082DuffingOscillatorForcedPreset classic = F0082DuffingOscillatorForcedPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0082DuffingOscillatorForcedPreset> all = [
    classic,
  ];
}
