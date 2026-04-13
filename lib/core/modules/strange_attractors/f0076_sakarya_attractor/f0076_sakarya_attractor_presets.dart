// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0076SakaryaAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0076SakaryaAttractorPreset({required this.id, required this.name, required this.params});
}

class F0076SakaryaAttractorPresets {
  static const F0076SakaryaAttractorPreset classic = F0076SakaryaAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0076SakaryaAttractorPreset> all = [
    classic,
  ];
}
