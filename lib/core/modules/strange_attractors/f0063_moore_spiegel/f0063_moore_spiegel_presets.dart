// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0063MooreSpiegelPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0063MooreSpiegelPreset({required this.id, required this.name, required this.params});
}

class F0063MooreSpiegelPresets {
  static const F0063MooreSpiegelPreset classic = F0063MooreSpiegelPreset(
    id: 'classic',
    name: 'Canonical parameters',
    params: {
      'step_size': 0.005,
    },
  );

  static const List<F0063MooreSpiegelPreset> all = [
    classic,
  ];
}
