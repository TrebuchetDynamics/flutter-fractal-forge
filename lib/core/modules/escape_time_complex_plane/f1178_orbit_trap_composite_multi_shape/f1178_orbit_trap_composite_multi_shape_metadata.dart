// GENERATED — DO NOT EDIT BY HAND.
import 'package:meta/meta.dart';

@immutable
class Citation {
  final String? author;
  final String? title;
  final int? year;
  final String url;
  const Citation({this.author, this.title, this.year, required this.url});
}

@immutable
class F1178OrbitTrapCompositeMultiShapeMetadata {
  static const instance = F1178OrbitTrapCompositeMultiShapeMetadata._();
  const F1178OrbitTrapCompositeMultiShapeMetadata._();

  String get id => 'f1178_orbit_trap_composite_multi_shape';
  String get name => 'Orbit Trap Composite Multi-Shape';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'C. Pickover',
      title: 'Computers, Pattern, Chaos and Beauty',
      year: 1990,
      url: 'https://en.wikipedia.org/wiki/Orbit_trap',
    ),
  ];
}
