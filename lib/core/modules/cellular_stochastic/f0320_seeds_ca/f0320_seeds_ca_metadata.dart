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
class F0320SeedsCaMetadata {
  static const instance = F0320SeedsCaMetadata._();
  const F0320SeedsCaMetadata._();

  String get id => 'f0320_seeds_ca';
  String get name => 'Seeds CA';
  String get category => 'Cellular &amp; Stochastic';

  List<String> get aliases => const [
    'B2',
    'B2/S_',
  ];

  List<Citation> get references => const [
    Citation(
      author: 'Mirek Wójtowicz',
      title: 'Seeds (cellular automaton)',
      year: 1997,
      url: 'https://en.wikipedia.org/wiki/Seeds_(cellular_automaton)',
    ),
  ];
}
