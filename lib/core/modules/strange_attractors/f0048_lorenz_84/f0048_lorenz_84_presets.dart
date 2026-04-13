// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0048Lorenz84Preset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0048Lorenz84Preset({required this.id, required this.name, required this.params});
}

class F0048Lorenz84Presets {
  static const F0048Lorenz84Preset classic = F0048Lorenz84Preset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0048Lorenz84Preset> all = [
    classic,
  ];
}
