// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0081HindmarshRosePreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0081HindmarshRosePreset({required this.id, required this.name, required this.params});
}

class F0081HindmarshRosePresets {
  static const F0081HindmarshRosePreset classic = F0081HindmarshRosePreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0081HindmarshRosePreset> all = [
    classic,
  ];
}
