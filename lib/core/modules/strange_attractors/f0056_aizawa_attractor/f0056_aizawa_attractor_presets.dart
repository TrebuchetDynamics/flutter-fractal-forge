// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0056AizawaAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0056AizawaAttractorPreset({required this.id, required this.name, required this.params});
}

class F0056AizawaAttractorPresets {
  static const F0056AizawaAttractorPreset classic = F0056AizawaAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0056AizawaAttractorPreset> all = [
    classic,
  ];
}
