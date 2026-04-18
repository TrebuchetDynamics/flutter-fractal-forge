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
class F1169OrbitTrapRoseCurveMetadata {
  static const instance = F1169OrbitTrapRoseCurveMetadata._();
  const F1169OrbitTrapRoseCurveMetadata._();

  String get id => 'f1169_orbit_trap_rose_curve';
  String get name => 'Orbit Trap Rose Curve';
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
