// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0044SprottMinimumChaoticFlowPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0044SprottMinimumChaoticFlowPreset({required this.id, required this.name, required this.params});
}

class F0044SprottMinimumChaoticFlowPresets {
  static const F0044SprottMinimumChaoticFlowPreset classic = F0044SprottMinimumChaoticFlowPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0044SprottMinimumChaoticFlowPreset> all = [
    classic,
  ];
}
