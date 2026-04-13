// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0066WangSunAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0066WangSunAttractorPreset({required this.id, required this.name, required this.params});
}

class F0066WangSunAttractorPresets {
  static const F0066WangSunAttractorPreset classic = F0066WangSunAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0066WangSunAttractorPreset> all = [
    classic,
  ];
}
