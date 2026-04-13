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
class F0124CubicMandelbrotCAdditiveMetadata {
  static const instance = F0124CubicMandelbrotCAdditiveMetadata._();
  const F0124CubicMandelbrotCAdditiveMetadata._();

  String get id => 'f0124_cubic_mandelbrot_c_additive';
  String get name => 'Cubic Mandelbrot (c-additive)';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_cubic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Cubic Mandelbrot (c-additive)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
