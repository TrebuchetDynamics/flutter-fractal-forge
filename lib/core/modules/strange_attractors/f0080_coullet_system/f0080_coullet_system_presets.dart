// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0080CoulletSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0080CoulletSystemPreset({required this.id, required this.name, required this.params});
}

class F0080CoulletSystemPresets {
  static const F0080CoulletSystemPreset classic = F0080CoulletSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0080CoulletSystemPreset> all = [
    classic,
  ];
}
