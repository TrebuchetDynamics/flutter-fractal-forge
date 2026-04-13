// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0045SprottWindmiPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0045SprottWindmiPreset({required this.id, required this.name, required this.params});
}

class F0045SprottWindmiPresets {
  static const F0045SprottWindmiPreset classic = F0045SprottWindmiPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0045SprottWindmiPreset> all = [
    classic,
  ];
}
