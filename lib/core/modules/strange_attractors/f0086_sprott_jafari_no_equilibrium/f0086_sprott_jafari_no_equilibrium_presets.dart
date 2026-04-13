// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0086SprottJafariNoEquilibriumPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0086SprottJafariNoEquilibriumPreset({required this.id, required this.name, required this.params});
}

class F0086SprottJafariNoEquilibriumPresets {
  static const F0086SprottJafariNoEquilibriumPreset classic = F0086SprottJafariNoEquilibriumPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0086SprottJafariNoEquilibriumPreset> all = [
    classic,
  ];
}
