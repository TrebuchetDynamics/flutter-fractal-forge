// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0085LangfordAttractorPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0085LangfordAttractorPreset({required this.id, required this.name, required this.params});
}

class F0085LangfordAttractorPresets {
  static const F0085LangfordAttractorPreset classic = F0085LangfordAttractorPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0085LangfordAttractorPreset> all = [
    classic,
  ];
}
