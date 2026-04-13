// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0030SprottQPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0030SprottQPreset({required this.id, required this.name, required this.params});
}

class F0030SprottQPresets {
  static const F0030SprottQPreset classic = F0030SprottQPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0030SprottQPreset> all = [
    classic,
  ];
}
