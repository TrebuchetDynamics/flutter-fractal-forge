// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0065RucklidgeAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0065RucklidgeAttractorPreset({required this.id, required this.name, required this.params});
}

class F0065RucklidgeAttractorPresets {
  static const F0065RucklidgeAttractorPreset classic = F0065RucklidgeAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0065RucklidgeAttractorPreset> all = [
    classic,
  ];
}
