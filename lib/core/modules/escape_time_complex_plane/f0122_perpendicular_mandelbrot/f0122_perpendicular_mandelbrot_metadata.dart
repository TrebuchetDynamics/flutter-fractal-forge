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
class F0122PerpendicularMandelbrotMetadata {
  static const instance = F0122PerpendicularMandelbrotMetadata._();
  const F0122PerpendicularMandelbrotMetadata._();

  String get id => 'f0122_perpendicular_mandelbrot';
  String get name => 'Perpendicular Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'burning_ship';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Perpendicular Mandelbrot',
      year: 2024,
      url: 'http://paulbourke.net/fractals/mandelbrot/',
    ),
  ];
}
