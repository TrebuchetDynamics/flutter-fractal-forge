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
class F1162OrbitTrapMultiLinesCrossMetadata {
  static const instance = F1162OrbitTrapMultiLinesCrossMetadata._();
  const F1162OrbitTrapMultiLinesCrossMetadata._();

  String get id => 'f1162_orbit_trap_multi_lines_cross';
  String get name => 'Orbit Trap Multi-Lines (Cross)';
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
