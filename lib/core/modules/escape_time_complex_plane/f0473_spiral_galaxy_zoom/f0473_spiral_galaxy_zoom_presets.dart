// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0473SpiralGalaxyZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0473SpiralGalaxyZoomPreset({required this.id, required this.name, required this.params});
}

class F0473SpiralGalaxyZoomPresets {
  static const F0473SpiralGalaxyZoomPreset namedView = F0473SpiralGalaxyZoomPreset(
    id: 'named_view',
    name: 'Spiral Galaxy Zoom view',
    params: {
      'center_re': 0.2824,
      'center_im': 0.01,
      'zoom': 8000.0,
    },
  );

  static const List<F0473SpiralGalaxyZoomPreset> all = [
    namedView,
  ];
}
