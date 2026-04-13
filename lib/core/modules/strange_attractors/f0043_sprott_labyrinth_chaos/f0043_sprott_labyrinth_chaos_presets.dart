// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0043SprottLabyrinthChaosPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0043SprottLabyrinthChaosPreset({required this.id, required this.name, required this.params});
}

class F0043SprottLabyrinthChaosPresets {
  static const F0043SprottLabyrinthChaosPreset classic = F0043SprottLabyrinthChaosPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0043SprottLabyrinthChaosPreset> all = [
    classic,
  ];
}
