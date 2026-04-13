// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0031SprottRPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0031SprottRPreset({required this.id, required this.name, required this.params});
}

class F0031SprottRPresets {
  static const F0031SprottRPreset classic = F0031SprottRPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0031SprottRPreset> all = [
    classic,
  ];
}
