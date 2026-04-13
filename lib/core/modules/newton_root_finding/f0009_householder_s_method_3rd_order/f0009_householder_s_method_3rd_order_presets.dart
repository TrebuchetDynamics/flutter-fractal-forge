// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0009HouseholderSMethod3rdOrderPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0009HouseholderSMethod3rdOrderPreset({required this.id, required this.name, required this.params});
}

class F0009HouseholderSMethod3rdOrderPresets {
  static const F0009HouseholderSMethod3rdOrderPreset h3Cubic = F0009HouseholderSMethod3rdOrderPreset(
    id: 'h3_cubic',
    name: 'H3 cubic (d=3, order=3)',
    params: {
      'order': 3.0,
      'power': 3.0,
    },
  );
  static const F0009HouseholderSMethod3rdOrderPreset h2IsHalley = F0009HouseholderSMethod3rdOrderPreset(
    id: 'h2_is_halley',
    name: 'H2 (reduces to Halley)',
    params: {
      'order': 2.0,
      'power': 3.0,
    },
  );

  static const List<F0009HouseholderSMethod3rdOrderPreset> all = [
    h3Cubic,
    h2IsHalley,
  ];
}
