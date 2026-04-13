// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0032SprottSPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0032SprottSPreset({required this.id, required this.name, required this.params});
}

class F0032SprottSPresets {
  static const F0032SprottSPreset classic = F0032SprottSPreset(
    id: 'classic',
    name: 'Classic view',
    params: {
      'step_size': 0.01,
    },
  );

  static const List<F0032SprottSPreset> all = [
    classic,
  ];
}
