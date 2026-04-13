// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0050RSslerAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0050RSslerAttractorPreset({required this.id, required this.name, required this.params});
}

class F0050RSslerAttractorPresets {
  static const F0050RSslerAttractorPreset classic = F0050RSslerAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0050RSslerAttractorPreset> all = [
    classic,
  ];
}
