// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0067ArneodoAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0067ArneodoAttractorPreset({required this.id, required this.name, required this.params});
}

class F0067ArneodoAttractorPresets {
  static const F0067ArneodoAttractorPreset classic = F0067ArneodoAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0067ArneodoAttractorPreset> all = [
    classic,
  ];
}
