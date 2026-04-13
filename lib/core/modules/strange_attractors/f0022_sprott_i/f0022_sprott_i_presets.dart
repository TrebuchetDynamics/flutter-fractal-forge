// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0022SprottIPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0022SprottIPreset({required this.id, required this.name, required this.params});
}

class F0022SprottIPresets {
  static const F0022SprottIPreset classic = F0022SprottIPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0022SprottIPreset> all = [
    classic,
  ];
}
