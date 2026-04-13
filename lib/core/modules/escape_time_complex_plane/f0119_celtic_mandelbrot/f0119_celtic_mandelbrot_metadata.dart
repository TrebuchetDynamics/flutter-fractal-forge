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
class F0119CelticMandelbrotMetadata {
  static const instance = F0119CelticMandelbrotMetadata._();
  const F0119CelticMandelbrotMetadata._();

  String get id => 'f0119_celtic_mandelbrot';
  String get name => 'Celtic Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Celtic Mandelbrot',
      year: 2024,
      url: 'http://www.fractalforums.com/new-theories-and-research/celtic-mandelbrot/',
    ),
  ];
}
