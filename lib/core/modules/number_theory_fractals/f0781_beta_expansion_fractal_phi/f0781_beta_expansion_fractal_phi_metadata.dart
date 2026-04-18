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
class F0781BetaExpansionFractalPhiMetadata {
  static const instance = F0781BetaExpansionFractalPhiMetadata._();
  const F0781BetaExpansionFractalPhiMetadata._();

  String get id => 'f0781_beta_expansion_fractal_phi';
  String get name => 'Beta-Expansion Fractal (phi)';
  String get category => 'Number-Theory Fractals';

  List<String> get aliases => const [
    'phi expansion',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. Parry',
      title: 'On the β-expansions of real numbers',
      year: 1960,
      url: 'https://doi.org/10.1007/BF02020954',
    ),
  ];
}
