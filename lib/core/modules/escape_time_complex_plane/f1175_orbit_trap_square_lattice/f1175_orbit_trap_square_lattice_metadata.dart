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
class F1175OrbitTrapSquareLatticeMetadata {
  static const instance = F1175OrbitTrapSquareLatticeMetadata._();
  const F1175OrbitTrapSquareLatticeMetadata._();

  String get id => 'f1175_orbit_trap_square_lattice';
  String get name => 'Orbit Trap Square Lattice';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
    'lattice trap',
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
