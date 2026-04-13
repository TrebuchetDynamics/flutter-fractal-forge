// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0078YuWangPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0078YuWangPreset({required this.id, required this.name, required this.params});
}

class F0078YuWangPresets {
  static const F0078YuWangPreset classic = F0078YuWangPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0078YuWangPreset> all = [
    classic,
  ];
}
