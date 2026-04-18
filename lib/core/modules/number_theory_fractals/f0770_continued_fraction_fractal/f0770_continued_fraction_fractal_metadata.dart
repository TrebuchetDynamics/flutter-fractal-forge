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
class F0770ContinuedFractionFractalMetadata {
  static const instance = F0770ContinuedFractionFractalMetadata._();
  const F0770ContinuedFractionFractalMetadata._();

  String get id => 'f0770_continued_fraction_fractal';
  String get name => 'Continued Fraction Fractal';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'continued fraction',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Y. Khinchin',
      title: 'Continued fractions',
      year: 1935,
      url: 'https://mathworld.wolfram.com/ContinuedFraction.html',
    ),
  ];
}
