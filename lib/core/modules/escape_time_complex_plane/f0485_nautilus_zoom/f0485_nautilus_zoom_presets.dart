// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0485NautilusZoomPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0485NautilusZoomPreset({required this.id, required this.name, required this.params});
}

class F0485NautilusZoomPresets {
  static const F0485NautilusZoomPreset namedView = F0485NautilusZoomPreset(
    id: 'named_view',
    name: 'Nautilus Zoom view',
    params: {
      'center_re': 0.3752,
      'center_im': 0.148,
      'zoom': 500.0,
    },
  );

  static const List<F0485NautilusZoomPreset> all = [
    namedView,
  ];
}
