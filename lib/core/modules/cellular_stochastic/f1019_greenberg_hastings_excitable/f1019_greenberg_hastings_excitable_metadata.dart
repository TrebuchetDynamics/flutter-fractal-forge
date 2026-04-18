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
class F1019GreenbergHastingsExcitableMetadata {
  static const instance = F1019GreenbergHastingsExcitableMetadata._();
  const F1019GreenbergHastingsExcitableMetadata._();

  String get id => 'f1019_greenberg_hastings_excitable';
  String get name => 'Greenberg-Hastings Excitable';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'J. M. Greenberg, S. P. Hastings',
      title: 'Spatial patterns for discrete models of diffusion in excitable media',
      year: 1978,
      url: 'https://doi.org/10.1137/0134046',
    ),
  ];
}
