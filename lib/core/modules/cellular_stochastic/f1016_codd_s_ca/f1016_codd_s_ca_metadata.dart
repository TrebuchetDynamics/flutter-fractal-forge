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
class F1016CoddSCaMetadata {
  static const instance = F1016CoddSCaMetadata._();
  const F1016CoddSCaMetadata._();

  String get id => 'f1016_codd_s_ca';
  String get name => 'Codd\'s CA';
  String get category => 'Cellular & Stochastic';

  List<String> get aliases => const [
    'Codd',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'E. F. Codd',
      title: 'Cellular Automata',
      year: 1968,
      url: 'https://en.wikipedia.org/wiki/Codd%27s_cellular_automaton',
    ),
  ];
}
