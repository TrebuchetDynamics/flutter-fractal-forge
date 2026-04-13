// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0087VanDerPolUnforcedPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0087VanDerPolUnforcedPreset({required this.id, required this.name, required this.params});
}

class F0087VanDerPolUnforcedPresets {
  static const F0087VanDerPolUnforcedPreset classic = F0087VanDerPolUnforcedPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0087VanDerPolUnforcedPreset> all = [
    classic,
  ];
}
