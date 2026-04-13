// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0074QiChaoticSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0074QiChaoticSystemPreset({required this.id, required this.name, required this.params});
}

class F0074QiChaoticSystemPresets {
  static const F0074QiChaoticSystemPreset classic = F0074QiChaoticSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0074QiChaoticSystemPreset> all = [
    classic,
  ];
}
