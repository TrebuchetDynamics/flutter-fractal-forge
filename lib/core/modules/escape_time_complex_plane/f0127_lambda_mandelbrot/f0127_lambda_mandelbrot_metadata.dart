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
class F0127LambdaMandelbrotMetadata {
  static const instance = F0127LambdaMandelbrotMetadata._();
  const F0127LambdaMandelbrotMetadata._();

  String get id => 'f0127_lambda_mandelbrot';
  String get name => 'Lambda Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Lambda Mandelbrot',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Complex_quadratic_polynomial',
    ),
  ];
}
