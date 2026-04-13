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
class F0126MandelbrotScaledMetadata {
  static const instance = F0126MandelbrotScaledMetadata._();
  const F0126MandelbrotScaledMetadata._();

  String get id => 'f0126_mandelbrot_scaled';
  String get name => 'Mandelbrot Scaled';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Mandelbrot Scaled',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Mandelbrot_set',
    ),
  ];
}
