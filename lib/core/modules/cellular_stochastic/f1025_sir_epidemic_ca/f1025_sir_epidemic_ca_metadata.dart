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
class F1025SirEpidemicCaMetadata {
  static const instance = F1025SirEpidemicCaMetadata._();
  const F1025SirEpidemicCaMetadata._();

  String get id => 'f1025_sir_epidemic_ca';
  String get name => 'SIR Epidemic CA';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
  ];

  List<Citation> get references => const [
    Citation(
      author: 'W. O. Kermack, A. G. McKendrick',
      title: 'A contribution to the mathematical theory of epidemics',
      year: 1927,
      url: 'https://doi.org/10.1098/rspa.1927.0118',
    ),
  ];
}
