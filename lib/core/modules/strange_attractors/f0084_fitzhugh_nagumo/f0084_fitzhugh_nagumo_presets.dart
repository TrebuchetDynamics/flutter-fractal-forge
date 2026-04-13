// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0084FitzhughNagumoPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0084FitzhughNagumoPreset({required this.id, required this.name, required this.params});
}

class F0084FitzhughNagumoPresets {
  static const F0084FitzhughNagumoPreset classic = F0084FitzhughNagumoPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0084FitzhughNagumoPreset> all = [
    classic,
  ];
}
