// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0441MiniMandelbrotPeriod12Preset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0441MiniMandelbrotPeriod12Preset({required this.id, required this.name, required this.params});
}

class F0441MiniMandelbrotPeriod12Presets {
  static const F0441MiniMandelbrotPeriod12Preset namedView = F0441MiniMandelbrotPeriod12Preset(
    id: 'named_view',
    name: 'Mini Mandelbrot (period 12) view',
    params: {
      'center_re': -0.5,
      'center_im': 0.5655,
      'zoom': 30000.0,
    },
  );

  static const List<F0441MiniMandelbrotPeriod12Preset> all = [
    namedView,
  ];
}
