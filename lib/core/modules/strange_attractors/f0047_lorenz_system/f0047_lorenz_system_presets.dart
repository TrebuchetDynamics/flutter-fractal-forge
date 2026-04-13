// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0047LorenzSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0047LorenzSystemPreset({required this.id, required this.name, required this.params});
}

class F0047LorenzSystemPresets {
  static const F0047LorenzSystemPreset classic = F0047LorenzSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0047LorenzSystemPreset> all = [
    classic,
  ];
}
