// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0064NewtonLeipnikPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0064NewtonLeipnikPreset({required this.id, required this.name, required this.params});
}

class F0064NewtonLeipnikPresets {
  static const F0064NewtonLeipnikPreset classic = F0064NewtonLeipnikPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0064NewtonLeipnikPreset> all = [
    classic,
  ];
}
