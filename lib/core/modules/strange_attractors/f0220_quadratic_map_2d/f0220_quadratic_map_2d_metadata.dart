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
class F0220QuadraticMap2dMetadata {
  static const instance = F0220QuadraticMap2dMetadata._();
  const F0220QuadraticMap2dMetadata._();

  String get id => 'f0220_quadratic_map_2d';
  String get name => 'Quadratic Map 2D';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. C. Sprott',
      title: 'Automatic generation of strange attractors',
      year: 1993,
      url: 'https://sprott.physics.wisc.edu/pubs/paper191.pdf',
    ),
  ];
}
