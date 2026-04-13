// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0057ThomasAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0057ThomasAttractorPreset({required this.id, required this.name, required this.params});
}

class F0057ThomasAttractorPresets {
  static const F0057ThomasAttractorPreset classic = F0057ThomasAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0057ThomasAttractorPreset> all = [
    classic,
  ];
}
