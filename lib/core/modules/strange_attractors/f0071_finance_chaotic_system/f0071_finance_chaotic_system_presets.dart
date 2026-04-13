// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0071FinanceChaoticSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0071FinanceChaoticSystemPreset({required this.id, required this.name, required this.params});
}

class F0071FinanceChaoticSystemPresets {
  static const F0071FinanceChaoticSystemPreset classic = F0071FinanceChaoticSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0071FinanceChaoticSystemPreset> all = [
    classic,
  ];
}
