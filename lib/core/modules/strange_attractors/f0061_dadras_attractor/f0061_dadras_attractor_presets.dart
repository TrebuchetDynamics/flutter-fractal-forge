// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0061DadrasAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0061DadrasAttractorPreset({required this.id, required this.name, required this.params});
}

class F0061DadrasAttractorPresets {
  static const F0061DadrasAttractorPreset classic = F0061DadrasAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0061DadrasAttractorPreset> all = [
    classic,
  ];
}
