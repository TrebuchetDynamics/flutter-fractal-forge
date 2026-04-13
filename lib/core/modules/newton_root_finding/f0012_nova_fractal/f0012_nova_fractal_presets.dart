// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class F0012NovaFractalPreset {
  final String id;
  final String name;
  final Map<String, double> params;
  const F0012NovaFractalPreset({required this.id, required this.name, required this.params});
}

class F0012NovaFractalPresets {
  static const F0012NovaFractalPreset classicNova = F0012NovaFractalPreset(
    id: 'classic_nova',
    name: 'Classic Nova (cubic, R=1, c=0)',
    params: {
      'power': 3.0,
      'relaxation': 1.0,
      'c_re': 0.0,
      'c_im': 0.0,
    },
  );
  static const F0012NovaFractalPreset offsetNova = F0012NovaFractalPreset(
    id: 'offset_nova',
    name: 'Offset Nova (c=0.3+0.2i)',
    params: {
      'power': 3.0,
      'relaxation': 1.0,
      'c_re': 0.3,
      'c_im': 0.2,
    },
  );
  static const F0012NovaFractalPreset underRelaxed = F0012NovaFractalPreset(
    id: 'under_relaxed',
    name: 'Under-relaxed (R=0.5)',
    params: {
      'power': 3.0,
      'relaxation': 0.5,
      'c_re': 0.0,
      'c_im': 0.0,
    },
  );
  static const F0012NovaFractalPreset overRelaxed = F0012NovaFractalPreset(
    id: 'over_relaxed',
    name: 'Over-relaxed (R=1.8)',
    params: {
      'power': 3.0,
      'relaxation': 1.8,
      'c_re': 0.0,
      'c_im': 0.0,
    },
  );

  static const List<F0012NovaFractalPreset> all = [
    classicNova,
    offsetNova,
    underRelaxed,
    overRelaxed,
  ];
}
