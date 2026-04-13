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
class F0125QuarticMandelbrotCAdditiveMetadata {
  static const instance = F0125QuarticMandelbrotCAdditiveMetadata._();
  const F0125QuarticMandelbrotCAdditiveMetadata._();

  String get id => 'f0125_quartic_mandelbrot_c_additive';
  String get name => 'Quartic Mandelbrot (c-additive)';
  String get category => 'Escape-Time (Complex Plane)';
  String get family => 'multibrot_quartic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Wikipedia / Paul Bourke / Fractal Forums',
      title: 'Quartic Mandelbrot (c-additive)',
      year: 2024,
      url: 'https://en.wikipedia.org/wiki/Multibrot_set',
    ),
  ];
}
