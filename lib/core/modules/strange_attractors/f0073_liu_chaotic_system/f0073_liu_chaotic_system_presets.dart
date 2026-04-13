// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0073LiuChaoticSystemPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0073LiuChaoticSystemPreset({required this.id, required this.name, required this.params});
}

class F0073LiuChaoticSystemPresets {
  static const F0073LiuChaoticSystemPreset classic = F0073LiuChaoticSystemPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0073LiuChaoticSystemPreset> all = [
    classic,
  ];
}
