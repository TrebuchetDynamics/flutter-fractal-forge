// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0077BoualiAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0077BoualiAttractorPreset({required this.id, required this.name, required this.params});
}

class F0077BoualiAttractorPresets {
  static const F0077BoualiAttractorPreset classic = F0077BoualiAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0077BoualiAttractorPreset> all = [
    classic,
  ];
}
