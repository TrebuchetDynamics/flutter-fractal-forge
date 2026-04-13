// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0055HalvorsenAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0055HalvorsenAttractorPreset({required this.id, required this.name, required this.params});
}

class F0055HalvorsenAttractorPresets {
  static const F0055HalvorsenAttractorPreset classic = F0055HalvorsenAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0055HalvorsenAttractorPreset> all = [
    classic,
  ];
}
