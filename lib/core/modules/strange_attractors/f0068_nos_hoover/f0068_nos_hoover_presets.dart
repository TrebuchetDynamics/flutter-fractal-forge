// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0068NosHooverPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0068NosHooverPreset({required this.id, required this.name, required this.params});
}

class F0068NosHooverPresets {
  static const F0068NosHooverPreset classic = F0068NosHooverPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0068NosHooverPreset> all = [
    classic,
  ];
}
