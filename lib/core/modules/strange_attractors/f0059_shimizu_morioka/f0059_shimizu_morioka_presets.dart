// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0059ShimizuMoriokaPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0059ShimizuMoriokaPreset({required this.id, required this.name, required this.params});
}

class F0059ShimizuMoriokaPresets {
  static const F0059ShimizuMoriokaPreset classic = F0059ShimizuMoriokaPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0059ShimizuMoriokaPreset> all = [
    classic,
  ];
}
