// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0062BurkeShawPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0062BurkeShawPreset({required this.id, required this.name, required this.params});
}

class F0062BurkeShawPresets {
  static const F0062BurkeShawPreset classic = F0062BurkeShawPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0062BurkeShawPreset> all = [
    classic,
  ];
}
