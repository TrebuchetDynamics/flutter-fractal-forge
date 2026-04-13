// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0430QuadSpiralPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0430QuadSpiralPreset({required this.id, required this.name, required this.params});
}

class F0430QuadSpiralPresets {
  static const F0430QuadSpiralPreset namedView = F0430QuadSpiralPreset(
    id: 'named_view',
    name: 'Quad Spiral view',
    params: {
      'center_re': -0.1,
      'center_im': 0.8405,
      'zoom': 100.0,
    },
  );

  static const List<F0430QuadSpiralPreset> all = [
    namedView,
  ];
}
