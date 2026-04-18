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
class F0854FractalCanopySymmetricMetadata {
  static const instance = F0854FractalCanopySymmetricMetadata._();
  const F0854FractalCanopySymmetricMetadata._();

  String get id => 'f0854_fractal_canopy_symmetric';
  String get name => 'Fractal Canopy Symmetric';
  String get category => 'L-Systems & Space-Filling';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'B. B. Mandelbrot',
      title: 'The Fractal Geometry of Nature',
      year: 1982,
      url: 'https://en.wikipedia.org/wiki/Fractal_canopy',
    ),
  ];
}
