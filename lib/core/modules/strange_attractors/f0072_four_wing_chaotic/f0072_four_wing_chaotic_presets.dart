// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0072FourWingChaoticPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0072FourWingChaoticPreset({required this.id, required this.name, required this.params});
}

class F0072FourWingChaoticPresets {
  static const F0072FourWingChaoticPreset classic = F0072FourWingChaoticPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0072FourWingChaoticPreset> all = [
    classic,
  ];
}
