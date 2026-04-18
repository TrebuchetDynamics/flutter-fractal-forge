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
class F0813QuadraticMapMandelbrot1dMetadata {
  static const instance = F0813QuadraticMapMandelbrot1dMetadata._();
  const F0813QuadraticMapMandelbrot1dMetadata._();

  String get id => 'f0813_quadratic_map_mandelbrot_1d';
  String get name => 'Quadratic Map (Mandelbrot 1D)';
  String get category => 'Strange Attractors';

  List<String> get aliases => const [
    '1D Mandelbrot c=-1.7',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. Milnor',
      title: 'Dynamics in one complex variable',
      year: 2006,
      url: 'https://en.wikipedia.org/wiki/Quadratic_map',
    ),
  ];
}
