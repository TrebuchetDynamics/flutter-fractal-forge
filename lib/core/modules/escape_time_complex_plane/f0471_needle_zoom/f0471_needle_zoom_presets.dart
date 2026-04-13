// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0471NeedleZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0471NeedleZoomPreset({required this.id, required this.name, required this.params});
}

class F0471NeedleZoomPresets {
  static const F0471NeedleZoomPreset namedView = F0471NeedleZoomPreset(
    id: 'named_view',
    name: 'Needle Zoom view',
    params: {
      'center_re': -1.99999,
      'center_im': 0.0,
      'zoom': 100000.0,
    },
  );

  static const List<F0471NeedleZoomPreset> all = [
    namedView,
  ];
}
