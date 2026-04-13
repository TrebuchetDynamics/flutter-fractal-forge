// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0046SprottConservativeScPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0046SprottConservativeScPreset({required this.id, required this.name, required this.params});
}

class F0046SprottConservativeScPresets {
  static const F0046SprottConservativeScPreset classic = F0046SprottConservativeScPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0046SprottConservativeScPreset> all = [
    classic,
  ];
}
