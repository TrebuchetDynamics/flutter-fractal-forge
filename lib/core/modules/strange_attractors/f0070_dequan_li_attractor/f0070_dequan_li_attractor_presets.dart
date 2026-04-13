// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0070DequanLiAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0070DequanLiAttractorPreset({required this.id, required this.name, required this.params});
}

class F0070DequanLiAttractorPresets {
  static const F0070DequanLiAttractorPreset classic = F0070DequanLiAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0070DequanLiAttractorPreset> all = [
    classic,
  ];
}
