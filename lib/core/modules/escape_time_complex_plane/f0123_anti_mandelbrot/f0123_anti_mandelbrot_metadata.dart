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
class F0123AntiMandelbrotMetadata {
  static const instance = F0123AntiMandelbrotMetadata._();
  const F0123AntiMandelbrotMetadata._();

  String get id => 'f0123_anti_mandelbrot';
  String get name => 'Anti-Mandelbrot';
  String get category => 'Escape-Time (Complex Plane)';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Anti-Mandelbrot',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
