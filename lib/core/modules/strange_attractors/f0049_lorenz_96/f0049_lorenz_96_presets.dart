// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0049Lorenz96Preset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0049Lorenz96Preset({required this.id, required this.name, required this.params});
}

class F0049Lorenz96Presets {
  static const F0049Lorenz96Preset classic = F0049Lorenz96Preset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0049Lorenz96Preset> all = [
    classic,
  ];
}
