// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0053ChenAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0053ChenAttractorPreset({required this.id, required this.name, required this.params});
}

class F0053ChenAttractorPresets {
  static const F0053ChenAttractorPreset classic = F0053ChenAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0053ChenAttractorPreset> all = [
    classic,
  ];
}
