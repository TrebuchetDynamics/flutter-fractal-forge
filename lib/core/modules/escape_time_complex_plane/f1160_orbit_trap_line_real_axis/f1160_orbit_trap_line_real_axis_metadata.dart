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
class F1160OrbitTrapLineRealAxisMetadata {
  static const instance = F1160OrbitTrapLineRealAxisMetadata._();
  const F1160OrbitTrapLineRealAxisMetadata._();

  String get id => 'f1160_orbit_trap_line_real_axis';
  String get name => 'Orbit Trap Line (Real Axis)';
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
