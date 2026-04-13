// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0475MandelbrotAntennaPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0475MandelbrotAntennaPreset({required this.id, required this.name, required this.params});
}

class F0475MandelbrotAntennaPresets {
  static const F0475MandelbrotAntennaPreset namedView = F0475MandelbrotAntennaPreset(
    id: 'named_view',
    name: 'Mandelbrot Antenna view',
    params: {
      'center_re': -1.5437,
      'center_im': 0.0,
      'zoom': 200.0,
    },
  );

  static const List<F0475MandelbrotAntennaPreset> all = [
    namedView,
  ];
}
