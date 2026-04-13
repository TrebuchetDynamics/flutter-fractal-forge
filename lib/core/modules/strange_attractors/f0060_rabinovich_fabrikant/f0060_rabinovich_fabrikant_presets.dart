// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0060RabinovichFabrikantPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0060RabinovichFabrikantPreset({required this.id, required this.name, required this.params});
}

class F0060RabinovichFabrikantPresets {
  static const F0060RabinovichFabrikantPreset classic = F0060RabinovichFabrikantPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0060RabinovichFabrikantPreset> all = [
    classic,
  ];
}
