// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0462SatelliteArmZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0462SatelliteArmZoomPreset({required this.id, required this.name, required this.params});
}

class F0462SatelliteArmZoomPresets {
  static const F0462SatelliteArmZoomPreset namedView = F0462SatelliteArmZoomPreset(
    id: 'named_view',
    name: 'Satellite Arm Zoom view',
    params: {
      'center_re': -0.10715,
      'center_im': 0.9121,
      'zoom': 5000.0,
    },
  );

  static const List<F0462SatelliteArmZoomPreset> all = [
    namedView,
  ];
}
