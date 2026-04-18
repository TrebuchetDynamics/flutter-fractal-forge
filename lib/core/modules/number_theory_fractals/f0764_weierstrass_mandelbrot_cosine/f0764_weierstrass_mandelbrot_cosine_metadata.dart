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
class F0764WeierstrassMandelbrotCosineMetadata {
  static const instance = F0764WeierstrassMandelbrotCosineMetadata._();
  const F0764WeierstrassMandelbrotCosineMetadata._();

  String get id => 'f0764_weierstrass_mandelbrot_cosine';
  String get name => 'Weierstrass-Mandelbrot Cosine';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. B. Mandelbrot',
      title: 'The Fractal Geometry of Nature',
      year: 1982,
      url: 'https://mathworld.wolfram.com/Weierstrass-MandelbrotFunction.html',
    ),
  ];
}
