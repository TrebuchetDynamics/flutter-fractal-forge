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
class F0782BetaExpansionFractalSqrt2Metadata {
  static const instance = F0782BetaExpansionFractalSqrt2Metadata._();
  const F0782BetaExpansionFractalSqrt2Metadata._();

  String get id => 'f0782_beta_expansion_fractal_sqrt2';
  String get name => 'Beta-Expansion Fractal (sqrt2)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'A. Renyi',
      title: 'Representations for real numbers and their ergodic properties',
      year: 1957,
      url: 'https://doi.org/10.4064/aa-8-4-477-493',
    ),
  ];
}
