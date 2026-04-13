// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0079GenesioTesiPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0079GenesioTesiPreset({required this.id, required this.name, required this.params});
}

class F0079GenesioTesiPresets {
  static const F0079GenesioTesiPreset classic = F0079GenesioTesiPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0079GenesioTesiPreset> all = [
    classic,
  ];
}
