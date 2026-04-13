// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0075HadleyCirculationPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0075HadleyCirculationPreset({required this.id, required this.name, required this.params});
}

class F0075HadleyCirculationPresets {
  static const F0075HadleyCirculationPreset classic = F0075HadleyCirculationPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0075HadleyCirculationPreset> all = [
    classic,
  ];
}
